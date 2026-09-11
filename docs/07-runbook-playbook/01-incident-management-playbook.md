# Incident management playbook

## AI Attribution Block

AI-assisted operational playbook. Contacts, URLs, on-call schedules, customer commitments, and actual incident evidence must be supplied by the approved production environment. This document does not claim any incident occurred.

## Severity and escalation

| Severity | Criteria | Acknowledge / declare | Update cadence | Escalation |
| --- | --- | --- | --- | --- |
| SEV1 Critical | full outage, material payment failure, data-integrity/security risk, or critical customer impact | <5 minutes | every 15 minutes | primary + secondary immediately; Engineering Manager and incident executive immediately |
| SEV2 Major | key workflow degraded or >25% user impact; paying-account report minimum | <15 minutes | every 30 minutes | Engineering Manager within 15 minutes; service/dependency owner |
| SEV3 Moderate | bounded feature issue with safe workaround | <1 hour | every 2 hours | team lead / next business review |
| SEV4 Low | cosmetic, non-production, or no user impact | next business day | daily | backlog triage |

Upgrade one level when impact doubles, a data-integrity concern arises (immediate SEV1), a SEV1 cause is unknown after 30 minutes, or a SEV2 cause is unknown after two hours. Incident classification reflects confirmed impact; thresholds are detection inputs, not proof of impact.

## Command roles

| Role | Responsibility |
| --- | --- |
| Incident Commander (IC) | declares severity, assigns roles, approves mitigation trade-offs, controls scope, cadence, and resolution declaration |
| Technical Lead | executes time-boxed diagnosis and approved runbooks; proposes mitigations and verification evidence |
| Communications Lead | issues fixed-cadence internal/external updates; never speculates or shares restricted evidence |
| Scribe | keeps timestamped decision/action/evidence timeline; records unknowns as unknown |
| Database owner / dependency owner | approves specialist actions and carries their recovery or vendor escalation path |

The primary on-call may initially fill several roles, but the IC should delegate as responders arrive. Every hypothesis has a 15-minute investigation timebox before the IC chooses a pivot, mitigation, or escalation.

## Detection and triage

1. Acknowledge the page, open an incident record/channel, record the alert source and timestamp, then validate alert freshness and telemetry health.
2. Check impact with the Engineering, Management, and Regulatory dashboards: API error/latency, payment outcome, database saturation, active rollout, and data-quality/redaction controls. Do not treat dashboard configuration as runtime evidence.
3. Inspect the latest reviewed GitOps change, immutable digest, ArgoCD sync state, Argo Rollouts phase and analysis, then correlate redacted Loki logs and OpenTelemetry/Jaeger traces.
4. Declare severity and roles. Protect users first: abort/rollback an implicated candidate before extended root-cause investigation.
5. Record each observation, command reference, decision, owner, and actual result in the evidence checklist. No cardholder data, secrets, access tokens, raw payment payloads, or unredacted personal data may enter incident channels or artifacts.

## Communication discipline

Within the severity cadence, publish: status (investigating/identified/mitigating/resolved), user impact actually known, time window, actions taken, next action, and next-update time. State uncertainty explicitly. Communications Lead uses approved on-call, executive, customer-support, status-page, legal/compliance, and vendor channels; channel identities are environment-owned and intentionally not invented here.

Initial SEV1 message: `We are investigating a production issue affecting [confirmed service/function]. Current confirmed impact: [known/unknown]. IC: [role/name]. Next update: [time].`

Resolved message: `Mitigation has been verified for the required observation window. Impact and root cause remain [known/under review]. A blameless review and evidence preservation are in progress.`

## Review, learning, and MTTR

SEV1/SEV2 receive a blameless post-incident review within 48 hours. The Scribe’s timeline, not memory, anchors reconstruction. Record detection time, declaration, mitigation start, service-restored time, and all-clear time; publish DORA Time to Restore only when the deployed telemetry has those correlation fields. Improvement actions require owner, priority, due date, validation method, and weekly tracking. Repeated action-item failures, noisy pages, or high restore time trigger reliability review and error-budget policy application.

Use [the 3 AM runbook](../../runbooks/incident-command-and-3am-response.md), [rollback specification](../06-rollback-specification/01-application-and-deployment-rollback.md), and [evidence templates](../../evidence/incident-response/README.md).
