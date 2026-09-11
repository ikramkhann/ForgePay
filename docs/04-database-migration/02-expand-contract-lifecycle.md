# Zero-downtime expand-contract lifecycle

## AI Attribution Block

AI-assisted migration process design. It is not an executed migration, a guarantee of lock behavior, or evidence of application/database compatibility in any environment.

## Mandatory ordering

1. **Plan and preflight:** create a reviewed plan in the `database/migration-plan.schema.json` format; identify affected tables, lock behavior, rollback point, integrity invariant, batch strategy, app versions, and expected WAL/capacity impact.
2. **Expand:** apply only backward-compatible additive schema changes (nullable column, new table, additive index). No old application must fail after this change.
3. **Compatible application:** deploy code that can read old and new forms and, when required, dual-writes atomically. This occurs through the existing signed-digest → reviewed GitOps → ArgoCD rollout flow.
4. **Backfill:** resume-safe, bounded batches with rate limiting and explicit validation. New writes are covered by compatible code while historical rows are updated.
5. **Validate and switch:** prove the migration invariant, then switch reads only after the required compatibility/observation window. Retain fallback reads until explicitly approved.
6. **Contract:** only after the oldest rollback-eligible application digest is no longer deployable and data-retention/restore decisions are approved. Remove old code before destructive schema removal; use a later release.

The contract phase must never be bundled with expand or the application rollout it enables.

## Compatibility matrix

`A0` is the current/stable application; `A1` is the compatible release; `A2` is the post-contract release. `D0` is the original schema; `D1` is expanded schema; `D2` is the contracted schema.

| Database phase | Allowed application versions | Safe coexistence | Rollback consequence |
| --- | --- | --- | --- |
| D0 — before expand | A0 | A0 + D0 | Normal application digest rollback |
| D1 — expanded, before A1 | A0, A1 | A0 tolerates additive objects; A1 must tolerate absent backfill data | Revert A1 to A0; leave D1 in place |
| D1 — dual-write/backfill/switch | A0, A1 | A1 reads fallback old/new and dual-writes; A0 continues old path | Abort blue-green/canary to A0; do not remove D1 or backfilled data |
| D1 — post-switch compatibility window | A0, A1 | A1 must retain backward reads/writes until A0 is outside rollback window | Revert A1 to A0 remains safe; forward-fix migration data if needed |
| D2 — contract complete | A2 only | A0/A1 are **not** eligible unless proven D2-compatible in a separately approved plan | Application rollback is not automatic; use forward fix or recovery decision |

Blue-green keeps stable and preview revisions live simultaneously; canary keeps stable and canary revisions live simultaneously. Therefore either strategy is allowed only in the D1 rows where A0 and A1 coexist safely. A D2 contract cannot begin while a rollout controller could return traffic to A0/A1.

## Expand patterns and lock safety

For PostgreSQL 16, prefer additive, metadata-light DDL. A migration plan must still state the expected lock and be tested; "safe" is not inferred from a generic pattern.

```sql
-- Example pattern only; table/column names must be supplied by an approved change.
SET lock_timeout = '5s';
SET statement_timeout = '30s';
ALTER TABLE target ADD COLUMN new_value text; -- nullable, no volatile default

-- Run outside a transaction block and monitor to completion.
CREATE INDEX CONCURRENTLY IF NOT EXISTS target_new_value_idx ON target (new_value);

-- Establish a constraint without a long blocking validation step.
ALTER TABLE target ADD CONSTRAINT target_new_value_present
  CHECK (new_value IS NOT NULL) NOT VALID;
ALTER TABLE target VALIDATE CONSTRAINT target_new_value_present;
```

`lock_timeout` fails rather than queues behind a long blocker. `statement_timeout` bounds an individual operation; migration tooling must distinguish a timeout from a committed change and re-check catalog state before retrying. The example is intentionally not a runnable ForgePay migration.

## Backfill strategy

Backfills must be idempotent and resumable. Use a stable key/range or `FOR UPDATE SKIP LOCKED` work claim, update a bounded number of rows per committed batch, record a checkpoint only after that batch commits, and throttle/pause when lock waits, replication/WAL/disk pressure, error rate, or database-owner guardrails require it. Every batch uses short transactions; never hold a transaction across the entire data set.

New application writes must populate both representations before the historical backfill begins if needed. A retry starts from an acknowledged checkpoint or repeats an idempotent predicate such as `WHERE new_value IS NULL`; it must not assume an interrupted command rolled back without checking.

## Contract and rollback decision points

| Decision point | Required action |
| --- | --- |
| Expand cannot acquire its lock in the approved timeout | Abort before change; resolve blocker and re-plan. |
| A1 rollout/analysis fails during D1 | Argo Rollouts aborts application traffic to stable digest; retain D1 and use old path. |
| Backfill fails or guardrail breaches | Stop scheduling batches, preserve checkpoint, investigate; retry only after catalog/data validation. |
| Data invariant fails | Stop switch/contract; retain dual-read/dual-write compatibility and choose a forward data correction. |
| Contract is proposed | Verify no eligible rollback digest uses old schema, backup/recovery decision is approved, and retention obligations are met. |
| Contract fails after destructive work | Do not blindly rerun or restore. Stop, assess blast radius, then choose approved forward fix, controlled restore/PITR, or incident response. |

Destructive schema changes and data deletion are not automatically reversible. A restore/PITR decision affects later valid writes and must be approved by the designated incident/data owners.
