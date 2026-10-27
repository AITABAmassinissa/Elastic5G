# UPF → UPF-VPP migration

All UPFs of this repository (slice 1 to slice 4) are **UPF-VPP** (`oai-upf-vpp:v2.2.1`, the VPP-based OAI UPF built from `oai-cn5g-fed/component/oai-upf-vpp`, same build procedure as the other network functions, see the main README) instead of the simple-switch `oai-upf`. The rest of the core (AMF, NRF, NSSF, UDM, UDR, AUSF, LMF, SMF) is built from the same release (OAI CN5G `v2.2.1`, previously `v2.1.0`); MySQL and NWDAF are unchanged.

The chart directories and Kubernetes names stay `oai-upf`, `oai-upf2`, `oai-upf3`, `oai-upf4` on purpose: the Service names, the Helm release names (`helm install upf2 slice2/oai-upf2 ...`) and the references from the other network functions are therefore unchanged.

## Files modified

| Path | Change |
|---|---|
| `oai-5g-core/oai-upf/`, `slice2/oai-upf2/`, `slice3/oai-upf3/`, `slice4/oai-upf4/` | image `oai-upf-vpp`, configuration by environment variables (`vpp:` block), Multus N3/N6, `pgrep vpp` probe, static ClusterIP, autoscaling disabled; `config.yaml` and `templates/configmap.yaml` removed (not read by UPF-VPP) |
| `oai-5g-core/oai-smf/`, `slice2/oai-smf2/`, `slice3/oai-smf3/`, `slice4/oai-smf4/` | `config.yaml`: `smf.upfs[].config.n3_local_ipv4`; `values.yaml` + `templates/deployment.yaml`: `upfHostAlias` → `hostAliases` |
| `oai-5g-core/oai-5g-advance/values.yaml` | UPF-VPP image, Multus, `vpp:` block and `upfHostAlias` for slice 1 (the file to edit for the umbrella deployment) |
| `oai-5g-core/oai-5g-advance/charts/oai-upf-v2.1.0.tgz`, `oai-smf-v2.1.0.tgz` | repackaged with `helm package`, otherwise `helm install` would keep deploying the old frozen content |
| `oai-5g-core/oai-traffic-server/templates/deployment.yaml`, `oai-5g-advance/charts/oai-traffic-server-v1.tgz` | init container: waits for the UPF Service name (`getent hosts`) instead of probing UDP 2152 (see below) |
| `oai-5g-ran/ueransim-gnb3/` | Multus N3 interface on `br-n3` (the gNB must be on the same L2 segment as the UPF-VPP), `nodeSelector` |
| `oai-5g-core/host-net-setup/daemonset.yaml` | **new**: creates `br-n3`, `br-n6`, the N6 gateway, the return routes to the UE pools and the NAT on every node |
| `README.md`, `docs/Slicing.md`, `docs/pod-commands.md`, UPF chart READMEs | UPF-VPP wording, prerequisites, `vppctl` commands |
| `docs/NWDAF-slicing-validation.md` | reworked NWDAF page |

## DNN names without digits (OAI CN5G v2.2.1)

The whole core is built from OAI CN5G `v2.2.1`. That release re-parses the plain-text DNN in the SMF as a length-prefixed label list, so a DNN containing a digit, `.` or `-` is truncated (`oai2` becomes `oai`) and its PDU sessions are rejected. The DNNs were therefore renamed: `oai2`→`oaib`, `oai3`→`oaic`, `oai4`→`oaid` (`oai` is unchanged), in the subscriber database, the SMF configs, the UPF-VPP `vpp.dnn` values, the UE `apn` values, the docs and the NWDAF page/script.

## Addressing plan

| Slice | UPF-VPP chart | SST / DNN | N3 | N6 | ClusterIP (SMF `hostAliases`) | NRF | UE pool |
|---|---|---|---|---|---|---|---|
| 1 | `oai-upf` | 1 / `oai` | 10.100.3.101 | 10.100.6.101 | 10.110.99.101 | `oai-nrf` | 12.1.1.0/24 |
| 2 | `oai-upf2` | 2 / `oaib` | 10.100.3.102 | 10.100.6.102 | 10.110.99.102 | `oai-nrf` | 12.1.2.0/24 |
| 3 | `oai-upf3` | 3 / `oaic` | 10.100.3.103 | 10.100.6.103 | 10.110.99.103 | `oai-nrf2` | 12.1.3.0/24 |
| 4 | `oai-upf4` | 2 (SD `000002`) / `oaid` | 10.100.3.104 | 10.100.6.104 | 10.110.99.104 | `oai-nrf` | 12.1.4.0/24 |

