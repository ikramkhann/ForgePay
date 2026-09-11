# ADR-004: Keep PostgreSQL authoritative and publish through a transactional outbox

## AI Attribution Block

AI-assisted architecture decision draft. It is proposed design rationale, not implementation, deployment, compliance, or runtime evidence; human approval is required before adoption.

## Status

Proposed

## Context

Financial state requires strong transactional correctness while notifications and downstream work benefit from asynchronous delivery. Redis and RabbitMQ cannot substitute for an ACID system of record.

## Decision

PostgreSQL 16 is authoritative. Redis 7 is non-authoritative cache/coordination. RabbitMQ 3.13 transports versioned, idempotently consumed events, which are published from a PostgreSQL transactional outbox.

## Consequences

This prevents lost publication after committed state changes and makes cache loss non-financial. It adds outbox processing, duplicate-delivery handling, and eventual consistency for consumers.
