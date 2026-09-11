#!/usr/bin/env bash
# AI Attribution Block: AI-assisted post-deployment smoke test script.
set -euo pipefail

TARGET_HOST="${1:-http://localhost:8080}"
echo "Running post-deployment smoke verification against ${TARGET_HOST}..."

# 1. Health check
echo -n "Checking /actuator/health... "
HEALTH_STATUS=$(curl -fsS "${TARGET_HOST}/actuator/health" | grep -o '"status":"UP"' || true)
if [ -n "${HEALTH_STATUS}" ]; then
  echo "OK"
else
  echo "FAILED"
  exit 1
fi

# 2. Metrics endpoint check
echo -n "Checking Prometheus /actuator/prometheus... "
curl -fsS "${TARGET_HOST}/actuator/prometheus" | grep -q "jvm_memory_used_bytes"
echo "OK"

# 3. Read-only API verification
echo -n "Checking Accounts API /api/v1/accounts/health... "
curl -fsS "${TARGET_HOST}/api/v1/accounts/health" > /dev/null
echo "OK"

echo "All smoke tests passed successfully."
