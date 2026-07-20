#!/usr/bin/env bash

# 오류와 정의되지 않은 변수를 엄격하게 처리한다.
set -Eeuo pipefail

# 첫 번째 인자는 Source Directory다.
SITE_DIR="${1:-migration/source-site}"

# 두 번째 인자는 Build Output Directory다.
OUTPUT_DIR="${2:-dist}"

fail() {
    echo "[FAIL] $*" >&2
    exit 1
}

echo "Static Site Build"
echo "Source: ${SITE_DIR}"
echo "Output: ${OUTPUT_DIR}"
echo "--------------------------------"

# Build 전에 Source 파일이 존재하는지 다시 확인한다.
[[ -s "${SITE_DIR}/index.html" ]] \
    || fail "index.html is missing or empty"

[[ -s "${SITE_DIR}/health.txt" ]] \
    || fail "health.txt is missing or empty"

# GitHub Actions에서는 GITHUB_SHA 환경변수를 Version으로 사용한다.
# WSL에서는 현재 Git Commit의 짧은 SHA를 사용한다.
if [[ -n "${GITHUB_SHA:-}" ]]; then
    VERSION="${GITHUB_SHA:0:12}"
else
    VERSION="$(
        git rev-parse --short=12 HEAD 2>/dev/null \
        || date -u +%Y%m%d%H%M%S
    )"
fi

ARCHIVE_NAME="static-site-${VERSION}.tar.gz"

# 이전 Build 결과가 섞이지 않도록 Output Directory를 다시 만든다.
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Source Directory 안에서 배포할 두 파일만 Archive에 포함한다.
tar -czf "${OUTPUT_DIR}/${ARCHIVE_NAME}" \
    -C "$SITE_DIR" \
    index.html \
    health.txt

# Output Directory 안에서 Checksum 파일을 생성하고 즉시 검증한다.
(
    cd "$OUTPUT_DIR"

    sha256sum "$ARCHIVE_NAME" \
        > "${ARCHIVE_NAME}.sha256"

    sha256sum -c "${ARCHIVE_NAME}.sha256"
)

# 어떤 Commit에서 Build됐는지 확인할 정보 파일을 만든다.
{
    echo "version=${VERSION}"
    echo "commit=${GITHUB_SHA:-$(git rev-parse HEAD 2>/dev/null || echo unknown)}"
    echo "built_at_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
} > "${OUTPUT_DIR}/build-info.txt"

echo
echo "Archive contents:"

tar -tzf "${OUTPUT_DIR}/${ARCHIVE_NAME}"
# Archive를 풀지 않고 내부 파일 목록을 출력한다.

echo
echo "Build outputs:"

ls -lh "$OUTPUT_DIR"
# 생성된 Package, Checksum과 Build 정보 파일을 출력한다.

echo "--------------------------------"
echo "RESULT: BUILD SUCCESS"
exit 0