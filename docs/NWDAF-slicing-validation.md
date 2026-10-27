# Validate Slices and UEs with NWDAF

NWDAF is used here as an additional validation layer for the 4-slice deployment (UPF-VPP user plane).

* `ping` validates basic user-plane connectivity.
* `iperf3` validates throughput and AMBR behavior.
* **NWDAF validates what the core network itself sees**: which UEs are registered (AMF events), where they are (NR cell / TAI), and which PDU sessions are established per DNN / slice (SMF events).

## Contents

1. [How it works](#how-it-works)
2. [What UPF-VPP changes (and what it does not)](#what-upf-vpp-changes-and-what-it-does-not)
3. [One-command check](#one-command-check)
4. [The 4 slices at a glance](#the-4-slices-at-a-glance)
5. [Step 1: NWDAF pods](#step-1-nwdaf-pods)
6. [Step 2: UEs seen by the AMF](#step-2-ues-seen-by-the-amf)
7. [Step 3: PDU sessions seen by the SMF](#step-3-pdu-sessions-seen-by-the-smf)
8. [Step 4: NWDAF engine API](#step-4-nwdaf-engine-api)
9. [Step 5: standard 3GPP API through the gateway](#step-5-standard-3gpp-api-through-the-gateway)
10. [Generate fresh events](#generate-fresh-events)
11. [Interpretation](#interpretation)
12. [Troubleshooting](#troubleshooting)

---

## How it works

```text
  AMF  ──(Namf_EventExposure notifications, HTTP/2)──┐
                                                     ├──▶ oai-nwdaf-sbi ──▶ MongoDB (db "testing")
  SMF (slice 1) ──(Nsmf_EventExposure notifications)─┘                       ├─ amf  collection
                                                                             └─ smf  collection
                                                                                  │
                    oai-nwdaf-engine :8080  ◀──────── reads the collections ──────┘
                           ▲
         oai-nwdaf-nbi-analytics / -events / -ml  ◀──  Kong gateway oai-nwdaf-nbi-gateway :80
                                                       (3GPP Nnwdaf_AnalyticsInfo / EventsSubscription)
```

| Component | Service / port | Role |
|---|---|---|
| `oai-nwdaf-sbi` | `oai-nwdaf-sbi:8080` | subscribes to the AMF and the SMF, receives their notifications and stores them in MongoDB |
| `oai-nwdaf-database` | `oai-nwdaf-database:27017` | MongoDB, database `testing`, collections `amf` and `smf` |
| `oai-nwdaf-engine` | `oai-nwdaf-engine:8080` | computes the analytics from the collections (internal API) |
| `oai-nwdaf-nbi-analytics`, `-events`, `-ml` | `:8080` | 3GPP northbound APIs |
| `oai-nwdaf-nbi-gateway` | `oai-nwdaf-nbi-gateway:80` | Kong gateway in front of the three northbound APIs |

Stored documents:

| Collection | `_id` | Main fields |
|---|---|---|
| `amf` | SUPI with prefix (`imsi-001010000000102`) | `rminfolist[]` (registration state `REGISTERED`, access type, timestamp), `locationlist[]` (NR location: TAI, NCGI, timestamp) |
| `smf` | IMSI without the `imsi-` prefix and leading zeros (`1010000000102`) | `pdusesestlist[]` (`dnn`, `snssai.sst`, `adipv4addr`, `pduseid`, `timestamp`), `qosmonlist[]` when QoS monitoring events exist |

## What UPF-VPP changes (and what it does not)

NWDAF only talks to the **AMF** and the **SMF**; it never talks to the UPF. Moving the user plane from the simple-switch UPF to UPF-VPP therefore does not change anything in the NWDAF deployment: the AMF and SMF events are the same.

What it means in practice:

* A PDU session through UPF-VPP is still reported by the SMF (`PDU_SES_EST`), so it shows up in the `smf` collection like before.
* UPF-VPP does not expose any SBI server (it only registers at the NRF), so nothing UPF-related can be collected by NWDAF.
* QoS monitoring (`UE_COMMUNICATION` analytics) depends on SMF `QOS_MON` events, which are not generated in this setup (see [Interpretation](#interpretation)).

## One-command check

[`NWDAF/scripts/check-nwdaf.sh`](../NWDAF/scripts/check-nwdaf.sh) runs steps 1 to 5 below in one go (pods, MongoDB counters per slice, engine API, gateway API) and exits with a non-zero code if a mandatory check fails:

```bash
NWDAF/scripts/check-nwdaf.sh          # namespace oai5g
NS=my-namespace NWDAF/scripts/check-nwdaf.sh
```

Example of a healthy output (excerpt):

```text
== 2. MongoDB (testing): AMF and SMF collections
    AMF documents (all UEs): 4
    AMF REGISTERED: 4
    SMF documents: 1
    slice 1 amf=1 smf_pdu_sessions(dnn oai)=1
  [ OK ] AMF events reach NWDAF (4 UE documents)
== 3. NWDAF engine API ...
  [ OK ] engine_num_of_ue -> {"absoluteNum":4}
```

The same checks are detailed manually below.

## The 4 slices at a glance

| Slice | UE chart | SUPI | DNN | SST | UE pool | SMF | UPF-VPP |
|---|---|---|---|---|---|---|---|
| 1 | `ueransim-ue3` | `imsi-001010000000102` | `oai` | 1 | 12.1.1.0/24 | `oai-smf` | `oai-upf` |
| 2 | `ueransim-ue4` | `imsi-001010000000200` | `oaib` | 2 | 12.1.2.0/24 | `oai-smf2` | `oai-upf2` |
| 3 | `ueransim-ue5` | `imsi-001010000000300` | `oaic` | 3 | 12.1.3.0/24 | `oai-smf3` | `oai-upf3` |
| 4 | `ueransim-ue6` | `imsi-001010000000400` | `oaid` | 2 | 12.1.4.0/24 | `oai-smf4` | `oai-upf4` |

The SUPI of a UE is `imsi-<MCC><MNC><initialMSISDN>` from the UE chart values (`helm template ueransim-ue3 oai-5g-ran/ueransim-ue3 | grep supi` shows the real one). The IMSI ranges of the subscriber database are `…100-120` (slice 1), `…200-220`, `…300-320` and `…400-420`; they are used below to count the UEs per slice.

> Slices 2 and 4 both use SST 2 and are told apart by their SD (slice 4: SD `000002`) and by their DNN (`oaib` / `oaid`).

---

## Step 1: NWDAF pods

```bash
kubectl get pods -n oai5g | grep nwdaf
```

All eight pods (`database`, `sbi`, `engine`, `engine-ads`, `nbi-analytics`, `nbi-events`, `nbi-ml`, `nbi-gateway`) must be `1/1 Running`.

Check that the SBI has subscribed to the AMF and the SMF:

```bash
kubectl logs -n oai5g deploy/oai-nwdaf-sbi | grep -i -E "subscri|error" | tail -20
```

## Step 2: UEs seen by the AMF

Collections and global counters:

```bash
kubectl exec -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
const d = db.getSiblingDB("testing");
print("collections: " + d.getCollectionNames());
print("amf documents: " + d.amf.countDocuments({}));
print("smf documents: " + d.smf.countDocuments({}));
print("registered UEs: " + d.amf.countDocuments({"rminfolist.rminfo.rmstate.rmstateanyof": "REGISTERED"}));
'
```

All UEs, with their registration state and last known cell:

```bash
kubectl exec -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
db.getSiblingDB("testing").amf.find({}, {
  _id: 1,
  "rminfolist.rminfo.rmstate.rmstateanyof": 1,
  "rminfolist.timestamp": 1,
  "locationlist.userlocation.nrlocation.tai": 1,
  "locationlist.userlocation.nrlocation.ncgi": 1
}).forEach(printjson);
'
```

A correctly registered UE has `rmstateanyof: REGISTERED` and `accesstype: 3GPP_ACCESS`.

One UE (replace the SUPI with the one of the slice, see the table above):

```bash
kubectl exec -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
printjson(db.getSiblingDB("testing").amf.findOne({_id: "imsi-001010000000200"}));
'
```

UEs per slice (AMF side) with the IMSI ranges:

```bash
kubectl exec -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
const d = db.getSiblingDB("testing");
[["1", /^imsi-0010100000001/], ["2", /^imsi-0010100000002/],
 ["3", /^imsi-0010100000003/], ["4", /^imsi-0010100000004/]].forEach(function (s) {
  print("Slice " + s[0] + " UEs in NWDAF: " + d.amf.countDocuments({_id: s[1]}));
});
'
```

Expected with one UE per slice: `1` for each slice.

## Step 3: PDU sessions seen by the SMF

The `smf` collection is fed by the SMF event exposure (`PDU_SES_EST`, `PDU_SES_REL`, ...). It tells which DNN / S-NSSAI the sessions use, so it is the NWDAF view of the slices:

```bash
kubectl exec -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
const d = db.getSiblingDB("testing");
["oai", "oaib", "oaic", "oaid"].forEach(function (dnn) {
  print("DNN " + dnn + ": UEs with a PDU session = " + d.smf.countDocuments({"pdusesestlist.dnn": dnn}));
});
d.smf.find({}, {_id: 1, "pdusesestlist.dnn": 1, "pdusesestlist.snssai": 1, "pdusesestlist.adipv4addr": 1}).forEach(printjson);
'
```

A healthy slice-1 UE shows `dnn: oai`, `snssai.sst: 1` and an `adipv4addr` of the `12.1.1.0/24` pool.

> **Only one SMF is subscribed.** `oai-nwdaf-sbi` subscribes to a single SMF (`SMF_IP_ADDR: http://oai-smf` in [`oai-nwdaf-sbi-deployment.yaml`](../NWDAF/deployment/oai-nwdaf-sbi-deployment.yaml)), i.e. the SMF of **slice 1**. PDU sessions of slices 2, 3 and 4 (`oai-smf2/3/4`) are therefore **not** stored in the `smf` collection, whereas the `amf` collection covers the UEs of **all** slices (a single AMF). An empty `smf` count for DNN `oaib`, `oaic`, `oaid` is expected with this deployment, it does not mean that the session failed (check it with `ping` / `iperf3`).

## Step 4: NWDAF engine API

The engine exposes four internal routes on **port 8080** (`oai-nwdaf-engine:8080`). They are `GET` requests with a JSON body:

| Route | Body | Answers |
|---|---|---|
| `/network_performance/num_of_ue` | `{}` (optional: `tais`, `startTs`, `endTs`) | number of registered UEs (all slices, from `amf`) |
| `/network_performance/sess_succ_ratio` | `{"dnns": [...], "snssaia": [{"sst": N}]}` | number of UEs with a PDU session matching the DNN / S-NSSAI (from `smf`) |
| `/ue_mobility` | `{"supi": "imsi-..."}` | location history of a UE (from `amf`) |
| `/ue_communication` | `{}` | communication statistics (from the `qosmonlist` of `smf`) |

Run the queries from a temporary curl pod:

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8080/network_performance/num_of_ue \
  -H "Content-Type: application/json" -d '{}'
```

```json
{"absoluteNum":4}
```

PDU sessions of slice 1 (DNN `oai`, SST 1):

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8080/network_performance/sess_succ_ratio \
  -H "Content-Type: application/json" \
  -d '{"dnns": ["oai"], "snssaia": [{"sst": 1}]}'
```

For another slice, change the DNN and the SST (`oaib`/2, `oaic`/3, `oaid`/2 with `"sd": "000002"`). `sd` is optional in the filter (`"sd": "000002"` is accepted, case-insensitive).

UE mobility (the SUPI must include the `imsi-` prefix, as stored by the AMF):

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8080/ue_mobility \
  -H "Content-Type: application/json" -d '{"supi":"imsi-001010000000200"}'
```

It returns `{"loc":[{...}]}` with the TAI / PLMN / NR cell of the UE.

> **A zero is an empty object.** The engine omits `absoluteNum` when it is `0`: a response of `{}` means "0", not an error. An HTTP error (`400`, `405`, `500`) is an error. `/network_performance/num_of_ue` ignores the DNN / slice filters (it counts every registered UE); use Step 2 for a per-slice count.

## Step 5: standard 3GPP API through the gateway

External consumers do not call the engine; they use the 3GPP `Nnwdaf` APIs exposed by the Kong gateway (`oai-nwdaf-nbi-gateway`, port 80, route matched on the `Host: oai-nwdaf-nbi-gateway` header).

**Nnwdaf_AnalyticsInfo**: number of UEs, then the mobility of one UE:

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never --image=curlimages/curl --command -- sh -c '
curl -sG "http://oai-nwdaf-nbi-gateway/nnwdaf-analyticsinfo/v1/analytics" \
  -H "Host: oai-nwdaf-nbi-gateway" \
  --data-urlencode "event-id=NETWORK_PERFORMANCE" \
  --data-urlencode "event-filter={\"nwPerfTypes\":[\"NUM_OF_UE\"]}"
echo
curl -sG "http://oai-nwdaf-nbi-gateway/nnwdaf-analyticsinfo/v1/analytics" \
  -H "Host: oai-nwdaf-nbi-gateway" \
  --data-urlencode "event-id=UE_MOBILITY" \
  --data-urlencode "tgt-ue={\"supis\":[\"imsi-001010000000200\"]}"'
```

Supported `event-id` values in this build: `NETWORK_PERFORMANCE` (`nwPerfTypes`: `NUM_OF_UE`, `SESS_SUCC_RATIO`; the latter also takes `dnns` and `snssais` in the `event-filter`), `UE_MOBILITY` (needs `tgt-ue.supis`) and `UE_COMMUNICATION`. Any other value answers `400 invalid Event Id param`.

**Nnwdaf_EventsSubscription**: periodic notifications (`notificationURI` must be reachable from the cluster, for example a pod that listens on port 9000):

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never --image=curlimages/curl --command -- sh -c '
curl -s -i -X POST "http://oai-nwdaf-nbi-gateway/nnwdaf-eventssubscription/v1/subscriptions" \
  -H "Host: oai-nwdaf-nbi-gateway" -H "Content-Type: application/json" \
  -d "{\"notificationURI\":\"http://<receiver-ip>:9000/notification\",
       \"eventSubscriptions\":[{\"event\":\"NETWORK_PERFORMANCE\",\"notificationMethod\":\"PERIODIC\",
       \"repetitionPeriod\":5,\"nwPerfRequs\":[{\"nwPerfType\":\"NUM_OF_UE\"}]}]}"'
```

A `201 Created` is expected, then one notification every `repetitionPeriod` seconds carrying the current value. If the first notification cannot be delivered, the subscription is closed by NWDAF: fix the receiver and subscribe again.

## Generate fresh events

Events are only recorded when something happens. To produce new AMF and SMF events for a slice, cycle its UE (scale to 0, wait for the pod to disappear, scale to 1):

```bash
kubectl scale deploy/ueransim-ue4 -n oai5g --replicas=0
kubectl wait --for=delete pod -n oai5g -l app.kubernetes.io/instance=ueransim-ue4 --timeout=60s
kubectl scale deploy/ueransim-ue4 -n oai5g --replicas=1
```

Then wait about a minute for the registration and PDU session establishment, and repeat Step 2 / 3.

## Interpretation

| Observation | Meaning |
|---|---|
| UE in `amf` with `REGISTERED` | the core network sees the UE and NWDAF receives the AMF events |
| `amf` count per slice = number of deployed UEs | slices are populated as expected |
| UE in `smf` with the right `dnn` / `snssai` / pool IP | the PDU session was established in the right slice (slice 1 only, see Step 3) |
| `{}` from `sess_succ_ratio` | zero matching sessions in the `smf` collection |
| `ue_communication` returns zeros or an error | no `qosmonlist`: the SMF does not emit QoS monitoring events in this setup. Not related to UPF-VPP |
| ping works but the UE is missing in `amf` | NWDAF is not receiving the AMF events (see Troubleshooting) |

In this deployment:

* `ping` validates basic user-plane connectivity through UPF-VPP.
* `iperf3` validates throughput and AMBR behavior.
* NWDAF `amf` collection validates UE registration and location visibility for all slices.
* NWDAF `smf` collection validates PDU sessions per DNN for the slice whose SMF is subscribed (slice 1).

## Troubleshooting

| Symptom | Likely cause | What to check |
|---|---|---|
| `amf` collection empty although UEs are registered | SBI did not subscribe to the AMF, or the AMF notifications are not accepted | `kubectl logs -n oai5g deploy/oai-nwdaf-sbi`; the AMF talks HTTP/2 without TLS, the SBI image must be built from the sources in `NWDAF/components/oai-nwdaf-sbi` (they serve `h2c`) |
| `amf` is filled but the UE just registered is missing | the AMF notifies when a UE changes state | cycle the UE (see [Generate fresh events](#generate-fresh-events)) |
| `curl: (7)` / connection refused on port 8888 | wrong port | the engine listens on **8080** |
| `smf` empty | SBI not subscribed to the SMF, or no PDU session since NWDAF started | `kubectl logs deploy/oai-nwdaf-sbi`; cycle the slice-1 UE |
| `smf` empty for DNN `oaib` / `oaic` / `oaid` | only the slice-1 SMF is subscribed | expected, see Step 3 |
| gateway answers `404 no Route matched` | missing `Host` header | add `-H "Host: oai-nwdaf-nbi-gateway"` |
| analytics answers `400 missing UE Communications Data` | the engine returned no data for that request (unknown SUPI, wrong `imsi-` prefix, no events yet) | run the same request on the engine (Step 4) |
