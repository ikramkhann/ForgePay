# Database-related delivery gates

## AI Attribution Block

AI-assisted gate design. These gates are requirements for future configured workflows and environments, not evidence that a database migration, scan, deployment, backup, or verification has occurred.

## Alignment with existing CI/CD

GitHub Actions still builds the application once and signs one immutable digest. The promotion workflow still changes only an environment GitOps overlay, and ArgoCD remains the deployer. Database migration approval does not authorize image rebuilding, direct cluster deployment, or a bypass of GitOps. A migration plan must bind to the source revision and release digest it supports.

| Existing stage | Database requirement before it may pass | External execution status |
| --- | --- | --- |
| 2 Build | Validate the migration-plan JSON for any changed plan; application tests compile with both compatibility paths | Not configured in this repository |
| 5 Integration/contract testing | Run approved expanded-schema compatibility and backfill-resume tests against disposable PostgreSQL 16 | Requires migrations, test harness and CI wiring |
| 7 Policy/compliance | Reject a changed migration plan lacking lifecycle, invariant, rollback, compatibility, timeout and approval fields | Local validator supplied; CI wiring not added |
| Promotion | Link the exact approved plan ID, signed image digest and destination; production requires an authorized database approver | Requires GitHub environment/ruleset configuration |
| 8 Deployment/verification | Execute only approved expand/backfill/switch work through the approved migration executor; record outcome; ArgoCD rollout analysis must pass | Requires real PostgreSQL and executor identity |
| Contract | Separate, later change only after rollback-window confirmation and recovery approval | Requires human approval and real environment |

The CI workflow currently has no application migration directory, migration runner, or external PostgreSQL credentials. This foundation deliberately does not add a false CI job that appears to migrate an unknown database.

## Required preflight and runtime gates

Before an execution, the database owner must approve: target identity/environment, plan ID/version, SQL checksum, release digest, compatible app versions, lock and statement limits, expected capacity/WAL impact, backup/PITR posture, integrity queries, stop conditions and recovery owner. Runtime gates require no active incompatible rollout; advisory-lock acquisition; catalog precondition checks; acceptable database health according to SRE-owned thresholds; a valid current backup/restore-verification posture; and a dry run on representative non-production data.

After each phase, capture actual (not invented) output: migration ID, timestamps, schema version, batch checkpoint, validation query result, failure/rollback choice and change approval references. Production promotion is blocked if these required records are absent; this is a future operational control, not current evidence.
