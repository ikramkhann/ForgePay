# ForgePay delivery foundation

## AI Attribution Block

AI-assisted implementation foundation. These files define desired state and validation gates; they do not evidence a registry, cluster, ArgoCD installation, scan, deployment, rollback, or compliance outcome.

`helm/forgepay` is the shared package. `gitops/base` renders it, and the three environment overlays add only environment-specific values and immutable-image substitution. ArgoCD must point at a reviewed Git repository/path containing an overlay; application templates are provided under `argocd/` because no repository URL or cluster registration was supplied.

The image placeholder is deliberately not a real registry location. The promotion workflow replaces it only after Cosign verification of a supplied digest. Configure protected branches and GitHub Environments so staging and production pull requests require an approver who did not author the source change.

The rollout analysis checks application health and aborts on failure. Error, latency, saturation, and synthetic-check thresholds are defined by the SRE phase in `helm/forgepay/values.yaml` (`observability.releaseAnalysis`) and enforced via `helm/forgepay/templates/analysis-template.yaml` and `pipeline/observability/release-verification.yaml`.