* The gNB uses `10.100.3.200` on `br-n3`.
* PLMN is `001` / `01` (as in the AMF). UPF-VPP registers at the NRF under `vpp-upf-slice<N>.node.5gcn.mnc01.mcc001.3gppnetwork.org` (built literally from `NAME`, `MNC`, `MCC`, `REALM`).
* The `10.110.99.10x` ClusterIPs must belong to the service CIDR of the cluster (`10.96.0.0/12` by default with kubeadm) and be free. Change `staticClusterIP` / `upfHostAlias.ip` together if needed.
* `SNSSAI_SD` is mandatory for UPF-VPP: `ffffff` (3GPP "no SD" value) for slices 1 to 3, `000002` for slice 4.

## Why the network changes

The simple-switch UPF routes through the kernel IP stack and can multiplex N3/N4/N6 on `eth0`. UPF-VPP takes over its interfaces (AF_PACKET / VPP): it needs one interface per role. N4 (PFCP) and the SBI registration to the NRF stay on `eth0` (pod IP injected with the downward API); **N3 and N6 need Multus** (macvlan on `br-n3` / `br-n6`).

Why the SMF needs two additions:

* UPF-VPP does not create its own F-TEID: without `smf.upfs[].config.n3_local_ipv4` the SMF hands the gNB the ClusterIP as GTP-U address.
* The FQDN registered by UPF-VPP is not in any DNS: the SMF resolves it through `hostAliases` pointing to the (static) ClusterIP of the UPF Service.

## Deployment

```bash
kubectl apply -f oai-5g-core/host-net-setup/daemonset.yaml        # once per cluster
kubectl label node <node> elastic5g.io/radio-plane=true            # node hosting the gNB and the UPF-VPP pods

helm dependency update oai-5g-core/oai-5g-advance/                 # optional, re-packages all sub-charts
helm install 5gc oai-5g-core/oai-5g-advance/ -n oai5g

helm install ueransim-gnb oai-5g-ran/ueransim-gnb3/ -n oai5g
helm install upf2 slice2/oai-upf2 -n oai5g && helm install smf2 slice2/oai-smf2 -n oai5g
helm install nrf2 slice3/oai-nrf2 -n oai5g && helm install upf3 slice3/oai-upf3 -n oai5g && helm install smf3 slice3/oai-smf3 -n oai5g
helm install upf4 slice4/oai-upf4 -n oai5g && helm install smf4 slice4/oai-smf4 -n oai5g
```

Then deploy the UEs as described in [Slicing.md](Slicing.md).

## Known limitations

* **Autoscaling disabled.** VPP busy-polls its worker core (about 100 % CPU even idle) and each replica would need its own static Multus IP, so the UPF HPA is off (`autoscaling.enabled: false`) and the UPF runs with one replica.
* **gNB and UPF-VPP on the same node.** L2 adjacency on `br-n3` / `br-n6`, enforced with the `elastic5g.io/radio-plane` label.
* **Slices 1, 2 and 4 share `oai-nrf`.** The SMF subscribes to NRF notifications without filtering on S-NSSAI/DNN, so each of these three SMFs is notified of the three UPF-VPP and tries to associate with all of them. An SMF that cannot resolve a UPF-VPP FQDN retries forever and never associates with its own UPF (observed: no PFCP association at all for slices 1 and 2). The SMF charts therefore carry `upfHostAlias.extra`, which resolves the FQDNs of the other slices' UPF-VPP too; the UPF selection then filters on S-NSSAI/DNN and each session lands on the right UPF (verified, see below). Slice 3 has its own NRF (`oai-nrf2`) and is not concerned. Giving each slice its own NRF would be cleaner but is not possible for slices 2 and 4 (next point).
* **Slices 2 and 4 are separated by their SD.** Both use SST 2 and the AMF picks the **first SMF whose S-NSSAI matches**, without looking at the DNN (`NFDiscovery ... target-nf-type=SMF` carries no S-NSSAI/DNN, AMF `discover_smf`). Slice 4 therefore uses **S-NSSAI SST 2 / SD `000002`** (subscriber database, SMF4, UPF-VPP 4, UE6, AMF, NSSF and gNB configs), so that the two slices can run at the same time.
* **Creating a slice at runtime: wait about one minute before attaching its UEs.** A new SMF/UPF-VPP pair needs the NRF notifications of the other SMFs to settle: an SMF re-sends its PFCP Association Setup Request (new Recovery Time Stamp) to a UPF-VPP several times in the first minute, and every request makes the UPF-VPP delete the PDU sessions already attached to that SMF. A UE attached during this minute gets an IP address but no session on its UPF-VPP (`vppctl show upf session` stays empty, no traffic). Check `vppctl show upf association` on the new UPF-VPP, wait about 70 s after `helm install`, then install the UE chart.
* **The OAI NRF keeps the subscriptions of the NFs that disappeared.** After many create/delete cycles of a slice, its notifications to the dead pods stall the NRF for seconds; the SMFs then miss an NRF heartbeat, register again and re-associate with their UPF-VPP, which resets their sessions (the UEs of those slices must be restarted). On a test bed that is rebuilt often, reinstall the core (`helm uninstall` / `helm install 5gc`) instead of cycling a slice many times.
* **UE pods after a gNB restart.** UERANSIM UEs lose their cell when the gNB pod is recreated: restart the UE deployments (scale to 0 then 1) after any gNB restart.
* **OAI RAN charts not adapted.** Only the UERANSIM gNB (`ueransim-gnb3`) gets the N3 Multus interface. With the OAI monolithic gNB or the disaggregated CU/DU, enable a `n3` Multus interface on `br-n3` in the CU-UP / gNB values (and an IP in `10.100.3.0/24`) before use.
* **`oai-traffic-server` not adapted.** The external DN pod stays on the cluster network; it is not on the N6 segment of UPF-VPP. Its init container used to wait for the UPF with `ncat -zv oai-upf 2152 --udp`: the simple-switch UPF binds that UDP port in the pod kernel, UPF-VPP does not (VPP serves GTP-U on the N3 interface), so the probe received an ICMP *port unreachable* and the pod stayed in `Init:0/1` (it only passed when the kernel rate-limited the ICMP reply). The init container now waits for the `oai-upf` Service name to resolve.
* **No PCF / double DNAI steering.**

