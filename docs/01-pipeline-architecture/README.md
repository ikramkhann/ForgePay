# ForgePay Pipeline Architecture

## Purpose

This architecture baseline describes the target delivery and production architecture for the ForgePay Digital Banking Platform.

> **FORGEPAY - BY FIIFII**

It is a design record, not implementation evidence: no AWS resources, deployments, scan results, control attestations, screenshots, or runtime metrics are claimed by these documents.

## AI Attribution Block

This document was drafted with AI assistance for the platform architecture design phase. A human reviewer remains accountable for verifying requirements, making implementation decisions, and approving any resulting change. Statements marked **Target** describe intended architecture, not observed state.

## Document map

| Document | Scope |
| --- | --- |
| [01-overall-architecture.md](01-overall-architecture.md) | System context, production topology, service and trust boundaries |
| [02-cicd-and-promotion.md](02-cicd-and-promotion.md) | Eight-stage pipeline, artifact and GitOps promotion flow |
| [03-eks-delivery-and-resilience.md](03-eks-delivery-and-resilience.md) | EKS environments, Helm/Kustomize, blue-green/canary, rollback |
| [04-data-security-observability.md](04-data-security-observability.md) | Data topology, migration, security/compliance and telemetry architecture |
| [05-platform-traceability.md](05-platform-traceability.md) | Requirement-to-design traceability and validation intent |
| [adr/](adr/) | Architecture decisions and trade-offs |

## Status and scope boundary

All ADRs are **Proposed** until an authorized implementation phase accepts them. CI/CD workflows, Terraform, Kubernetes manifests, application code, IAM policies, database migrations, dashboards, runbooks, and evidence are intentionally outside this phase.
