# Validate Slices and UEs with NWDAF

NWDAF can be used as an additional validation layer for the slicing deployment.

While `ping` validates basic user-plane connectivity and `iperf3` validates throughput and AMBR behavior, NWDAF allows us to check whether the UEs are visible from the 5G core monitoring point of view.

In this setup, the NWDAF database stores AMF-related information in the `amf` collection and, depending on the available SMF event exposure integration, SMF-related information in the `smf` collection.

The following commands are useful to verify UE registration, UE mobility information, and the number of connected UEs.

---

## NWDAF available checks

According to the NWDAF deployment and source code, the following analytics are useful for this setup:

```text
NETWORK_PERFORMANCE
UE_COMMUNICATION
UE_MOBILITY
```

The NWDAF engine exposes the following internal routes:

```text
/network_performance/num_of_ue
/network_performance/sess_succ_ratio
/ue_communication
/ue_mobility
```

These routes rely mainly on the MongoDB collections:

```text
amf
smf
```

In practice, if the `smf` collection is empty, UE registration and location can still be validated through the `amf` collection.

---

## Check NWDAF database collections

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
print("NWDAF collections:");
printjson(db.getCollectionNames());
print("AMF documents:");
printjson(db.amf.countDocuments());
print("SMF documents:");
printjson(db.getCollectionNames().includes("smf") ? db.smf.countDocuments() : 0);
'
```

If the `amf` collection contains documents, NWDAF is receiving AMF-side information about registered UEs.

If the `smf` collection is empty, UE registration can still be validated through the `amf` collection, but PDU session or traffic-related analytics may not be available.

---

## Check all UEs registered in NWDAF

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
print("Registered UEs seen by NWDAF AMF collection:");
db.amf.find(
  {},
  {
    _id: 1,
    "rminfolist.rminfo.rmstate.rmstateanyof": 1,
    "rminfolist.timestamp": 1,
    "locationlist.userlocation.nrlocation.tai": 1,
    "locationlist.userlocation.nrlocation.ncgi": 1
  }
).forEach(printjson);
'
```

A correctly registered UE should appear with:

```text
rmstateanyof: REGISTERED
accesstype: 3GPP_ACCESS
```

---

## Check the number of registered UEs

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
print("Number of registered UEs:");
printjson(db.amf.countDocuments({
  "rminfolist.rminfo.rmstate.rmstateanyof": "REGISTERED"
}));
'
```

This is useful after adding a new UE. The value should increase when a new UE successfully registers.

---

## Validate slice 1 UE

Slice 1 uses:

```text
UE: ueransim-ue3
IMSI: 001010000000100
DNN: oai
SST: 1
Tunnel IP: 12.1.1.2
```

Check the UE in NWDAF:

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
const imsi = "imsi-001010000000100";
print("AMF document for " + imsi + ":");
printjson(db.amf.findOne(
  {_id: imsi},
  {
    _id: 1,
    "rminfolist.rminfo.rmstate.rmstateanyof": 1,
    "rminfolist.rminfo.accesstype": 1,
    "rminfolist.timestamp": 1,
    "locationlist.userlocation.nrlocation.tai": 1,
    "locationlist.userlocation.nrlocation.ncgi": 1
  }
));
print("SMF document for " + imsi + ":");
printjson(db.getCollectionNames().includes("smf") ? db.smf.findOne({_id: imsi}) : "SMF collection not available");
'
```

---

## Validate slice 2 UE

Slice 2 uses:

```text
UE: ueransim-ue4
IMSI: 001010000000200
DNN: oai2
SST: 2
Tunnel IP: 12.1.2.2
```

