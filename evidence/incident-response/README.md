# Incident response evidence templates and checklists

## AI Attribution Block

AI-assisted templates only. Empty fields are intentionally not evidence. Populate from approved systems during a real incident; record missing data as `unknown` and do not reconstruct it by assumption.

## Evidence manifest checklist

| Field | Record |
| --- | --- |
| Incident ID, severity, IC, roles |  |
| Detection source, alert/query reference, actual alert time |  |
| Service/environment; user impact and confidence |  |
| GitOps commit, ArgoCD sync, rollout revision, stable/candidate immutable digests |  |
| Strategy, canary weight or active/preview traffic state; analysis reference |  |
| Prometheus query references and actual windows/values |  |
| Redacted Loki log and OTel/Jaeger trace references |  |
| Database plan ID, D0/D1/D2 phase, checkpoint, integrity result |  |
| Dependency/vendor escalation reference |  |
| Decision/action/timestamp/operator/approval reference |  |
| Mitigation verification and 15-minute observation outcome |  |
| Communication updates and post-incident owner |  |

Never include secrets, authentication tokens, private keys, PAN/cardholder data, raw payment payloads, or unredacted personal information. Retention, legal hold, and access must follow approved compliance policy.

## Timeline reconstruction template

| Timestamp (with zone) | Source/reference | Observation or action | Owner | Known/unknown | Decision/result |
| --- | --- | --- | --- | --- | --- |
|  |  |  |  |  |  |

## Blameless post-incident review template

```markdown
# Post-incident review: [title]

## AI Attribution Block
Template populated from verified evidence; no assertion is made until fields are completed and reviewed.

Date: [ ]  Severity: [ ]  Status: Draft/Review/Final
Duration: [detection] to [service restored] to [all clear]

## Executive summary and confirmed impact
[What happened, confirmed scope, mitigation. State unknowns.]

## Timeline
[Use the evidence timeline; include detection, declaration, mitigation, restoration, and all-clear.]

## Technical analysis
Immediate trigger: [ ]
Contributing system/process conditions: [ ]
Root cause confidence and evidence: [ ]
Database/migration phase and decision: [ ]

## What helped / what impeded
[Blameless, system-focused observations.]

## DORA and SLO review
MTTD: [verified only]  Time to Restore: [verified only]
Error-budget impact: [verified only]  Change failure classification: [verified only]

## Actions
| Action | Owner | Priority | Due date | Validation | Status |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |  |
```
