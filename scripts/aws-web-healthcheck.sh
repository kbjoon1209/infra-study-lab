#!/usr/bin/env bash

# 정의되지 않은 변수를 사용하면 오류로 처리한다.
# 변수명 오타를 조기에 발견하는 데 도움이 된다.
set -u

# Script 실행 시 첫 번째로 전달된 값을 EC2 Public IP로 사용한다.
# 인자가 없으면 빈 문자열을 사용한다.
TARGET_IP="${1:-}"

# Public IP가 전달되지 않았다면 사용법을 출력하고 종료한다.
if [[ -z "$TARGET_IP" ]]; then
    echo "Usage: $0 <EC2_PUBLIC_IP>"
    exit 2
fi

# 여러 curl 명령에서 반복해서 사용할 기본 URL을 생성한다.
BASE_URL="http://${TARGET_IP}"

# 실패 횟수를 저장할 변수다.
FAIL_COUNT=0

echo "Target: ${BASE_URL}"
echo "--------------------------------"

# 기본 페이지에 HTTP 요청을 보낸다.
# -f : HTTP 400·500번대 응답을 실패로 처리
# -s : 진행률 등의 불필요한 출력 숨김
# -S : 실패했을 때 오류 메시지는 출력
# --max-time 5 : 최대 5초까지만 대기
if curl -fsS --max-time 5 "${BASE_URL}/" > /dev/null; then
    echo "[OK] / : HTTP request succeeded"
else
    echo "[FAIL] / : HTTP request failed"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# health.txt의 내용을 변수에 저장한다.
# curl이 실패할 경우 Script 전체가 즉시 종료되지 않도록 || true를 사용한다.
HEALTH_BODY=$(
    curl -fsS --max-time 5 "${BASE_URL}/health.txt" 2>/dev/null || true
)

# health.txt가 기대한 문자열과 같은지 확인한다.
if [[ "$HEALTH_BODY" == "OK - migrated from WSL to AWS EC2" ]]; then
    echo "[OK] /health.txt : expected content found"
else
    echo "[FAIL] /health.txt : unexpected or missing content"
    echo "Received: ${HEALTH_BODY:-<empty>}"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo "--------------------------------"

# 실패가 하나도 없다면 Exit Code 0으로 종료한다.
if (( FAIL_COUNT == 0 )); then
    echo "RESULT: HEALTHY"
    exit 0
fi

# 한 개 이상 실패했다면 Exit Code 1로 종료한다.
echo "RESULT: UNHEALTHY"
exit 1