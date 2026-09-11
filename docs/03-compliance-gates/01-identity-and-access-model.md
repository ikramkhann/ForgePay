# Identity and access model

## AI Attribution Block

AI-assisted target model. It does not assert a configured trust provider, role, cluster, identity association, repository rule, or access grant.

## Trust chain and role boundaries

GitHub Actions receives a short-lived GitHub OIDC token. AWS STS exchanges only an exact, approved workflow subject for temporary credentials. The resulting CI role may publish the already-built image only to its permitted registry scope; it has no Kubernetes or database administrator permission. ArgoCD, running with a distinct in-cluster identity, reconciles reviewed GitOps state. The ForgePay workload has its own EKS workload identity and receives only the data-service secret/config access it needs.

| Actor | Authentication | Permitted boundary | Explicitly excluded |
| --- | --- | --- | --- |
| Developer | Individual GitHub identity | Reviewed source and non-production change proposal | Direct production deployment, AWS administrator, production database credentials |
| CI build workflow | GitHub OIDC -> STS temporary role | Registry publication/attestation scope specified in `deploy/security/iam/` | `eks:AccessKubernetesApi`, cluster-admin, production secret read, direct ArgoCD sync |
| Promotion workflow | GitHub environment-protected execution | Verify signature and propose one digest-only GitOps PR | Merge its own higher-environment PR, cluster deployment |
| ArgoCD deployer | Dedicated ArgoCD service account / registered-cluster credential | Reconcile only its AppProject source, destination and namespace | AWS human-admin role, broad cluster administration, arbitrary repositories |
| ForgePay workload | EKS Pod Identity preferred; IRSA only if explicitly selected | Runtime secret/config/data-client actions granted to its role | Node role credentials, Kubernetes write APIs, registry push |
| Production operator | Named, MFA-protected human identity | Approved break-glass procedure only | Standing unrestricted access |

## AWS IAM architecture

Use separate AWS accounts and EKS clusters for production and non-production as required by the existing target architecture. Within each account, use separate roles for CI registry publication, GitOps/ArgoCD infrastructure provisioning (if approved separately), application workload identity, database migration executor, security audit read-only access, and break-glass. Roles must be assumed with STS temporary credentials; no long-lived AWS access keys in GitHub, Kubernetes Secrets, source, or CI logs.

The supplied GitHub OIDC trust policy binds `aud` to `sts.amazonaws.com` and uses an exact `sub` placeholder. Populate it with the GitHub environment form for the intended workflow, for example `repo:OWNER/REPOSITORY:environment:production`, rather than a wildcard. Use different roles and exact subjects for non-production versus production. The policy does not create a role or an OIDC provider.

For workloads, create the `forgepay` service account in the application namespace and bind it to a single EKS Pod Identity association, or to an IRSA trust policy with an exact service-account subject. The selected mechanism must be one per workload; do not allow both trust paths without an approved exception. The pod is deliberately granted no Kubernetes RBAC binding because the packaged application does not need Kubernetes API access.

## Kubernetes and ArgoCD boundaries

`deploy/helm/forgepay/templates/service-account.yaml` defines the namespace-scoped service account with token automount disabled, and the workload chart uses it. EKS Pod Identity/IRSA credential projection is an external EKS control and must be validated in a real cluster before enabling application cloud calls.

The AppProject template restricts ArgoCD to a single Git repository, target cluster and `forgepay` namespace after placeholders are replaced. It denies source/destination drift by omission. ArgoCD human roles must be mapped to least-privilege IdP groups: read-only observers, application operators for non-production, and production deploy approvers with no direct sync override. ArgoCD credentials/tokens must be short-lived where supported and stored in the platform secret system, not Actions variables.

## GitHub controls required outside this repository

Configure protected `main` and GitOps promotion branches/rulesets to require pull requests, required CI checks, and prohibit force pushes. Configure GitHub Environments `staging` and `production` with required reviewers, prevent self-review, restrict deployment branches/tags, and restrict environment-secret access. Production must require at least one authorized approver who is not the source or GitOps change author. Repository administrators must not use an administrator bypass for production promotion; if GitHub configuration cannot disable bypass for the selected plan, treat it as an unresolved control gap and use an independently governed production repository/approval boundary.

The checked-in promotion workflow already binds the job to the selected GitHub Environment. The environment settings, not YAML alone, enforce approval. It proposes a PR and never calls ArgoCD sync or Kubernetes APIs.
