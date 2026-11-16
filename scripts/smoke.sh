#!/usr/bin/env sh
# Compose smoke test: signed-out redirect, then register -> OTP -> login -> OTP -> /auth/me -> dashboard with the session.
# Needs the stack from `make up` (mock OTP 112233). Usage: scripts/smoke.sh [base-url]
set -eu
BASE=${1:-http://localhost:8080}
JAR=$(mktemp)
trap 'rm -f "$JAR"' EXIT
EMAIL="smoke-$(date +%s)-$$@example.com"
PASSWORD='smoke-password-123'

fail() { echo "smoke: $*" >&2; exit 1; }
post() { curl -fsS -b "$JAR" -c "$JAR" -H 'Content-Type: application/json' -H "Origin: $BASE" -d "$2" "$BASE/api/v1$1"; }
challenge() { sed -n 's/.*"challengeId":"\([^"]*\)".*/\1/p'; }

curl -fsS "$BASE/api/health/ready" >/dev/null || fail "api is not ready"

location=$(curl -sS -o /dev/null -w '%{http_code} %{redirect_url}' "$BASE/")
case $location in
  30[278]\ */login*) ;;
  *) fail "signed-out / should redirect to /login, got: $location" ;;
esac
curl -fsS "$BASE/login" | grep -q 'Candidate Meeting Scheduler' || fail "/login did not render"

id=$(post /auth/register "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | challenge)
[ -n "$id" ] || fail "register returned no challengeId"
post /auth/otp/verify "{\"challengeId\":\"$id\",\"code\":\"112233\"}" >/dev/null

id=$(post /auth/login "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | challenge)
[ -n "$id" ] || fail "login returned no challengeId"
post /auth/otp/verify "{\"challengeId\":\"$id\",\"code\":\"112233\"}" >/dev/null

curl -fsS -b "$JAR" "$BASE/api/v1/auth/me" | grep -q '"user"' || fail "/auth/me did not return the user"
code=$(curl -sS -b "$JAR" -o /dev/null -w '%{http_code}' "$BASE/")
[ "$code" = 200 ] || fail "signed-in / should render the dashboard, got HTTP $code"
curl -fsS -b "$JAR" "$BASE/api/v1/meetings" | grep -q '"items"' || fail "meetings list failed with a session"

echo "smoke: ok"
