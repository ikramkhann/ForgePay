# Deployment verification and runtime dependencies

## AI Attribution Block

AI-assisted release-verification specification. It is not evidence of a completed deployment, canary, blue-green promotion, observation window or rollback. ArgoCD remains the deployer; the supplied verification configuration is read-only except for Argo Rollouts' configured abort behavior.

## Release verification model

| Strategy | Existing design alignment | Required gates | Observation |
| --- | --- | --- | --- |
| Blue-green | preview service, manual promotion (`autoPromotionEnabled: false`) | preview health twice at 30s; 5m Prometheus analysis before and after promotion; 15m scale-down/abort protection | 15m after promotion |
| Canary | existing 10%, 25%, 50%, 100% steps, 2m pauses | at each step, 5m Prometheus release analysis; abort on failed analysis | 5m/step plus 15m after 100% |

Automated analysis abort thresholds are identical in both strategies: HTTP 5xx rate >5% over 5m; p99 latency >300 ms over 5m; PostgreSQL pool active/max >=90% over 5m or pending >0 over 5m; payment gateway timeout >10% over 5m; failed readiness/synthetic health check; or a failed analysis query. Canary abort retains stable traffic. Blue-green failure before promotion leaves stable traffic untouched; a failure after promotion retains the prior revision for the configured 15-minute abort window, during which the approved Argo Rollouts/GitOps recovery action restores stable traffic. These thresholds describe application traffic rollback only. They never automatically reverse a database migration.

## CI/CD reliability gates

1. CI must attach source revision, signed immutable digest and test evidence to promotion as already designed.
2. Promotion must preserve the same digest and await reviewed GitOps/ArgoCD reconciliation; no direct cluster deployment is added.
3. The target telemetry endpoint and Prometheus credentials/configuration must be explicitly supplied by the real environment. A missing telemetry source fails closed for production verification.
4. A release must emit correlation fields and pass pre-promotion health/analysis; failed gates record `deployment_verification_total` and abort the rollout.
5. Production may proceed only when availability-budget policy permits it and any database plan remains compatible with both revisions during its mandated rollback window.

## Real-environment prerequisites

Prometheus must scrape application, Argo Rollouts, Kubernetes and approved exporter metrics. Grafana requires configured Prometheus, Loki and Jaeger data sources. Loki requires an approved storage/retention design; OTel Collector and Jaeger require approved endpoints and sampling/retention; Alertmanager needs approved receiver integrations. URLs, credentials, routing destinations, on-call ownership, maintenance exclusions and actual SLO values require a deployed, approved monitoring environment and are intentionally not invented here.
