#!/usr/bin/env bash

# 명령 실패, 정의되지 않은 변수, Pipeline 중간 실패를 엄격하게 처리한다.
set -Eeuo pipefail

# 첫 번째 인자가 있으면 검사 대상 Directory로 사용한다.
# 인자가 없다면 기존 Migration Source Directory를 기본값으로 사용한다.
SITE_DIR="${1:-migration/source-site}"

# 임시 HTTP Server가 사용할 Port다.
# 환경변수가 없으면 18080을 사용한다.
PORT="${CI_TEST_PORT:-18080}"

# CI에서 정상으로 인정할 기대값이다.
EXPECTED_TITLE='<title>WSL to AWS EC2 Migration Lab</title>'
EXPECTED_HEALTH='OK - migrated from WSL to AWS EC2'

# 실패 메시지를 출력하고 Exit Code 1로 종료한다.
fail() {
    echo "[FAIL] $*" >&2
    exit 1
}

# 성공한 검사 항목을 보기 좋게 출력한다.
pass() {
    echo "[OK] $*"
}

echo "Static Site Validation"
echo "Source: ${SITE_DIR}"
echo "--------------------------------"

# 검사 대상 Directory가 실제로 존재하는지 확인한다.
[[ -d "$SITE_DIR" ]] \
    || fail "Source directory not found: ${SITE_DIR}"

pass "Source directory exists"

# index.html이 존재하며 크기가 0보다 큰지 확인한다.
[[ -s "${SITE_DIR}/index.html" ]] \
    || fail "index.html is missing or empty"

pass "index.html exists"

# health.txt가 존재하며 크기가 0보다 큰지 확인한다.
[[ -s "${SITE_DIR}/health.txt" ]] \
    || fail "health.txt is missing or empty"

pass "health.txt exists"

# HTML Title이 기대한 값과 일치하는지 확인한다.
grep -Fq "$EXPECTED_TITLE" "${SITE_DIR}/index.html" \
    || fail "Expected HTML title was not found"

pass "Expected HTML title found"

# 줄바꿈 차이로 비교가 실패하지 않도록 CR·LF 문자를 제거한다.
HEALTH_BODY="$(
    tr -d '\r\n' < "${SITE_DIR}/health.txt"
)"

# health.txt의 내용이 기대 문자열과 정확히 같은지 확인한다.
[[ "$HEALTH_BODY" == "$EXPECTED_HEALTH" ]] \
    || fail "Unexpected health content: ${HEALTH_BODY:-<empty>}"

pass "health.txt content matched"

# 임시 HTTP Server의 로그를 저장할 임시 파일을 만든다.
SERVER_LOG="$(mktemp)"

# Python 내장 HTTP Server를 Background에서 실행한다.
# GitHub Runner와 WSL 모두 별도의 Web Server 설치 없이 사용할 수 있다.
python3 -m http.server "$PORT" \
    --bind 127.0.0.1 \
    --directory "$SITE_DIR" \
    > "$SERVER_LOG" 2>&1 &

SERVER_PID=$!

# Script가 성공하거나 실패해도 임시 Server가 남지 않도록 종료 처리한다.
cleanup() {
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
    rm -f "$SERVER_LOG"
}

trap cleanup EXIT

# Server Process가 Port를 열 때까지 최대 약 4초간 기다린다.
SERVER_READY=0

for _ in {1..20}; do
    if curl -fsS --max-time 1 \
        "http://127.0.0.1:${PORT}/" \
        > /dev/null; then

        SERVER_READY=1
        break
    fi

    sleep 0.2
done

# 제한 시간 안에 HTTP 응답이 없으면 Server Log와 함께 실패 처리한다.
if (( SERVER_READY != 1 )); then
    cat "$SERVER_LOG"
    fail "Temporary HTTP server did not become ready"
fi

pass "Temporary HTTP server started"

# HTTP로 받은 index.html 본문을 변수에 저장한다.
INDEX_HTTP_BODY="$(
    curl -fsS --max-time 2 \
        "http://127.0.0.1:${PORT}/"
)"

# 파일 자체뿐 아니라 실제 HTTP 응답에도 기대 Title이 있는지 확인한다.
grep -Fq "$EXPECTED_TITLE" <<< "$INDEX_HTTP_BODY" \
    || fail "Expected title was not found in HTTP response"

pass "HTTP / response validated"

# HTTP로 받은 health.txt에서 줄바꿈을 제거한다.
HEALTH_HTTP_BODY="$(
    curl -fsS --max-time 2 \
        "http://127.0.0.1:${PORT}/health.txt" \
        | tr -d '\r\n'
)"

# HTTP Endpoint가 기대한 Health 문자열을 반환하는지 확인한다.
[[ "$HEALTH_HTTP_BODY" == "$EXPECTED_HEALTH" ]] \
    || fail "Unexpected HTTP health response"

pass "HTTP /health.txt response validated"

echo "--------------------------------"
echo "RESULT: VALID"
exit 0