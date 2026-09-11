# ADR-003: Use progressive delivery with expand-contract schema compatibility

## AI Attribution Block

AI-assisted architecture decision draft. It is proposed design rationale, not implementation, deployment, compliance, or runtime evidence; human approval is required before adoption.

## Status

Proposed

## Context

Blue-green and canary releases require reliable application reversal. Database schema changes can make a traffic rollback unsafe if old code cannot use the new schema.

## Decision

Use blue-green for ready-standby promotion and canary for stepwise exposure. Release candidates must be backward-compatible with the current schema. Database changes use expand, compatible deployment, bounded backfill, validation, switch, and delayed contract phases.

## Consequences

Application rollback can return to the stable digest during the compatibility window. Schema evolution takes more releases and may temporarily require dual reads/writes. Destructive rollback is intentionally not automated.
