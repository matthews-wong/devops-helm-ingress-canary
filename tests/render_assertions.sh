#!/usr/bin/env bash
# The canary must be fully switchable and must never share a Service with stable.
set -euo pipefail

CHART="$(dirname "$0")/../chart"

render() {
  helm template t "$CHART" "$@"
}

fail() {
  echo "FAIL: $1"
  exit 1
}

count() {
  grep -c "^kind: $1" <<<"$2" || true
}

off="$(render)"
on="$(render --set canary.enabled=true)"

for kind in Deployment Service Ingress; do
  [[ "$(count "$kind" "$off")" == 1 ]] || fail "expected 1 $kind with canary disabled"
  [[ "$(count "$kind" "$on")" == 2 ]] || fail "expected 2 ${kind}s with canary enabled"
done
echo "ok:   canary resources appear only when enabled"

grep -q 'nginx.ingress.kubernetes.io/canary' <<<"$off" && fail "canary annotation rendered while disabled"
grep -q 'canary-weight: "10"' <<<"$on" || fail "default canary weight 10 not rendered"
grep -q 'canary-weight: "25"' <<<"$(render --set canary.enabled=true --set canary.weight=25)" \
  || fail "canary.weight override not rendered"
echo "ok:   canary weight follows values"

selectors="$(render --set canary.enabled=true --show-only templates/service.yaml \
  | awk '/^  selector:/ {in_sel=1; next} /^  ports:/ {in_sel=0} in_sel')"
for track in stable canary; do
  [[ "$(grep -c "component: $track" <<<"$selectors")" == 1 ]] || fail "expected one Service selecting $track"
done
echo "ok:   each Service selects exactly one track"
