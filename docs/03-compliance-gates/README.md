# ForgePay identity, access and compliance gates

## AI Attribution Block

AI-assisted identity and access-control foundation. These artifacts are configuration templates and control requirements, not evidence that AWS, EKS, GitHub, ArgoCD, KMS, or any compliance control has been configured, deployed, tested, or audited. Human security, platform, compliance and service owners must approve and operate them.

This directory implements the platform identity, access-control, secrets and segregation-of-duties foundation while preserving the build-once, signed-digest GitOps architecture in `docs/01-pipeline-architecture/` and the expand-contract migration process in `docs/04-database-migration/`.

| Document | Purpose |
| --- | --- |
| [01-identity-and-access-model.md](01-identity-and-access-model.md) | AWS, GitHub Actions OIDC, EKS workload identity, RBAC and ArgoCD boundaries |
| [02-segregation-of-duties.md](02-segregation-of-duties.md) | Production approval, role separation, break-glass and reviews |
| [03-secrets-keys-and-supply-chain-trust.md](03-secrets-keys-and-supply-chain-trust.md) | Secrets, KMS ownership and Cosign trust boundary |
| [04-rbi-pci-dss-v4-mapping.md](04-rbi-pci-dss-v4-mapping.md) | Design mapping and evidence requirements |

`deploy/security/` contains offline policy templates. Every `REPLACE_WITH_*` value is deliberately unresolved; it must be replaced through approved provisioning, never guessed.
