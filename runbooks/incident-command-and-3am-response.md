# Incident command and 3 AM production response

## AI Attribution Block

AI-assisted operational runbook. Command names, dashboards, cluster context, approved emergency channels, and tool access must be configured by the real environment. Follow existing access and change controls; this runbook does not grant access or prove execution.

## First five minutes

1. **Acknowledge and classify.** Validate a real signal from Prometheus/Alertmanager, user reports, or approved synthetic checks. Declare provisional SEV1/2 under the [severity matrix](../docs/07-runbook-playbook/01-incident-management-playbook.md); upgrade on confirmed data-integrity risk.
2. **Take command.** State `I am IC`; appoint Technical Lead, Communications Lead, and Scribe. Start a timestamped incident timeline and set the next update (SEV1: 15 minutes; SEV2: 30 minutes).
3. **Establish blast radius.** Record service, environment, rollout name/phase, candidate and stable immutable digests, GitOps revision, ArgoCD sync state, migration plan/phase if any, and confirmed/unknown user impact.
4. **Protect traffic.** For an implicated candidate, stop promotion and follow [progressive delivery rollback](progressive-delivery-rollback.md). Do not use direct cluster deployment edits; make emergency recovery through approved Rollouts/GitOps and reconcile it into reviewed desired state.
5. **Preserve safe evidence.** Save query links/identifiers, redacted log/trace references, alert payload references, and decisions in the [evidence checklist](../evidence/incident-response/README.md). Never copy secrets, PAN/cardholder data, tokens, or raw payment payloads.

## Triage paths

| Confirmed condition | Immediate action | Do not do |
| --- | --- | --- |
| HTTP 5xx >5% for 5m or p99 >300ms for 5m | inspect rollout correlation; abort candidate; verify stable health | assume a dashboard snapshot proves recovery |
| pool active/max >=90% for 5m or pending >0 for 5m | pause/abort candidate, involve database owner, capture redacted evidence | restart DB, kill sessions, change pool/DB config, or reverse schema without owner approval |
| gateway timeouts >10% for 5m | distinguish dependency versus app errors; abort only an implicated candidate; escalate vendor/owner | expose payment payloads or claim vendor fault without evidence |
| telemetry unavailable | fail closed for production verification; retain stable traffic and diagnose telemetry separately | promote based on missing data |

## 3 AM decision discipline

- Mitigate first, diagnose second. Give each hypothesis 15 minutes.
- The IC alone decides severity, mitigation order, scope changes, and resolution; Technical Lead recommends and executes authorized actions.
- Use exact UTC and IST offsets in records, and record times from the system of record.
- Continue updates even when there is no change. Say what is known, unknown, and next.
- Do not modify IAM, bypass GitOps, delete workloads, alter database schema, run restore/PITR, or expose sensitive evidence during an incident without the appropriate existing approval.

## Resolution and handoff

Require two health checks, configured threshold recovery, stable traffic/routing confirmation, and the 15-minute observation window before declaring mitigation verified. Then identify the post-incident owner and schedule SEV1/SEV2 review within 48 hours. On handoff, transfer current severity, impact, roles, timeline, actions, open hypotheses, monitor links, rollback/migration state, next update, and action owners explicitly.
