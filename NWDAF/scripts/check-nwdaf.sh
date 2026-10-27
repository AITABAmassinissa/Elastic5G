#!/usr/bin/env bash
# NWDAF end-to-end check for the 4-slice Elastic5G deployment (UPF-VPP core).
#
#   NWDAF/scripts/check-nwdaf.sh            # namespace oai5g
#   NS=my-ns NWDAF/scripts/check-nwdaf.sh
#
# 1. NWDAF pods are ready
# 2. MongoDB: UEs seen by the AMF (amf collection) and PDU sessions seen by the SMF (smf collection), per slice
# 3. NWDAF engine API (port 8080): num_of_ue, sess_succ_ratio per slice, ue_mobility of the slice-1 UE
# 4. 3GPP Nnwdaf_AnalyticsInfo API through the Kong gateway
# Exit code: 0 = all mandatory checks passed, 1 = at least one failed.
set -u

NS="${NS:-oai5g}"
DB="${NWDAF_DB:-testing}"
KUBECTL="${KUBECTL:-kubectl}"
FAIL=0

ok()   { printf '  [ OK ] %s\n' "$*"; }
ko()   { printf '  [FAIL] %s\n' "$*"; FAIL=1; }
warn() { printf '  [WARN] %s\n' "$*"; }
step() { printf '\n== %s\n' "$*"; }

# slice | DNN | SST | UE deployment | UE IMSI | IMSI prefix used to count the UEs of the slice
SLICES=(
  "1|oai|1|ueransim-ue3|imsi-001010000000102|imsi-0010100000001"
  "2|oaib|2|ueransim-ue4|imsi-001010000000200|imsi-0010100000002"
  "3|oaic|3|ueransim-ue5|imsi-001010000000300|imsi-0010100000003"
  "4|oaid|2|ueransim-ue6|imsi-001010000000400|imsi-0010100000004"
)

step "1. NWDAF pods (namespace $NS)"
for d in oai-nwdaf-database oai-nwdaf-sbi oai-nwdaf-engine oai-nwdaf-engine-ads \
         oai-nwdaf-nbi-analytics oai-nwdaf-nbi-events oai-nwdaf-nbi-ml oai-nwdaf-nbi-gateway; do
  ready=$($KUBECTL get deploy "$d" -n "$NS" -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  if [ "${ready:-0}" -ge 1 ] 2>/dev/null; then ok "$d ready"; else ko "$d not ready"; fi
done

step "2. MongoDB ($DB): AMF and SMF collections"
mongo_js='
const d = db.getSiblingDB("'"$DB"'");
const slices = [
  ["1","oai","imsi-0010100000001"],["2","oaib","imsi-0010100000002"],
  ["3","oaic","imsi-0010100000003"],["4","oaid","imsi-0010100000004"]];
print("AMF documents (all UEs): " + d.amf.countDocuments({}));
print("AMF REGISTERED: " + d.amf.countDocuments({"rminfolist.rminfo.rmstate.rmstateanyof": "REGISTERED"}));
print("SMF documents: " + d.smf.countDocuments({}));
slices.forEach(function (s) {
  print("slice " + s[0] + " amf=" + d.amf.countDocuments({_id: new RegExp("^" + s[2])}) +
        " smf_pdu_sessions(dnn " + s[1] + ")=" + d.smf.countDocuments({"pdusesestlist.dnn": s[1]}));
});'
mongo_out=$($KUBECTL exec -n "$NS" deploy/oai-nwdaf-database -- mongosh --quiet --eval "$mongo_js" 2>&1)
if [ $? -ne 0 ]; then ko "mongosh failed: $mongo_out"; else
  printf '%s\n' "$mongo_out" | sed 's/^/    /'
  amf_all=$(printf '%s\n' "$mongo_out" | sed -n 's/^AMF documents (all UEs): //p')
  if [ "${amf_all:-0}" -ge 1 ] 2>/dev/null; then ok "AMF events reach NWDAF ($amf_all UE documents)"; else ko "amf collection empty: no UE seen (see docs/NWDAF-slicing-validation.md, Troubleshooting)"; fi
  smf_all=$(printf '%s\n' "$mongo_out" | sed -n 's/^SMF documents: //p')
  if [ "${smf_all:-0}" -ge 1 ] 2>/dev/null; then ok "SMF events reach NWDAF ($smf_all documents)"; else warn "smf collection empty (only the SMF configured in oai-nwdaf-sbi, slice 1, is subscribed)"; fi
fi

step "3. NWDAF engine API (http://oai-nwdaf-engine:8080) and 4. Kong gateway"
# One temporary curl pod runs every query: each line is "label|http-code|body".
q='E=http://oai-nwdaf-engine:8080; G=http://oai-nwdaf-nbi-gateway
call() { r=$(curl -s -m 10 -w "|%{http_code}" "$@"); echo "$LABEL|${r##*|}|${r%|*}"; }
LABEL=engine_num_of_ue call -X GET $E/network_performance/num_of_ue -H "Content-Type: application/json" -d "{}"'
for s in "${SLICES[@]}"; do
  IFS='|' read -r n dnn sst _ imsi _ <<<"$s"
  q="$q
LABEL=engine_sess_succ_ratio_slice$n call -X GET \$E/network_performance/sess_succ_ratio -H \"Content-Type: application/json\" -d '{\"dnns\":[\"$dnn\"],\"snssaia\":[{\"sst\":$sst}]}'"
done
IFS='|' read -r _ _ _ _ imsi1 _ <<<"${SLICES[0]}"
q="$q
LABEL=engine_ue_mobility_slice1 call -X GET \$E/ue_mobility -H \"Content-Type: application/json\" -d '{\"supi\":\"$imsi1\"}'
LABEL=gateway_num_of_ue call -G \$G/nnwdaf-analyticsinfo/v1/analytics -H \"Host: oai-nwdaf-nbi-gateway\" --data-urlencode \"event-id=NETWORK_PERFORMANCE\" --data-urlencode 'event-filter={\"nwPerfTypes\":[\"NUM_OF_UE\"]}'
LABEL=gateway_ue_mobility_slice1 call -G \$G/nnwdaf-analyticsinfo/v1/analytics -H \"Host: oai-nwdaf-nbi-gateway\" --data-urlencode \"event-id=UE_MOBILITY\" --data-urlencode 'tgt-ue={\"supis\":[\"$imsi1\"]}'"
api_out=$($KUBECTL run "nwdaf-check-$$" -n "$NS" --rm -i --restart=Never --quiet \
  --image=curlimages/curl --command -- sh -c "$q" 2>&1)
if [ $? -ne 0 ]; then ko "curl pod failed: $api_out"; else
  # keep only the result lines: kubectl may print attach warnings around them
  api_out=$(printf '%s\n' "$api_out" | grep -E '^(engine|gateway)_[a-z0-9_]+\|')
  while IFS='|' read -r label code body; do
    [ -z "$label" ] && continue
    [ "${#body}" -gt 140 ] && body="${body:0:140}..."
    case "$label" in
      engine_sess_succ_ratio_*)
        # absoluteNum is omitted by the engine when it is 0, so "{}" means 0 PDU sessions
        if [ "$code" = 200 ]; then ok "$label -> $body"; else ko "$label HTTP $code $body"; fi ;;
      *)
        if [ "$code" = 200 ]; then ok "$label -> $body"; else ko "$label HTTP $code $body"; fi ;;
    esac
  done <<<"$api_out"
fi

echo
if [ "$FAIL" -eq 0 ]; then echo "NWDAF: all checks passed"; else echo "NWDAF: some checks failed"; fi
exit "$FAIL"
