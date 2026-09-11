# SLI, SLO, SLA and error-budget model

## AI Attribution Block

AI-assisted target reliability model. Targets and formulas below are not measured results, contractual terms, or proof of availability. Product, legal, compliance and service owners must approve the customer SLA and operating policy before production use.

## Scope and measurement

The service target is the ForgePay payment API. Prometheus is the target SLI source. A valid request is one reaching the API after edge authentication and request validation. Planned maintenance is **not** automatically excluded: only a documented, customer-approved SLA exclusion may be filtered using a reviewed maintenance label. Client-aborted requests, invalid requests rejected with 4xx, and an unavailable third-party payment gateway remain visible as dependency indicators; they do not improve the API availability numerator by being silently discarded.

| Level | Definition | Window | Target | Owner action |
| --- | --- | ---: | ---: | --- |
| SLI | `good requests / eligible requests`; good is HTTP status `<500` and not an instrumented server timeout | rolling 30 days | measured | SRE maintains query and cardinality controls |
| Availability SLO | API availability SLI | rolling 30 days | **99.999% target** | Freeze non-essential risk when budget policy triggers |
| Latency SLO | eligible requests completed in `<=300 ms` | rolling 30 days | 99.0% | investigate latency/saturation trend |
| Payment dependency SLO | payment gateway calls completed without timeout or 5xx | rolling 30 days | 99.9% | dependency owner escalation and resilient-degradation review |
| Customer SLA | contractual commitment, if approved | contract-defined | not set by this document | Legal/product must separately approve |

Five nines is a target, not an achieved outcome. At 30 days, a 99.999% availability target permits 0.00001 of eligible-request failure: approximately 2.59 seconds of equivalent full outage. Request-weighted error budget is authoritative; time equivalents are explanatory only and do not permit rounding.

## Error budget and release policy

For the availability SLO, `budget = 1 - 0.99999 = 0.00001` of eligible requests per rolling 30-day window. Budget consumption is `1 - availability`, divided by `0.00001`.

| Budget state | Calculation | Release policy |
| --- | --- | --- |
| Healthy | <25% consumed | normal progressive releases after all gates |
| Guarded | 25% to <50% consumed | SRE review required for production promotion |
| Restricted | 50% to <100% consumed | only reliability, security or approved regulatory changes |
| Exhausted | >=100% consumed | freeze feature releases; restore reliability and document exit approval |

Burn-rate alerts use the 30-day budget: critical at 14.4x in both 5m and 1h windows; warning at 6x in both 30m and 6h windows. These are target alert rules, not alert history.

## Dependency and migration safeguards

Payment gateway availability is tracked separately because its failure has customer impact but requires a dependency-aware response. PostgreSQL health and pool saturation are release blockers, not an automatic database rollback mechanism. Database changes remain governed by the expand-contract lifecycle: an application rollback selects the prior verified digest only while both revisions are schema-compatible. No observability configuration authorizes direct database actions, destructive contract rollback, or changes to IAM.
