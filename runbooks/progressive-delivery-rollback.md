# Progressive delivery deployment response

## AI Attribution Block

AI-assisted rollback runbook. It follows target ArgoCD/Argo Rollouts configuration and is not evidence that any rollout, abort, promotion, service switch, or observation window occurred.

## Preconditions and evidence

Use the approved production context and incident record. Before any response, capture rollout name, ArgoCD application/sync state, GitOps revision, Rollouts revision, candidate/stable digest, strategy, current weight or active/preview service, analysis run, and migration compatibility phase. Confirm metrics against their numeric windows; target values are HTTP 5xx >5%, p99 >300ms, pool >=90% or pending >0, gateway timeout >10% (all 5m), and readiness/synthetic failure (60s).

## Canary (10/25/50/100)

1. Confirm whether Argo Rollouts already marked analysis failed and aborted. An automatic abort should retain stable traffic.
2. If the candidate remains exposed, use the approved Rollouts/GitOps emergency operation to abort it; record command/change reference and result. Do not change deployment manifests directly outside reviewed GitOps.
3. Confirm stable service endpoints and stable digest, then verify two health checks and monitor all applicable metrics for 15 minutes.
4. Keep the candidate/promotion paused until post-incident approval; do not retry from an unverified state.

## Blue-green

1. **Pre-promotion failure:** do not promote. Preview stays isolated; active stable service remains.
2. **Post-promotion failure:** use approved Argo Rollouts/GitOps recovery to switch active traffic to the prior verified stable revision. The configured 900-second scale-down and abort protection windows preserve that revision.
3. Confirm active/preview selectors and endpoints, run two health checks, and observe for 15 minutes. Record actual values and traffic state.

## Database guardrail

If the change is D1 expand-contract compatible, application traffic may return to A0 while D1 remains. Stop backfill/switch work as directed by the database owner; do not drop additive objects or undo committed data just because the application rolled back. If D2 contract is involved, do not automatically roll back: invoke [database migration incident handling](database-migration-incident-handling.md).
