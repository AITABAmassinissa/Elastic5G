# Helm Chart for OAI User Plane Network Function: UPF-VPP (slice 2)

This chart deploys **UPF-VPP** (`oai-upf-vpp:v2.2.1`, the VPP-based OAI UPF, built from `oai-cn5g-fed/component/oai-upf-vpp`, see the main README) for slice 2. It replaces the former simple-switch `oai-upf` image. The chart keeps the name `oai-upf2` so that the Kubernetes Service name, the Helm release names and the references of the other network functions are unchanged.

## What is different from the simple-switch UPF

* **Configuration by environment variables.** UPF-VPP does not read any `config.yaml`; the `vpp:` block of `values.yaml` is turned into environment variables (`NAME`, `MCC`, `MNC`, `SNSSAI_SST`, `SNSSAI_SD`, `DNN`, `NRF_IP_ADDR`, `IF_1..3`, ...) in `templates/deployment.yaml`.
* **Dedicated N3 and N6 interfaces.** UPF-VPP takes over its interfaces (VPP / AF_PACKET), so N3 and N6 each need their own Multus interface (macvlan on the host bridges `br-n3` and `br-n6`). N4 (PFCP) and the SBI registration to the NRF stay on `eth0` (the pod IP is injected through the downward API).
* **Static ClusterIP.** `staticClusterIP` is fixed because the SMF reaches this UPF-VPP through a `hostAliases` entry (UPF-VPP registers a made-up FQDN at the NRF).
* **No autoscaling.** VPP busy-polls its worker core and each replica needs its own static Multus IP, so `autoscaling.enabled` is `false`.
* **Health check.** `pgrep vpp`.

## Slice 2 parameters

| Parameter | Value |
|---|---|
| Registration name / FQDN | `VPP-UPF-SLICE2` / `vpp-upf-slice2.node.5gcn.mnc01.mcc001.3gppnetwork.org` |
| N3 (GTP-U to the gNB) | `10.100.3.102/24` on `br-n3` |
| N6 (towards the data network) | `10.100.6.102/24` on `br-n6` |
| ClusterIP (SMF `hostAliases`) | `10.110.99.102` |
| NRF | `oai-nrf` |

The matching SMF must declare the same FQDN and N3 address under `smf.upfs` in its `config.yaml` and the same IP in `upfHostAlias` of its `values.yaml`.

## Prerequisites

* Multus installed in the cluster.
* The bridges `br-n3` and `br-n6` on the node: `kubectl apply -f oai-5g-core/host-net-setup/daemonset.yaml`.
* The node hosting the gNB and the UPF-VPP pods labelled `elastic5g.io/radio-plane=true`.

See [docs/CHANGES-upf-vpp.md](../../docs/CHANGES-upf-vpp.md) for the full description.

## Debug

```bash
kubectl exec -n oai5g deploy/oai-upf2 -- /openair-upf/bin/vppctl show upf association
kubectl exec -n oai5g deploy/oai-upf2 -- /openair-upf/bin/vppctl show upf session
```
