# ADR-001: Start with a modular Spring Boot core and explicit bounded contexts

## AI Attribution Block

AI-assisted architecture decision draft. It is proposed design rationale, not implementation, deployment, compliance, or runtime evidence; human approval is required before adoption.

## Status

Proposed

## Context

ForgePay must deliver banking behavior while preserving clear ownership of financial invariants, asynchronous work, and integrations. Immediate microservice decomposition would add deployment, contract, and operational overhead before independent teams or scaling needs are proven.

## Decision

Use Java 21 / Spring Boot 3.x with modular bounded contexts and ports-and-adapters. Accounts & Ledger is the transactional authority; Payments orchestrates payment state; Notifications and Operations consume explicit contracts. Framework and infrastructure dependencies remain outside domain policy.

## Consequences

This reduces early operational complexity and permits atomic changes across closely related modules. It gives up independent deployment and scaling per context until extraction is justified. Module boundary enforcement and contract tests are required to prevent a disguised monolith.
