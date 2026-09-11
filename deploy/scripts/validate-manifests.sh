#!/usr/bin/env bash
# AI Attribution Block: AI-assisted local structural validation; it performs no deployment.
set -euo pipefail

command -v helm >/dev/null
command -v kustomize >/dev/null

helm lint deploy/helm/forgepay
for environment in dev staging production; do
  kustomize build --enable-helm "deploy/gitops/environments/${environment}" >/dev/null
done
