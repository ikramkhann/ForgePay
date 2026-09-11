#!/usr/bin/env bash
# AI Attribution Block: AI-assisted static plan validator. It does not connect to or alter PostgreSQL.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 database/plans/<migration>.json" >&2
  exit 64
fi

plan="$1"
schema="database/migration-plan.schema.json"
[[ -f "$plan" ]] || { echo "migration plan not found: $plan" >&2; exit 66; }
[[ -f "$schema" ]] || { echo "schema not found: $schema" >&2; exit 66; }

if command -v ajv >/dev/null 2>&1; then
  ajv validate --spec=draft2020 -s "$schema" -d "$plan"
elif command -v npx >/dev/null 2>&1; then
  npx --yes ajv-cli validate --spec=draft2020 -s "$schema" -d "$plan"
else
  echo "ajv-cli is required to validate migration plans (install it or run via npx)." >&2
  exit 69
fi

echo "Migration plan structure is valid: $plan"
