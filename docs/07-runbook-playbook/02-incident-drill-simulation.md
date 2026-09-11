# Incident Drill Simulation: Friday Hotfix Canary

> **FORGEPAY - BY FIIFII**

## AI Attribution Block

AI-assisted operational drill scenario only. This is a tabletop/simulation reference, not a historical or live incident record. No alerts, logs, metrics, deployment, user impact, rollback, or outcome is asserted to have occurred.

## Scenario inputs

At **Friday 5:07 PM IST**, a **critical hotfix bypassed staging** and has been in a production **canary for 8 minutes**. The reference conditions are: HTTP 500 error rate **12%**, critical against the existing **5% over 5 minutes** threshold; PostgreSQL connection-pool exhaustion, high, against **active/max >=90% for 5 minutes or pending >0 for 5 minutes**; and payment-gateway timeout **35%**, critical against the existing **10% over 5 minutes** threshold.

These values are scenario injects. In a real response, responders must validate them with live Prometheus/rollout evidence before acting.

## Required simulation timeline

| Relative time | Simulated response action | Required record / gate |
| --- | --- | --- |
| T+0 (5:07 PM IST) | Treat correlated critical HTTP and gateway conditions plus high pool exhaustion as a likely SEV1; acknowledge, open record/channel, assign IC/Technical Lead/Comms/Scribe. | alert references, declared severity, candidate and stable digest, rollout step and start time |
| T+30s | Confirm telemetry freshness; compare candidate versus stable traffic; inspect Argo Rollouts analysis, active canary weight, readiness, and latest GitOps revision. | validation result or `unknown`; never invent a firing alert |
| T+2m | Abort the candidate through existing Rollouts/GitOps response path; freeze further promotion. Begin dependency/database-owner escalation. Do not restart DB, terminate sessions, or reverse schema. | abort request/result, migration D0/D1/D2 phase, vendor escalation reference |
| T+5m | Re-evaluate configured five-minute thresholds, stable service health, traces and redacted logs. If the candidate is not safely removed or errors persist, escalate response and consider wider fault domain. | actual metric windows, traffic state, IC decision and next update |
| T+10m | Verify two health checks; correlate pool recovery and payment outcomes. Continue fixed SEV1 updates; preserve redacted evidence. | verification checklist; known vs unknown impact |
| T+15m | Complete required post-abort observation only if thresholds clear and no new critical signal appears. | 15-minute observation evidence; no declaration based on a snapshot |
| T+30m | If service is stable, issue mitigated/all-clear communication as appropriate; retain candidate artifact and GitOps record. If cause remains unknown, maintain/escalate SEV1 investigation. | restored timestamp only if actually observed; post-incident review owner |
| Within 48h | Facilitate blameless review; reconstruct timeline; create owned MTTR and preventive actions. | completed template and action register |

## Simulation success criteria

Success is that responders can follow the approved decision path, preserve stable traffic, respect the D1/D2 migration boundary, and distinguish configured thresholds from live evidence. It is not a claim that the described hotfix or response happened.

See [the rollout rollback specification](../06-rollback-specification/01-application-and-deployment-rollback.md) and [observability threshold cross-links](../08-observability/05-incident-response-cross-links.md).