Check the UE in NWDAF:

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
const imsi = "imsi-001010000000200";
print("AMF document for " + imsi + ":");
printjson(db.amf.findOne(
  {_id: imsi},
  {
    _id: 1,
    "rminfolist.rminfo.rmstate.rmstateanyof": 1,
    "rminfolist.rminfo.accesstype": 1,
    "rminfolist.timestamp": 1,
    "locationlist.userlocation.nrlocation.tai": 1,
    "locationlist.userlocation.nrlocation.ncgi": 1
  }
));
print("SMF document for " + imsi + ":");
printjson(db.getCollectionNames().includes("smf") ? db.smf.findOne({_id: imsi}) : "SMF collection not available");
'
```

---

## Validate slice 3 UE

Slice 3 uses:

```text
UE: ueransim-ue5
IMSI: 001010000000300
DNN: oai3
SST: 3
Tunnel IP: 12.1.3.2
```

Check the UE in NWDAF:

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
const imsi = "imsi-001010000000300";
print("AMF document for " + imsi + ":");
printjson(db.amf.findOne(
  {_id: imsi},
  {
    _id: 1,
    "rminfolist.rminfo.rmstate.rmstateanyof": 1,
    "rminfolist.rminfo.accesstype": 1,
    "rminfolist.timestamp": 1,
    "locationlist.userlocation.nrlocation.tai": 1,
    "locationlist.userlocation.nrlocation.ncgi": 1
  }
));
print("SMF document for " + imsi + ":");
printjson(db.getCollectionNames().includes("smf") ? db.smf.findOne({_id: imsi}) : "SMF collection not available");
'
```

---

## Validate slice 4 UE

Slice 4 uses:

```text
UE: ueransim-ue6
IMSI: 001010000000400
DNN: oai4
SST: 2
Tunnel IP: 12.1.4.2
```

Check the UE in NWDAF:

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
const imsi = "imsi-001010000000400";
print("AMF document for " + imsi + ":");
printjson(db.amf.findOne(
  {_id: imsi},
  {
    _id: 1,
    "rminfolist.rminfo.rmstate.rmstateanyof": 1,
    "rminfolist.rminfo.accesstype": 1,
    "rminfolist.timestamp": 1,
    "locationlist.userlocation.nrlocation.tai": 1,
    "locationlist.userlocation.nrlocation.ncgi": 1
  }
));
print("SMF document for " + imsi + ":");
printjson(db.getCollectionNames().includes("smf") ? db.smf.findOne({_id: imsi}) : "SMF collection not available");
'
```

---

## Count UEs by slice IMSI range

Since the AMF collection mainly stores UE registration and location information, the easiest way to count UEs per slice in this setup is to use the IMSI ranges defined in the subscriber database.

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");
print("Slice 1 UEs in NWDAF:");
printjson(db.amf.countDocuments({_id: /^imsi-0010100000001/}));
print("Slice 2 UEs in NWDAF:");
printjson(db.amf.countDocuments({_id: /^imsi-0010100000002/}));
print("Slice 3 UEs in NWDAF:");
printjson(db.amf.countDocuments({_id: /^imsi-0010100000003/}));
print("Slice 4 UEs in NWDAF:");
printjson(db.amf.countDocuments({_id: /^imsi-0010100000004/}));
'
```

Expected result after deploying one UE per slice:

```text
Slice 1 UEs in NWDAF: 1
Slice 2 UEs in NWDAF: 1
Slice 3 UEs in NWDAF: 1
Slice 4 UEs in NWDAF: 1
```

---

## Query NWDAF Engine: number of UEs

The NWDAF Engine exposes a `NETWORK_PERFORMANCE` endpoint for the number of connected UEs.

First, check the NWDAF Engine service name:

```bash
kubectl get svc -n oai5g | grep nwdaf
```

Then query the engine with a temporary curl pod:

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never \
  --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8888/network_performance/num_of_ue \
  -H "Content-Type: application/json" \
  -d '{}'
```

Expected output example:

```json
{
  "absoluteNum": 4
}
```

The value depends on the number of UEs currently registered and stored in the NWDAF `amf` collection.

---

## Query NWDAF Engine: UE mobility

The NWDAF Engine exposes a `UE_MOBILITY` endpoint. This endpoint reads AMF location information for a given SUPI.

Example for slice 2:

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never \
  --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8888/ue_mobility \
  -H "Content-Type: application/json" \
  -d '{"supi":"imsi-001010000000200"}'
```

This should return the UE location information stored in the NWDAF AMF collection, such as TAI, PLMN, and NR cell information.

