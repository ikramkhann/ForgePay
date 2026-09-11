# ForgePay observability and reliability

## AI Attribution Block

AI-assisted SRE design and configuration templates. They define target telemetry, SLOs, alerting and release-verification criteria; they are not evidence that Prometheus, Grafana, Loki, OpenTelemetry, Jaeger, Alertmanager, any alert, deployment, rollback, metric value or five-nines outcome exists or has been observed.

This directory implements the SRE layer for the architecture in `docs/01-pipeline-architecture/`. It preserves GitHub Actions as CI, reviewed GitOps plus ArgoCD as CD, Argo Rollouts for progressive delivery, and the separate PostgreSQL expand-contract process in `docs/04-database-migration/`.

| Artifact | Purpose |
| --- | --- |
| [01-sli-slo-sla-and-error-budgets.md](01-sli-slo-sla-and-error-budgets.md) | Target SLI/SLO/SLA definitions, exclusions, budget and burn policy |
| [02-metrics-dora-and-alerting.md](02-metrics-dora-and-alerting.md) | Metric catalogue, DORA derivations, alerts and simulation references |
| [03-regulatory-observability.md](03-regulatory-observability.md) | Audit telemetry, minimisation, access, retention and evidence boundaries |
| [04-verification-and-runtime-dependencies.md](04-verification-and-runtime-dependencies.md) | Release gates, observation windows and environment prerequisites |
| [05-incident-response-cross-links.md](05-incident-response-cross-links.md) | Alert-to-runbook thresholds, evidence boundaries and drill-simulation links |

Machine-readable target configuration is under `pipeline/observability/`; Grafana definitions are under `dashboards/grafana/`; operational procedures are in `runbooks/`.
