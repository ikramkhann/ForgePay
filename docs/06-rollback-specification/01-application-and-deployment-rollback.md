# Application and deployment rollback specification

## AI Attribution Block

AI-assisted incident-response specification. It describes target procedures and configuration-aligned decision rules, not a performed rollback, deployment, alert, or production result. It does not authorize changes to IAM, CI/CD approval controls, or database schema.

## Scope and non-negotiable boundaries

ArgoCD remains the production deployer from reviewed GitOps desired state. Argo Rollouts is the progressive-delivery controller. A rollback restores application traffic to a previously verified, immutable image digest through the approved GitOps/ArgoCD and Rollouts path. Do not use an imperative `kubectl` deployment change as a substitute for the GitOps record.

An application rollback is **not** a database rollback. During `D1` expand-contract phases, A0 and A1 are compatible and rollback may return traffic to A0 while D1 remains. During or after D2 contract, an automatic or presumed application rollback is prohibited; stop, preserve evidence, and obtain the database-owner recovery decision.

## Rollback decision table

| Signal, confirmed for required window | Response | Traffic result | Database action |
| --- | --- | --- | --- |
| HTTP 5xx rate >5% for 5m | fail analysis / abort candidate | stable revision retained or restored | none |
| p99 latency >300ms for 5m | fail analysis / abort candidate | stable revision retained or restored | none |
| PostgreSQL pool active/max >=90% for 5m, or pending >0 for 5m | pause and abort implicated candidate; engage DB owner | stable revision retained or restored | no session kill, config change, or schema reversal without owner approval |
| Payment-gateway timeout >10% for 5m | abort only if candidate correlation supports it; escalate dependency | stable revision retained or restored if implicated | none |
| readiness or synthetic health check fails for 60s | fail analysis / abort candidate | stable revision retained or restored | none |
| telemetry unavailable | fail closed for production verification | no promotion; stable traffic remains | none |

These are target configuration thresholds from `pipeline/observability/release-verification.yaml`, not observed outcomes.

## Canary abort and recovery

1. IC declares severity, assigns Technical Lead and Scribe, and records rollout name, candidate/stable digest, GitOps revision, analysis run, and migration phase.
2. Technical Lead confirms the threshold against Prometheus and checks Argo Rollouts analysis. A failed analysis should abort automatically; if it has not, use the approved Rollouts/GitOps emergency procedure to abort the candidate and make the approved GitOps state explicit.
3. Confirm stable service traffic, two health checks, and correlation of error/latency/pool/gateway signals with the stable digest.
4. Maintain the 15-minute post-abort observation window. Do not resume or promote the candidate merely because a single point-in-time reading improves.
5. Reconcile the emergency desired-state change into the reviewed GitOps record; preserve the candidate digest and analysis evidence for review.

Canary steps remain 10%, 25%, 50%, and 100%, with two-minute pauses and five-minute analysis. Incident response does not alter those strategy settings.

## Blue-green rollback and recovery

1. Before promotion, a failed preview health or pre-promotion analysis means do not promote; stable active service remains untouched.
2. After promotion, use the approved Argo Rollouts/GitOps recovery action to restore stable service selection to the prior verified revision. The existing `scaleDownDelaySeconds` and `abortScaleDownDelaySeconds` retain the prior revision for 900 seconds (15 minutes).
3. Verify active service selectors/endpoints point to the intended stable revision, execute two health checks, and monitor SLI, dependencies, logs, and traces for 15 minutes.
4. Record actual timestamps and observed values. A passing configuration check is not proof traffic recovered.

## Rollback completion criteria

- Stable digest, GitOps commit, and rollout revision are recorded and mutually consistent.
- Applicable rollback threshold is no longer breached in its configured window, and two health checks pass.
- No new critical alert is active during the 15-minute observation window.
- Database phase/compatibility is recorded; no destructive database action was taken without the database owner.
- Communications, evidence manifest, and post-incident owner are assigned before closure.

See [incident command and 3 AM response](../../runbooks/incident-command-and-3am-response.md), [database migration incident handling](../../runbooks/database-migration-incident-handling.md), and [release verification](../08-observability/04-verification-and-runtime-dependencies.md).