You can adapt the SUPI for each slice:

```text
Slice 1: imsi-001010000000100
Slice 2: imsi-001010000000200
Slice 3: imsi-001010000000300
Slice 4: imsi-001010000000400
```

---

## Query NWDAF Engine: PDU session information

The NWDAF Engine exposes a session-related endpoint through `NETWORK_PERFORMANCE` / `SESS_SUCC_RATIO`.

This endpoint uses the `smf` collection. If your `smf` collection is empty, the command will return `0`.

Example for slice 2:

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never \
  --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8888/network_performance/sess_succ_ratio \
  -H "Content-Type: application/json" \
  -d '{
    "dnns": ["oai2"],
    "snssaia": [
      {
        "sst": 2,
        "sd": "FFFFFF"
      }
    ]
  }'
```

Example for slice 3:

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never \
  --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8888/network_performance/sess_succ_ratio \
  -H "Content-Type: application/json" \
  -d '{
    "dnns": ["oai3"],
    "snssaia": [
      {
        "sst": 3,
        "sd": "FFFFFF"
      }
    ]
  }'
```

If the response is:

```json
{
  "absoluteNum": 0
}
```

it means that NWDAF currently has no SMF-side PDU session data in MongoDB. In that case, use the `amf` collection to validate UE registration, and use `ping`/`iperf3` to validate user-plane connectivity and throughput.

---

## Query NWDAF Engine: UE communication

The `UE_COMMUNICATION` endpoint uses SMF QoS monitoring data from the `smf` collection.

```bash
kubectl run nwdaf-curl -n oai5g --rm -i --restart=Never \
  --image=curlimages/curl -- \
  curl -s -X GET http://oai-nwdaf-engine:8888/ue_communication \
  -H "Content-Type: application/json" \
  -d '{}'
```

If the response contains zero values or fails because `qosmonlist` is missing, it means that the SMF-side QoS monitoring data is not currently being populated.

---

## Complete NWDAF validation command

The following command gives a compact overview of the NWDAF database state:

```bash
kubectl exec -it -n oai5g deploy/oai-nwdaf-database -- mongosh --quiet --eval '
use("testing");

print("==== Collections ====");
printjson(db.getCollectionNames());

print("==== Global counts ====");
print("AMF documents: " + db.amf.countDocuments());
print("SMF documents: " + (db.getCollectionNames().includes("smf") ? db.smf.countDocuments() : 0));

print("==== Registered UEs ====");
db.amf.find(
  {},
  {
    _id: 1,
    "rminfolist.rminfo.rmstate.rmstateanyof": 1,
    "rminfolist.rminfo.accesstype": 1
  }
).forEach(printjson);

print("==== Count per slice IMSI range ====");
print("Slice 1: " + db.amf.countDocuments({_id: /^imsi-0010100000001/}));
print("Slice 2: " + db.amf.countDocuments({_id: /^imsi-0010100000002/}));
print("Slice 3: " + db.amf.countDocuments({_id: /^imsi-0010100000003/}));
print("Slice 4: " + db.amf.countDocuments({_id: /^imsi-0010100000004/}));
'
```

---

## Interpretation

If the UE appears in the `amf` collection with `REGISTERED`, then the UE has been detected by the core network and NWDAF has received AMF-side information.

If the `smf` collection is empty, this does not necessarily mean that the UE failed. It means that SMF-side event exposure or QoS monitoring data is not currently being stored in NWDAF.

Therefore, in this deployment:

* `ping` validates basic user-plane connectivity.
* `iperf3` validates throughput and AMBR behavior.
* NWDAF `amf` collection validates UE registration and location visibility.
* NWDAF `smf` collection, when available, can validate PDU session and communication analytics.

---

## Example result

Example output:

```text
collections: [ 'amf' ]
amf count: 1
smf count: 0
_id: imsi-001010000000200
rmstate: REGISTERED
```

This means that NWDAF sees the UE `001010000000200` on the AMF side, so the slice 2 UE is registered.

However, because the `smf` collection is absent or empty, NWDAF cannot yet confirm PDU session, DNN, or traffic-related information from the SMF side.