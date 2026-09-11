# PostgreSQL 16 reliability architecture

## AI Attribution Block

AI-assisted target design. It is not evidence of a PostgreSQL cluster, replication, backup, restore test, metric, or production configuration.

## Scope and authority

PostgreSQL 16 is ForgePay's authoritative ACID store, as established by [ADR-004](../01-pipeline-architecture/adr/ADR-004-authoritative-data-and-transactional-outbox.md). Redis remains non-authoritative and RabbitMQ delivery remains idempotent and outbox-backed. This document defines database reliability expectations only; IAM design belongs to the Identity & Access Engineer and SLO thresholds, dashboards, and alert ownership belong to SRE.

## Target operational shape

Before production use, the database owner must select a managed PostgreSQL 16 offering or an equivalently operated topology with:

| Capability | Required outcome | Execution evidence required later |
| --- | --- | --- |
| Primary/write endpoint | One fenced writable primary behind a stable application endpoint | Provisioned topology and endpoint test |
| Replication/failover | At least one current failover candidate; never promote an unknown-lag replica | Scheduled, recorded failover drill |
| Connection protection | A pooler or managed proxy plus per-service connection caps and application backpressure | Load/connection-exhaustion test |
| Encryption and access | TLS in transit; storage encryption and least privilege under the security/IAM design | Security owner review |
| Capacity | Headroom for normal load, WAL, backfill and index builds | Capacity review with measured inputs |

Replication lag is a correctness gate: read-after-write flows must not be routed to a replica whose freshness is outside the application’s approved bound, and a failover candidate must be assessed for lag before promotion. The exact replication mode, RPO, RTO, backup provider, retention and cross-region arrangement are unresolved business and platform decisions; no target numbers are asserted here.

## Backup and restore expectations

The selected platform must provide base backups plus continuous WAL archiving sufficient for point-in-time recovery (PITR) within the agreed retention. A backup is not accepted as recoverability evidence until a scheduled restore verification has restored it to an isolated instance, replayed WAL to a chosen point, run approved integrity checks, and recorded its measured duration.

Restore verification must not use production credentials or expose production data outside an approved isolated boundary. Its acceptance criteria (RPO/RTO, retention, scope, redaction and evidence retention) require business, security and SRE approval. This project has not executed a backup or restore test.

## Transaction and lock discipline

- Every application change that writes financial state and an outbox record keeps both in one PostgreSQL transaction.
- Migrations use a dedicated migration connection, an advisory lock, bounded statement/lock timeouts and a traceable migration identifier.
- One transaction is used for a small atomic metadata change; a large backfill, `CREATE INDEX CONCURRENTLY`, or validation is never wrapped in a long transaction.
- `CREATE INDEX CONCURRENTLY` cannot run inside a transaction block and may leave an invalid index after interruption; it must be checked and remediated explicitly.
- Avoid table rewrites, unbounded updates, long transactions, `ALTER ... SET NOT NULL` on hot tables, and DDL requiring strong locks during serving hours. Test actual lock behavior and query plans against production-like size before approval.

## Data integrity and migration telemetry

Each approved migration defines its own deterministic validation query or invariant: for example, old/new column equality, orphan count of zero, checksum/count reconciliation, constraint validity, and application error-free dual reads. Do not substitute invented row counts or sample data for this validation.

The migration executor must emit structured, redacted records containing migration ID, release digest/revision, phase, batch range or count, duration, retry/error classification, lock wait, rows affected and validation outcome. Database-side collection should make available lock waits, blocked sessions, long transactions, connection utilisation, replication lag, WAL/disk pressure, backup age and most recent restore-verification status. Thresholds and alert routes remain SRE-owned.
