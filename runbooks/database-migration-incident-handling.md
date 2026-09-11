# Database migration incident handling

## AI Attribution Block

AI-assisted incident runbook. It complements, but does not replace, the approved expand-contract migration plan or database-owner authority. No migration, recovery, restore, or data correction is claimed to have occurred.

## Trigger and containment

Invoke for a failed migration/backfill/invariant, a pool condition correlated with a release, or any suspected data-integrity impact. Declare/upgrade severity per impact, stop migration/backfill scheduling, freeze conflicting promotions, preserve plan ID, phase, checkpoint, SQL checksum, and redacted error evidence. Do not infer a failed statement rolled back: inspect approved catalog/integrity checks.

## Expand-contract decisions

| Phase | Incident response |
| --- | --- |
| D0 | application rollback follows normal approved GitOps/Rollouts procedure |
| D1 expand/dual-write/backfill/switch | abort candidate to A0 if compatible; retain D1 and committed backfill; pause batch scheduling; database owner selects forward correction after validation |
| D1 post-switch compatibility window | preserve backward reads/writes; A0 remains rollback-eligible; do not contract |
| D2 contract/destructive work | stop; no automatic application/schema rollback; database and incident owners assess blast radius, legal/retention implications, approved forward fix or isolated restore/PITR decision |

## Recovery evidence and compliance

Record actual timestamps, operators/approvers, migration plan and phase, environment/target identity, GitOps and immutable image revisions, checkpoint/range, executed SQL checksums, errors, integrity checks, potential data impact, chosen recovery path, and approval references. Preserve according to approved audit retention; restrict evidence to authorized personnel and exclude PAN, secrets, credentials, and raw payment payloads. A restore/PITR is last resort: restore isolated, validate integrity, assess valid writes after recovery point, and obtain approved cutover authority.

Use the detailed [database rollback and recovery runbook](../docs/04-database-migration/runbooks/database-rollback-recovery.md) before any irreversible action.
