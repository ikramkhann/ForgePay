# Platform Requirements & Architecture Traceability

> **FORGEPAY - BY FIIFII**

## AI Attribution Block

AI-assisted traceability draft. “Planned” means architectural intent only; it is not evidence of an implemented, tested, deployed, or compliant control.

| Platform Requirement | Architecture / Repository response | Status / Verification state |
| --- | --- | --- |
| Java 21 / Spring Boot 3.x | Modular ports-and-adapters architecture; build job configured | Statically verified in CI Stage 2 workflow; application source deferred to build team |
| GitHub Actions, registry, ArgoCD, EKS | Immutable artifact to GitOps to ArgoCD reconciliation flow | Workflows (`ci.yml`, `promote.yml`, `verify-gitops.yml`) and templates verified; live cluster execution requires environment provisioning |
| Terraform, Helm, Kustomize | Terraform boundary defined; Helm chart and Kustomize overlays built | Manifests and overlays statically verified via Kustomize & Helm lint |
| PostgreSQL 16, Redis 7, RabbitMQ 3.13 | Authoritative store, non-authoritative cache, idempotent outbox | Validated in CI service containers and expand-contract architecture specifications |
| Eight canonical stages | Explicitly numbered in CI workflows and architecture | Complete; Stages 1–7 in `ci.yml`, Stage 8 in `verify-gitops.yml` |
| Sonar, Trivy, Syft, ZAP, OPA/Conftest, Kyverno, Checkov, Cosign | Tool integration across mandatory gates and admission policies | Implemented in CI stages and `deploy/policy/`; policy syntax verified; runtime reports generated on execution |
| JUnit and Pact | Unit and contract testing stages in CI | Configured in CI Stages 2 and 5 |
| Blue-green, canary, rollback | Argo Rollouts blue-green & canary with Prometheus analysis abort | Manifests (`rollout.yaml`, `analysis-template.yaml`) implemented and harmonized; thresholds match SRE specs |
| Expand-contract database migration | Additive expand, batch backfill, switch, and contract sequence | Complete; schema, validator script, and sample plan (`d1-expand-accounts.json`) verified |
| RBI, PCI-DSS v4.0, segregation of duties | Control mappings, IAM/OIDC templates, approval matrix | Complete design mapping in `docs/03-compliance-gates/`; formal certification requires independent audit |
| Under-two-hour commit-to-production | Gate-budget workflow design | Complete target flow in `deploy/COMMIT_TO_PRODUCTION.md`; DORA lead-time metric defined |
| Five-nines availability, DORA, 15+ metrics | SRE model, 25 metrics catalog, Prometheus alert rules | Complete in `docs/08-observability/` and `pipeline/observability/prometheus-rules.yaml` |
| Engineering, Management, Regulatory dashboards | Three Grafana JSON dashboard definitions and mockups | Complete in `dashboards/grafana/` and `dashboards/mockups/` |
| Incident simulation and runbooks | Playbook, simulation scenario, and 7 operational runbooks | Complete in `runbooks/`, `docs/07-runbook-playbook/`, and `evidence/` |
| Exactly three deliberate defects in ERRATA.md | Three technical defects identified, analyzed, and remediated | Complete; ERR-001, ERR-002, ERR-003 documented in root `ERRATA.md` |
| Architecture review & executive briefing deck | Review structure and executive summary defined | Executive briefing and navigation in root `README.md`; executive slide presentation prepared for review |
| Version control lifecycle & promotion history | Authentic version control progression | Traceable Git history and immutable digest promotion gates |

All repository directories and artifacts are now established. Artifacts represent static validation and architectural specifications; no claims of live infrastructure or active production telemetry are made without empirical execution evidence.
