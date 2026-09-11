# Environment Promotion Model

## AI Attribution Block

AI-assisted environment promotion specification. All promotion flows, approval gates, and GitOps reconciliation steps describe designed target workflows for GitHub Actions, ArgoCD, and Kustomize on AWS EKS. No live environment promotions are asserted to have been executed.

---

## Overview

ForgePay enforces a strict **dev → staging → production** promotion model where each environment transition requires a verified image digest, passing compliance gates, and explicit approval by a role-separated operator. No mutable image tags are permitted at any promotion boundary.

---

## Environment Topology

```
┌─────────────────────────────────────────────────────────────────────┐
│                     ForgePay Promotion Pipeline                      │
│                                                                     │
│  ┌──────────┐        ┌──────────────┐        ┌──────────────────┐  │
│  │   dev    │───────►│   staging    │───────►│   production     │  │
│  │          │  Auto  │              │ Manual │                  │  │
│  │ Blue-    │  on CI │  Blue-Green  │ Review │  Canary          │  │
│  │ Green    │  Pass  │  + Manual    │ + Env  │  Progressive     │  │
│  │          │        │  Promotion   │ Approver│  Delivery       │  │
│  └──────────┘        └──────────────┘        └──────────────────┘  │
│       ▲                                                             │
│       │                                                             │
│  CI Pipeline (8 Stages)                                             │
│  Image: sha256:<64-hex-chars>                                       │
│  Signed: Cosign keyless + OIDC                                      │
│  SBOM: Syft SPDX                                                    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Promotion Flow

### Stage 1: CI Pipeline → `dev`

**Trigger:** Merge to `main` branch  
**Mechanism:** Automated digest injection via [`deploy/scripts/set-image-digest.sh`](../../deploy/scripts/set-image-digest.sh)

1. The CI pipeline ([`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)) completes all 8 stages.
2. Upon successful completion, the pipeline computes the immutable `sha256` image digest.
3. The digest is written to the dev Kustomize overlay:
   ```yaml
   # deploy/gitops/environments/dev/kustomization.yaml
   images:
     - name: forgepay
       digest: sha256:<64-hex-verified-digest>
   ```
4. ArgoCD detects the overlay change and reconciles the dev environment.
5. Argo Rollouts deploys the candidate using the **blue-green** strategy.
6. The operator verifies the preview service and manually promotes.

### Stage 2: `dev` → `staging`

**Trigger:** Successful dev deployment verified  
**Mechanism:** Promotion workflow ([`.github/workflows/promote.yml`](../../.github/workflows/promote.yml))

1. An authorized Release Operator triggers the promotion workflow.
2. The workflow copies the verified digest from the dev overlay to the staging overlay:
   ```yaml
   # deploy/gitops/environments/staging/kustomization.yaml
   images:
     - name: forgepay
       digest: sha256:<same-64-hex-verified-digest>
   ```
3. ArgoCD reconciles the staging environment.
4. Argo Rollouts deploys using **blue-green** strategy.
5. QA team and compliance reviewers validate the candidate.
6. Manual promotion is executed after sign-off.

### Stage 3: `staging` → `production`

**Trigger:** Staging verification complete + environment approval  
**Mechanism:** Promotion workflow with GitHub Environment protection rules

1. The Release Operator triggers promotion to production.
2. **GitHub Environment protection** requires approval from a designated Environment Reviewer (separate from the code author and Release Operator).
3. The verified digest is copied to the production overlay:
   ```yaml
   # deploy/gitops/environments/production/kustomization.yaml
   images:
     - name: forgepay
       digest: sha256:<same-64-hex-verified-digest>
   ```
4. ArgoCD reconciles the production environment.
5. Argo Rollouts deploys using **canary** strategy (10% → 25% → 50% → 100%).
6. Automated Prometheus analysis validates at each step.
7. Post-100% observation window (15 minutes) confirms stability.

---

## Segregation of Duties Matrix

| Role                  | Permissions                                        | Restrictions                                    |
| :-------------------- | :------------------------------------------------- | :---------------------------------------------- |
| **Developer**         | Push commits, create PRs                           | Cannot approve own PRs, cannot promote           |
| **PR Reviewer**       | Approve PRs for merge to `main`                    | Cannot be the PR author                          |
| **CI Workload**       | Build, sign, scan images                           | Cannot modify GitOps overlays directly           |
| **Release Operator**  | Trigger promotion workflows                        | Cannot approve production environments           |
| **Environment Reviewer** | Approve production deployments                  | Cannot be the Release Operator or code author    |
| **Database Executor** | Execute migration plans                            | Cannot modify application code or promote        |

See [`docs/03-compliance-gates/02-segregation-of-duties.md`](../03-compliance-gates/02-segregation-of-duties.md) for the full access model.

---

## Digest Immutability Enforcement

At every promotion boundary, the following controls prevent mutable or unsigned images from advancing:

1. **OPA Conftest Policy:** [`deploy/policy/opa/image_digest.rego`](../../deploy/policy/opa/image_digest.rego) requires all Kustomize image entries to have valid `sha256:` digests with 64 hex characters and rejects placeholder strings.
2. **Kyverno Cluster Policy:** [`deploy/policy/kyverno/require-immutable-images.yaml`](../../deploy/policy/kyverno/require-immutable-images.yaml) blocks any pod admission using mutable tags (`:latest`, `:<tag>`) at the Kubernetes admission controller level.
3. **Kyverno Image Verification:** [`deploy/policy/kyverno/verify-images-template.yaml`](../../deploy/policy/kyverno/verify-images-template.yaml) template for verifying Cosign signatures on admitted images.
4. **GitOps Verification:** [`.github/workflows/verify-gitops.yml`](../../.github/workflows/verify-gitops.yml) validates ArgoCD sync status and application health after every overlay change.

---

## Rollback at Each Stage

| Environment   | Rollback Method                                    | Time to Recover        |
| :------------ | :------------------------------------------------- | :--------------------- |
| `dev`         | Abort blue-green; stable ReplicaSet retained       | Immediate (< 30s)      |
| `staging`     | Abort blue-green; revert overlay to previous digest | Immediate (< 30s)      |
| `production`  | Automatic canary abort on metric breach            | Immediate (< 30s)      |
| `production`  | Manual GitOps revert to previous verified digest   | ~2-5 min (ArgoCD sync) |

---

## Related Documents

- [Deployment Strategies Overview](../02-deployment-strategies/README.md)
- [Blue-Green Strategy](../02-deployment-strategies/01-blue-green-strategy.md)
- [Canary Progression](../02-deployment-strategies/02-canary-progression.md)
- [Progressive Delivery Rollback Runbook](../../runbooks/progressive-delivery-rollback.md)
- [Commit to Production Checklist](../../deploy/COMMIT_TO_PRODUCTION.md)
