# ADR-005: Use a separated observability control plane with correlated telemetry

## AI Attribution Block

AI-assisted architecture decision draft. It is proposed design rationale, not implementation, deployment, compliance, or runtime evidence; human approval is required before adoption.

## Status

Proposed

## Context

The platform specification requires Prometheus, Grafana, Loki, Jaeger/OpenTelemetry, DORA metrics, and Engineering, Management, and Regulatory dashboards. Operational data must not expose payment-sensitive content.

## Decision

Instrument workload and delivery paths with correlated release and request identifiers. Send metrics to Prometheus, structured/redacted logs to Loki, and traces through OpenTelemetry to Jaeger; compose role-specific Grafana views from these sources.

## Consequences

This creates a common investigation path across releases and runtime behavior. It requires cardinality discipline, data-redaction rules, access control, retention decisions, and an SRE-owned SLO definition before reliable alerting.
