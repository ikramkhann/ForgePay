# Secrets, keys and supply-chain trust

## AI Attribution Block

AI-assisted security design. It does not evidence an existing secret, key, signing certificate, encryption configuration, rotation, or verification event.

## Secrets and encryption boundaries

Store runtime secrets in an approved AWS-backed secret manager and deliver them to workloads through the approved workload identity and a reviewed external-secrets/CSI mechanism. Do not commit plaintext secrets, place production secrets in Helm values, expose them as GitHub repository variables, or pass them on command lines. GitHub Environments may store only CI-specific protected secrets needed until a workload-identity replacement exists; environment scope and approvals must restrict production values.

Security/KMS owners administer customer-managed keys, key policies, rotation/retirement and break-glass use. Workload and CI roles are key *users* only for their narrowly approved encrypt/decrypt/sign operations; developers and ArgoCD do not receive broad decrypt or key-administration permissions. Database encryption, backups and restore authorization remain database-owner responsibilities under `docs/04-database-migration/`; this document does not select or configure them.

## Cosign identity and admission boundary

The existing CI workflow uses keyless Cosign signing with GitHub Actions OIDC and verifies the issuer and workflow identity before promotion. The authoritative identity is the exact workflow certificate subject, issuer, repository and protected ref/environment policy—not a mutable image tag. The existing Kyverno verification file is intentionally an unapplied template. Before enforcement, the security owner must replace the trusted registry/repository and exact certificate identity, test enforcement in non-production, and establish certificate/provenance retention. A KMS-backed signing key may be selected only through an approved replacement design; do not mix an unverified KMS key with keyless trust.

Admission verification is defense in depth; it cannot substitute for protected source, CI scanning, GitOps review, or environment approvals. The initial immutable-digest Kyverno policy remains Audit mode until the cluster owner validates its scope and exception process; changing to Enforce is a controlled production change.
