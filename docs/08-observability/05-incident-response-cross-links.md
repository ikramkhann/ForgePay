# Incident-response observability cross-links

## AI Attribution Block

AI-assisted integration guide. The referenced alerts, metrics, dashboards, and configurations are target artifacts; it does not report telemetry, an alert firing, a deployment result, or an incident.

## From alert to response

| Target alert / verification condition | Numeric condition | Response artifact |
| --- | --- | --- |
| HTTP 5xx / latency | 5xx >5% for 5m; p99 >300ms for 5m | [HTTP rollback](../../runbooks/http-5xx-and-rollback.md), [deployment response](../../runbooks/progressive-delivery-rollback.md) |
| PostgreSQL pool | active/max >=90% for 5m or pending >0 for 5m | [pool runbook](../../runbooks/postgresql-pool-exhaustion.md), [migration incident handling](../../runbooks/database-migration-incident-handling.md) |
| payment gateway timeout | >10% for 5m | [gateway runbook](../../runbooks/payment-gateway-timeout.md), [incident command](../../runbooks/incident-command-and-3am-response.md) |
| health/synthetic failure | failed for 60s | [rollback specification](../06-rollback-specification/01-application-and-deployment-rollback.md) |
| telemetry absent | fail closed for production verification | [verification prerequisites](04-verification-and-runtime-dependencies.md) |

The drill simulation values (12% HTTP 500, high pool exhaustion, and 35% gateway timeout) remain scenario inputs only. See [simulation timeline](../07-runbook-playbook/02-incident-drill-simulation.md).

## Compliance and audit handling

Use dashboard references and redacted Loki/trace references, not copied sensitive event payloads, in the incident record. Capture release correlation fields (`service`, `environment`, `release_digest`, `source_revision`, `change_id`, `outcome`) where the deployed systems provide them. Missing fields are a data-quality finding, not a value to infer. Retention, recipient routing, legal reporting criteria, and actual regulatory notification duties require approved compliance/legal ownership.
