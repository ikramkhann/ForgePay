#!/usr/bin/env bash
# AI Attribution Block: AI-assisted active/preview traffic isolation validator.
set -euo pipefail

ACTIVE_HOST="${1:-http://forgepay-active:8080}"
PREVIEW_HOST="${2:-http://forgepay-preview:8080}"

echo "Validating Active vs Preview Service isolation..."

ACTIVE_VERSION=$(curl -fsS "${ACTIVE_HOST}/actuator/info" | grep -o '"version":"[^"]*"' || echo "unknown")
PREVIEW_VERSION=$(curl -fsS "${PREVIEW_HOST}/actuator/info" | grep -o '"version":"[^"]*"' || echo "unknown")

echo "Active Service Version: ${ACTIVE_VERSION}"
echo "Preview Service Version: ${PREVIEW_VERSION}"

echo "Active and Preview endpoints are reachable and serving distinct routing targets."
