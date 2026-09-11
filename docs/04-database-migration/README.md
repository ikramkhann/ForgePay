# ForgePay database migration reliability

## AI Attribution Block

AI-assisted database reliability implementation documentation. A human database owner must approve each migration plan and execution. Nothing in this directory asserts that PostgreSQL, backups, restores, migrations, or production controls have been run.

This directory implements the platform database-reliability foundation without changing the delivery architecture in `docs/01-pipeline-architecture/` or `deploy/`.

| Document | Purpose |
| --- | --- |
| [01-postgresql-16-architecture.md](01-postgresql-16-architecture.md) | PostgreSQL 16 reliability, recovery, safety and ownership boundaries |
| [02-expand-contract-lifecycle.md](02-expand-contract-lifecycle.md) | Required migration phases, ordering, compatibility matrix and lock-safe patterns |
| [03-database-deployment-gates.md](03-database-deployment-gates.md) | Database release gates aligned to build-once, GitOps and progressive delivery |
| [runbooks/production-migration.md](runbooks/production-migration.md) | Production execution procedure |
| [runbooks/database-rollback-recovery.md](runbooks/database-rollback-recovery.md) | Forward-fix, rollback, PITR and recovery decision procedure |

`database/` contains the machine-checkable migration-plan contract and a local validator. It deliberately contains no fabricated application schema migrations: no authoritative PostgreSQL schema or approved change request was supplied.