## Kernel forwarding is disabled in the UPF-VPP pod

The N3/N6/eth0 interfaces of UPF-VPP also exist in the pod's kernel, which sees the same frames as VPP (AF_PACKET does not steal them). With `net.ipv4.ip_forward=1` (the pod default) the kernel forwards the N6 replies a second time through its default route (eth0, towards the node), the node sends them back through `mv-n6`, and the packet loops until its TTL expires: every reply to a destination inside the cluster (for example the `iperf3` server pod) is duplicated about 30 times and TCP breaks (`iperf3: unable to send control message: Broken pipe`). The `postStart` hook of the UPF-VPP charts therefore sets `net.ipv4.ip_forward=0`.

## NRF registration of UPF-VPP

UPF-VPP registers at the NRF once, at start-up, while the pod is still creating its interfaces, and that request fails (`NF Registration Procedure Failed (response is 000)` in its log). The `postStart` hook of the UPF-VPP charts therefore registers the profile the image generated (`/openair-upf/etc/upf_profile.json`) again with `curl`. On every try it also puts back the default route through `n4-1` and pins the MAC addresses of the VPP AF_PACKET interfaces to the kernel ones (VPP drops the answers otherwise), then sends the registration with a single NF instance id, every 3 s for about 5 minutes, until the NRF answers 200/201. A shorter loop (6 tries in 30 s) was not enough when many pods start together (`helm install 5gc` on a loaded node): the UPF-VPP of slice 1 stayed unregistered, the SMF never associated with it and the first UE got `PDU Session Establishment Reject` (`UPF selection failed` in the SMF log). Symptoms: no `VPP-UPF-SLICE<N>` profile in the NRF log and an empty `vppctl show upf association`.

## Checks

```bash
kubectl get pods -n oai5g -o wide
kubectl exec -n oai5g deploy/oai-upf  -- /openair-upf/bin/vppctl show upf association   # SMF associated
kubectl exec -n oai5g deploy/oai-upf  -- /openair-upf/bin/vppctl show upf session       # Local F-TEID = 10.100.3.10x
```

Verified on a fresh single-node kubeadm cluster (v1.31, containerd, Flannel, Multus thick, metrics-server), namespace `oai5g`, with **all images built from source** with the README commands (OAI CN5G `v2.2.1`: NRF, NSSF, LMF, UDR, UDM, AUSF, AMF, SMF and UPF-VPP; UPF-VPP on `ubuntu:focal`, the others on `ubuntu:jammy`; a 16 GB swap file was needed while building), the NWDAF images built from `NWDAF/components`, the core installed with `helm install 5gc` and the slices with the README commands:

| Check | Result |
|---|---|
| PFCP association | `vppctl show upf association` lists the SMF(s) on every UPF-VPP |
| Slice 1 (`oai`) | PDU session on `oai-upf`, F-TEID `10.100.3.101`, ping 8.8.8.8 0 % loss, iperf3 about 110 Mbit/s (AMBR 100) |
| Slice 2 (`oaib`) | session on `oai-upf2`, iperf3 about 226 Mbit/s (AMBR 200) |
| Slice 3 (`oaic`) | session on `oai-upf3`, iperf3 about 315 Mbit/s (AMBR 300) |
| Slice 4 (`oaid`) | session on `oai-upf4`, iperf3 about 400 Mbit/s (AMBR 500: the UERANSIM gNB/UE peaks at 400-440 Mbit/s on the test machine, the cap is not reached) |
| NWDAF | 8 pods ready, `NWDAF/scripts/check-nwdaf.sh` passes (AMF events, SMF events of slice 1, engine API, gateway API) |

Notes from the runs: after (re)deploying a slice, give its UPF-VPP about a minute to settle (see the limitation above) before starting the UE; a UE that registered too early can get an IP without a session on the UPF, in which case restart the UE (scale to 0 then 1).
