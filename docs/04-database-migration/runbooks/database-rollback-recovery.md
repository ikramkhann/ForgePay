# Database rollback and recovery runbook

## AI Attribution Block

AI-assisted runbook template. It is not a tested recovery plan, a performed restore, or evidence of any RPO/RTO. A human incident/data owner must authorize irreversible recovery actions.

## Decision sequence

1. Stabilize: stop the migration/backfill scheduler, retain evidence, identify the exact plan/phase/checkpoint and prevent conflicting schema changes.
2. If the database is D1, prefer application rollback through the existing reviewed GitOps revert to A0. Do not drop D1 objects or undo committed backfill merely because traffic was rolled back.
3. If data is inconsistent but schema compatibility remains, choose an approved, tested forward correction and re-run the integrity validation. This is normally safer than destructive reversal.
4. If a concurrent index build failed, inspect its catalog validity. Drop/rebuild only under an approved follow-up plan; do not assume `IF NOT EXISTS` makes an invalid index usable.
5. If contract/destructive work occurred, stop and assess affected writes, data loss exposure, legal/retention obligations and recovery point. Escalate to the data/incident owners before any restore.
6. Restore/PITR is a last-resort decision. Restore to an isolated target first, validate approved integrity checks, compare expected recovered point with the approved RPO, and plan how valid post-recovery writes are reconciled. Only the authorized owner may cut over.

## Required recovery record

Capture actual timestamps, plan ID, operator/approvers, phase, target identity, errors, executed SQL checksums, affected checkpoint/range, chosen path, integrity results, recovery-point assessment, application/GitOps revision and follow-up actions. Unknown or missing evidence is recorded as unknown, not inferred.

## Post-incident

Do not resume the original plan until the database owner approves a revised plan. Schedule a restore/failover drill if the incident exposed an untested assumption; record measured results only after the drill is executed.
