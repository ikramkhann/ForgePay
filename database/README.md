# Database implementation artifacts

## AI Attribution Block

AI-assisted implementation foundation. This directory contains validation tooling, not executed schema changes or database evidence.

Add a reviewed JSON plan per actual migration under `database/plans/` and validate it before review or CI integration:

```bash
bash database/scripts/validate-migration-plan.sh database/plans/<migration>.json
```

The validator checks planning completeness only. It cannot prove SQL behavior, credentials, backup state, database health, execution approval, or compatibility; those require a real PostgreSQL 16 environment and human review.
