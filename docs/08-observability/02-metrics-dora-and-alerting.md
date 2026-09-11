# Reliability metrics, DORA model and alerts

## AI Attribution Block

AI-assisted metric and alert specification. Metric names, queries, labels and thresholds are desired configuration only. No dashboard, alert, pipeline run, release, incident or DORA result is asserted to have occurred.

## DORA metrics

| Metric | Target event source | Formula | Reporting cadence |
| --- | --- | --- | --- |
| Deployment Frequency | ArgoCD/Argo Rollouts verified production promotions | count of completed production rollouts with a verified digest | weekly and monthly |
| Lead Time for Changes | source revision plus production verification event | production verification timestamp minus merged commit timestamp, per change; report median and p90 | weekly/monthly |
| Change Failure Rate | verified production deployments plus rollback/failed verification events | failed or rolled-back production deployments / completed production deployments | rolling 30 days |
| Time to Restore | Alertmanager incident lifecycle plus service-restored event | restored timestamp minus incident-declared timestamp; report median and p90 | monthly |

Events must include `service`, `environment`, `release_digest`, `source_revision`, `change_id` where applicable, and `outcome`. Missing correlation fields produce an observability-data-quality finding; they must not be inferred.

## Pipeline and operational metric catalogue

The following target catalogue contains more than 15 metrics; dimensions must avoid account identifiers, payment payloads, cardholder data, tokens and unbounded IDs.

| # | Metric | Type | Key labels | Purpose |
| ---: | --- | --- | --- | --- |
| 1 | `http_server_requests_total` | counter | service, route, method, status, environment, release_digest | traffic and availability SLI |
| 2 | `http_server_request_duration_seconds_bucket` | histogram | service, route, status_class, environment, release_digest | p50/p95/p99 latency SLI |
| 3 | `http_server_in_flight_requests` | gauge | service, route, environment | concurrency saturation |
| 4 | `application_health_status` | gauge | service, component, environment | readiness/liveness visibility |
| 5 | `db_connection_pool_active` | gauge | service, pool, environment | PostgreSQL pool utilisation |
| 6 | `db_connection_pool_max` | gauge | service, pool, environment | pool capacity denominator |
| 7 | `db_connection_pool_pending` | gauge | service, pool, environment | queued connections |
| 8 | `db_query_duration_seconds_bucket` | histogram | service, operation, environment | query latency |
| 9 | `payment_gateway_requests_total` | counter | gateway, outcome, environment, release_digest | dependency reliability |
| 10 | `payment_gateway_request_duration_seconds_bucket` | histogram | gateway, outcome, environment | dependency latency |
| 11 | `outbox_pending_records` | gauge | service, environment | transactional-outbox backlog |
| 12 | `outbox_publish_failures_total` | counter | service, reason, environment | publish failure rate |
| 13 | `rabbitmq_queue_messages_ready` | gauge | queue, environment | queue backlog |
| 14 | `rabbitmq_queue_consumers` | gauge | queue, environment | consumer availability |
| 15 | `process_resident_memory_bytes` | gauge | service, pod, environment | memory saturation |
| 16 | `container_cpu_usage_seconds_total` | counter | service, pod, environment | CPU saturation |
| 17 | `kube_pod_container_status_restarts_total` | counter | service, pod, environment | restart instability |
| 18 | `argo_rollouts_phase` | gauge | rollout, phase, environment | progressive-delivery state |
| 19 | `deployment_verification_total` | counter | environment, strategy, gate, outcome, release_digest | release gate outcome |
| 20 | `cicd_stage_duration_seconds` | histogram | stage, workflow, outcome | pipeline latency/reliability |
| 21 | `cicd_stage_runs_total` | counter | stage, workflow, outcome | pipeline failure rate |
| 22 | `dora_deployment_total` | counter | environment, outcome, release_digest | deployment frequency/CFR |
| 23 | `dora_lead_time_seconds` | histogram | environment, change_type | lead time |
| 24 | `dora_restore_time_seconds` | histogram | severity, service | restoration time |
| 25 | `telemetry_redaction_failures_total` | counter | signal, rule, environment | compliance telemetry control |

## Simulation reference conditions

These known drill simulations are test/reference conditions only. They are **not production observations and do not assert an alert fired**.

| Condition | Classification | Gate / alert threshold |
| --- | --- | --- |
| HTTP 500 error rate of 12% | critical simulation | 5% over 5 minutes |
| PostgreSQL connection-pool exhaustion | high simulation | >=90% active/max for 5 minutes, or pending connections >0 for 5 minutes |
| Payment gateway timeout rate of 35% | critical simulation | 10% over 5 minutes |

The matching alert rules are in `pipeline/observability/prometheus-rules.yaml`; response paths are in `runbooks/`.
