# ForgePay security policy templates

## AI Attribution Block

AI-assisted offline security templates. They are not applied AWS IAM, EKS, Kubernetes, ArgoCD, KMS, or compliance configuration and do not grant access by their presence in this repository.

`iam/` supplies narrow trust and permission-policy documents with deliberately unresolved values. `github-actions/` provides a reusable OIDC credential-exchange template with a 15-minute STS session; it is not called by the current GHCR workflow because no approved AWS role, account, region, or ECR registry choice was supplied. `argocd/` supplies an AppProject template that bounds a configured application to one repository, cluster and namespace. The Helm chart owns the `forgepay` service account; associate it with EKS Pod Identity (preferred) or approved IRSA outside these templates. Do not apply a template with any `REPLACE_WITH_*` value unresolved.
