# Availability error-budget response

## AI Attribution Block

AI-assisted target runbook. It does not state that an incident, burn alert, release freeze or recovery has occurred.

1. Confirm alert labels, query range, service and environment; record the Alertmanager fingerprint and dashboard/tracing links.
2. Check the request SLI, traffic denominator, 5xx breakdown, latency, saturation and current rollout/release digest. Do not treat absent telemetry as recovery.
3. At critical 14.4x burn, pause feature promotion and follow the active rollback procedure if a rollout violates its release criteria. At warning 6x burn, open SRE investigation and assess budget state.
4. Apply the release policy in `docs/08-observability/01-sli-slo-sla-and-error-budgets.md`; only the approved change authority may override a freeze.
5. Record actual timestamps, affected SLI, mitigation and restoration evidence. Conduct a blameless follow-up for sustained/exhausted budget.
