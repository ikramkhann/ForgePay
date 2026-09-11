# Production migration runbook

## AI Attribution Block

AI-assisted runbook template. It must be completed with actual environment identifiers, approvals and observed results at execution time. It does not authorize or evidence a production migration.

## Preconditions

1. Confirm the change is an approved D1 expand/backfill/switch plan, not a contract, and validate it with `database/scripts/validate-migration-plan.sh`.
2. Record approved plan ID/checksum, source revision, signed image digest, GitOps revision, target environment, operator, database approver and recovery/incident owner in the change record.
3. Confirm A0/A1 compatibility using the matrix in [02-expand-contract-lifecycle.md](../02-expand-contract-lifecycle.md), including the currently stable and candidate rollout digests.
4. Confirm the designated platform owner has assessed current backup/PITR and restore-verification posture. Do not claim it is good without current evidence.
5. Run and review representative non-production lock, duration, WAL/capacity, resume and integrity tests. Obtain SRE/database approval for runtime guardrails.
6. Ensure a stable application revision remains available and no contract or incompatible deployment is in progress.

## Execute

1. Announce the approved change window and freeze conflicting schema changes.
2. Acquire the migration advisory lock and re-check target identity, schema preconditions and lock/statement timeout settings.
3. Apply the expand DDL. On timeout/error, stop and inspect catalog/locks before any retry.
4. Deploy or confirm the A1 compatible release only through the existing GitOps/ArgoCD process. Blue-green preview and canary both require A0/A1 coexistence to be safe.
5. Run bounded backfill batches. Commit each batch independently, persist only confirmed checkpoints, and pause on approved guardrail breach.
6. Run the approved integrity queries; validate constraints/index state and application dual-read/write behavior.
7. Switch reads only after validation and the approved observation period. Keep fallback code and D1 schema through the rollback window.
8. Record actual outcomes, including failures, pauses and retries. Do not mark a phase complete based solely on command submission.

## Stop criteria

Stop new work on unexpected lock waits, statement timeouts, blocked sessions, errors, data-invariant failures, index invalidity, unacceptable replication/WAL/disk/connection conditions, or rollout-analysis abort. Preserve diagnostics and checkpoint, retain D1 compatibility, and move to the recovery runbook; do not begin contract work.
