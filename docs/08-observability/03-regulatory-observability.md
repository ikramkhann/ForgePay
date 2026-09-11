# Regulatory and compliance observability

## AI Attribution Block

AI-assisted control design, not legal advice, an RBI determination, a PCI-DSS attestation, or collected compliance evidence. Formal scoping, retention periods, access approvals and evidence review remain human compliance-owner responsibilities.

## Target controls

| Control objective | Target implementation | Required evidence in a real environment |
| --- | --- | --- |
| Traceability of changes | correlate source revision, signed digest, GitOps revision, ArgoCD application and verification outcome | immutable workflow, approval, GitOps and rollout records |
| Security/audit visibility | collect CI, ArgoCD, Kubernetes, database audit and deployment-verification events in the approved audit system | configured sources, sample records, review/retention records |
| Data minimisation | JSON logs and OTel attributes use allowlists/redaction; prohibit PAN, CVV, token, secret, authorization header and full personal data | instrumentation review and redaction test results |
| Least-privilege telemetry access | Grafana/Loki/Jaeger/Alertmanager access governed by the existing identity model; segregate viewer, operator and administrator access | access mappings, reviews and audit trails |
| Integrity and retention | retention/immutable storage settings are compliance-approved and environment-specific, not guessed in repository configuration | approved policy, configuration export and restore/access test |
| Alert accountability | alert records carry service, environment, severity, release digest and correlation ID where available | routed alert and acknowledgement evidence |

Loki labels must be low-cardinality and must not contain personal or payment data. Store event detail in structured log fields only after redaction. Trace sampling must retain error traces and release-verification traces subject to approved scope and retention; it must not capture payment credentials. Dashboards show aggregated status, not raw sensitive records.
