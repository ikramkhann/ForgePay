# ADR-002: Promote signed immutable artifacts through GitOps

## AI Attribution Block

AI-assisted architecture decision draft. It is proposed design rationale, not implementation, deployment, compliance, or runtime evidence; human approval is required before adoption.

## Status

Proposed

## Context

The platform specification requires GitHub Actions, an artifact registry, ArgoCD, EKS, segregation of duties, and traceable release promotion.

## Decision

Build once in GitHub Actions, publish a signed image and SBOM, and promote the same image digest by an approved GitOps desired-state change. ArgoCD reconciles the desired state into each environment. Mutable tags and direct ad-hoc cluster deployment are excluded from the target path.

## Consequences

This improves provenance, reproducibility, and auditability. It introduces GitOps change management and requires well-designed approvals to protect the under-two-hour target.
