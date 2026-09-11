#!/usr/bin/env bash
# AI Attribution Block: AI-assisted GitOps mutation helper; it changes only an overlay's image field.
set -euo pipefail

environment="${1:?environment is required}"
image="${2:?image repository is required}"
digest="${3:?image digest is required}"
overlay="deploy/gitops/environments/${environment}"

case "$environment" in dev|staging|production) ;; *) echo "unsupported environment" >&2; exit 2 ;; esac
[[ "$digest" =~ ^sha256:[a-f0-9]{64}$ ]] || { echo "digest must be a lowercase sha256 digest" >&2; exit 2; }
test -f "$overlay/kustomization.yaml"
command -v kustomize >/dev/null

(cd "$overlay" && kustomize edit set image "REQUIRED_IMAGE_REFERENCE=${image}@${digest}")
