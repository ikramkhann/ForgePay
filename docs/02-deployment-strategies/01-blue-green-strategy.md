# Blue-Green Deployment Strategy

## AI Attribution Block

AI-assisted deployment specification. All Argo Rollouts configurations describe target controller state for AWS EKS; no live blue-green deployments are asserted to be running.

---

## Purpose

Blue-green deployment provides a zero-downtime release mechanism by maintaining two identical environments: the **active** (stable) environment serving live traffic and a **preview** (candidate) environment running the new release. Traffic is switched atomically from active to preview only after explicit manual approval and successful automated health analysis.

ForgePay uses blue-green as the default deployment strategy for **development** and **staging** environments where operator verification of the candidate revision is required before any traffic shift.

---

## Architecture

```
                    ┌───────────────────────────────────────────────┐
                    │              Kubernetes Cluster (EKS)         │
                    │                                               │
  Ingress ─────────┤──► forgepay-active (Service)                   │
  (100% traffic)    │       │                                       │
                    │       ▼                                       │
                    │   ReplicaSet (Stable Revision: v1.2.3)        │
                    │                                               │
                    │   forgepay-preview (Service)                   │
                    │       │                                       │
                    │       ▼                                       │
                    │   ReplicaSet (Candidate Revision: v1.3.0)     │
                    │                                               │
                    └───────────────────────────────────────────────┘
```

### Service Layout

| Service               | Role                                    | Helm Reference                    |
| :-------------------- | :-------------------------------------- | :-------------------------------- |
| `forgepay-active`      | Routes all production/staging traffic   | `{{ include "forgepay.name" . }}-active`  |
| `forgepay-preview`     | Routes internal verification traffic    | `{{ include "forgepay.name" . }}-preview` |

Both services are defined in [`deploy/helm/forgepay/templates/service.yaml`](../../deploy/helm/forgepay/templates/service.yaml).

---

## Rollout Configuration

The blue-green strategy is configured in [`deploy/helm/forgepay/templates/rollout.yaml`](../../deploy/helm/forgepay/templates/rollout.yaml) and parameterized through [`deploy/helm/forgepay/values.yaml`](../../deploy/helm/forgepay/values.yaml):

```yaml
strategy:
  blueGreen:
    activeService: forgepay-active
    previewService: forgepay-preview
    autoPromotionEnabled: false                  # ERR-002 fix: explicit manual gate
    prePromotionAnalysis:
      templates:
        - templateName: forgepay-release-health
    postPromotionAnalysis:
      templates:
        - templateName: forgepay-release-health
    scaleDownDelaySeconds: 900                   # 15-min cold-start buffer
    abortScaleDownDelaySeconds: 900
```

### Key Parameters

| Parameter                      | Value    | Rationale                                                                 |
| :----------------------------- | :------- | :------------------------------------------------------------------------ |
| `autoPromotionEnabled`         | `false`  | Mandatory manual approval gate per RBI segregation of duties requirement  |
| `scaleDownDelaySeconds`        | `900`    | Retains previous stable ReplicaSet for 15 minutes after promotion         |
| `abortScaleDownDelaySeconds`   | `900`    | Retains candidate ReplicaSet for 15 minutes after abort for diagnostics   |

> **Note:** The original repository contained `autoPromotionSeconds: 0` without explicitly setting `autoPromotionEnabled: false`. This was identified as ERR-002 and remediated by the Code Reviewer. See [`ERRATA.md`](../../ERRATA.md) for full details.

---

## Promotion Lifecycle

### Phase 1: Candidate Deployment

1. ArgoCD detects a new image digest in the environment's Kustomize overlay.
2. Argo Rollouts creates a new ReplicaSet with the candidate revision.
3. The `forgepay-preview` service selector is updated to route to the candidate pods.
4. The `forgepay-active` service continues routing to the stable ReplicaSet.

### Phase 2: Pre-Promotion Analysis

Before any traffic shift, the Argo Rollouts controller executes the [`forgepay-release-health`](../../deploy/helm/forgepay/templates/analysis-template.yaml) AnalysisTemplate:

1. **Synthetic Health Check:** HTTP GET to `forgepay-preview:8080/actuator/health`, expecting `{"status": "UP"}`.
   - `count: 2`, `interval: 30s`, `failureLimit: 0`
2. **Prometheus Metric Analysis:** 5-minute evaluation window checking:
   - HTTP 5xx rate ≤ 5%
   - P99 latency ≤ 300ms
   - PostgreSQL pool utilization < 90%
   - Payment gateway timeout rate ≤ 10%

If any metric breaches its threshold, the rollout **automatically aborts** and the candidate ReplicaSet is retained for diagnostic inspection for 900 seconds.

### Phase 3: Manual Promotion

If pre-promotion analysis passes:

1. The rollout enters a **paused** state awaiting manual approval.
2. An authorized Release Operator (separate from the code author per segregation of duties) issues:
   ```bash
   kubectl argo rollouts promote forgepay -n forgepay
   ```
3. The `forgepay-active` service selector is atomically switched to the candidate ReplicaSet.
4. All ingress traffic now flows to the new revision.

### Phase 4: Post-Promotion Analysis

After promotion, a second round of the same `forgepay-release-health` analysis runs against the now-active candidate:

- 5-minute Prometheus evaluation window with identical thresholds.
- If post-promotion analysis fails, the Rollouts controller automatically reverts the `forgepay-active` service selector to the previous stable ReplicaSet.

### Phase 5: Scale-Down

After successful post-promotion analysis:

- The previous stable ReplicaSet is retained for `scaleDownDelaySeconds` (900s / 15 minutes).
- This prevents cold-start delays if an immediate rollback is needed.
- After the delay window expires, the previous ReplicaSet is scaled to zero.

---

## Rollback Procedure

If a blue-green deployment must be rolled back (either automatically via failed analysis or manually):

1. **Automatic Rollback:** The Argo Rollouts controller reverts the `forgepay-active` service selector to the last known stable ReplicaSet. No pod restart required — the stable pods are still running.
2. **Manual Rollback:**
   ```bash
   kubectl argo rollouts abort forgepay -n forgepay
   ```
3. **GitOps Rollback:** Revert the image digest in the environment Kustomize overlay to the previous verified digest and allow ArgoCD to reconcile.

Detailed rollback procedures: [`runbooks/progressive-delivery-rollback.md`](../../runbooks/progressive-delivery-rollback.md).

---

## Environment Applicability

| Environment   | Strategy    | Promotion Gate | Rationale                                        |
| :------------ | :---------- | :------------- | :----------------------------------------------- |
| `dev`         | Blue-Green  | Manual         | Developer verification before integration merge  |
| `staging`     | Blue-Green  | Manual         | QA and compliance team sign-off before production |
| `production`  | Canary      | Automated      | See [02-canary-progression.md](02-canary-progression.md) |
