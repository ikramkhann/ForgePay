# Canary Deployment Progression

## AI Attribution Block

AI-assisted canary deployment specification. All traffic weight percentages, analysis query templates, and step durations describe target Argo Rollouts controller behaviour on AWS EKS; no live canary deployments are asserted to be running.

---

## Purpose

Canary deployment exposes a new release to a progressively increasing percentage of real production traffic, validating the candidate revision against live request patterns at each step. Unlike blue-green's binary cutover, canary provides **incremental blast-radius expansion** with automated metric-driven gates and immediate abort capability at every stage.

ForgePay uses canary as the **production** deployment strategy, providing the highest confidence level before full traffic commitment.

---

## Traffic Progression Steps

ForgePay defines a four-step canary progression with automated Prometheus analysis between each step:

```
  10%          25%          50%          100%
   │            │            │             │
   ▼            ▼            ▼             ▼
┌──────┐   ┌──────┐    ┌──────┐     ┌──────────┐
│Step 1│──►│Step 2│───►│Step 3│────►│Full Shift │
│ 10%  │   │ 25%  │    │ 50%  │     │   100%   │
│ 2min │   │ 2min │    │ 2min │     │  15min   │
│pause │   │pause │    │pause │     │ observe  │
└──────┘   └──────┘    └──────┘     └──────────┘
     ↑           ↑           ↑            ↑
  Analysis    Analysis    Analysis    Post-Shift
  Window      Window      Window      Analysis
  (5 min)     (5 min)     (5 min)     (15 min)
```

### Step Configuration

Configured in [`deploy/helm/forgepay/values.yaml`](../../deploy/helm/forgepay/values.yaml):

```yaml
rollout:
  strategy: canary
  canarySteps: [10, 25, 50, 100]
  scaleDownDelaySeconds: 900
  abortScaleDownDelaySeconds: 900
```

Rendered in [`deploy/helm/forgepay/templates/rollout.yaml`](../../deploy/helm/forgepay/templates/rollout.yaml):

```yaml
strategy:
  canary:
    stableService: forgepay-active
    canaryService: forgepay-preview
    analysis:
      templates:
        - templateName: forgepay-release-health
    steps:
      - setWeight: 10
      - pause: { duration: 2m }
      - setWeight: 25
      - pause: { duration: 2m }
      - setWeight: 50
      - pause: { duration: 2m }
      - setWeight: 100
      - pause: { duration: 2m }
```

### Step-by-Step Behavior

| Step | Weight | Pause  | Analysis Duration | Cumulative Time (approx.) |
| :--- | :----- | :----- | :---------------- | :------------------------ |
| 1    | 10%    | 2 min  | 5 min continuous  | ~7 min                    |
| 2    | 25%    | 2 min  | 5 min continuous  | ~14 min                   |
| 3    | 50%    | 2 min  | 5 min continuous  | ~21 min                   |
| 4    | 100%   | 2 min  | 15 min post-shift | ~38 min                   |

**Total canary release duration:** approximately 38 minutes for a fully healthy release.

---

## Automated Metric Analysis

At each canary step, the Argo Rollouts controller executes the [`forgepay-release-health`](../../deploy/helm/forgepay/templates/analysis-template.yaml) AnalysisTemplate. The analysis runs on a continuous 5-minute evaluation window with the following abort thresholds:

### Metric Abort Thresholds

| Metric                        | PromQL Source                                                                 | Abort Threshold | Window  |
| :---------------------------- | :---------------------------------------------------------------------------- | :-------------- | :------ |
| **HTTP 5xx Error Rate**       | `sum(rate(http_server_requests_seconds_count{status=~"5.."}[5m]))`            | > 5.0%          | 5 min   |
| **P99 Request Latency**       | `histogram_quantile(0.99, rate(http_server_requests_seconds_bucket[5m]))`     | > 300 ms        | 5 min   |
| **PostgreSQL Pool Saturation**| `pg_stat_activity_count / pg_settings_max_connections`                         | ≥ 90%           | 5 min   |
| **Payment Gateway Timeouts**  | `sum(rate(payment_gateway_requests_total{outcome="timeout"}[5m]))`            | > 10.0%         | 5 min   |

### Analysis Parameters

From `values.yaml`:

```yaml
observability:
  releaseAnalysis:
    intervalSeconds: 30        # Evaluation interval
    count: 10                  # Number of evaluation cycles (30s × 10 = 5 min)
    maxHttp5xxRate: 0.05       # 5% threshold
    maxP99LatencySeconds: 0.3  # 300ms threshold
    maxPostgresPoolUtilization: 0.9  # 90% threshold
    maxPaymentGatewayTimeoutRate: 0.1  # 10% threshold
```

### Synthetic Health Probe

In addition to Prometheus metric analysis, a synthetic HTTP health check probes the canary endpoint directly:

```yaml
metrics:
  - name: preview-health
    provider:
      web:
        url: http://forgepay-preview.<namespace>.svc.cluster.local:8080/actuator/health
        jsonPath: '{$.status}'
    successCondition: result == "UP"
    count: 2
    interval: 30s
    failureLimit: 0
```

> **Note:** The original configuration omitted the `:8080` port in the URL, causing the probe to default to port 80 and fail with connection refused. This was identified as ERR-003 and remediated. See [`ERRATA.md`](../../ERRATA.md).

---

## Abort and Rollback Behavior

### Automatic Abort

If **any** metric breaches its threshold at **any** canary step:

1. The Argo Rollouts controller immediately sets weight to **0%** for the candidate.
2. All traffic is routed back to the **stable** ReplicaSet (`forgepay-active`).
3. The candidate ReplicaSet is retained for `abortScaleDownDelaySeconds` (900s / 15 minutes) for diagnostic pod inspection.
4. A Prometheus alert fires and the on-call responder is paged.

### Manual Abort

An operator can manually abort a canary at any step:

```bash
kubectl argo rollouts abort forgepay -n forgepay
```

### Recovery After Abort

After an abort:

1. Confirm stable service health:
   ```bash
   kubectl argo rollouts status forgepay -n forgepay
   curl -s http://forgepay-active.forgepay.svc.cluster.local:8080/actuator/health
   ```
2. Investigate candidate failure in retained pods (within the 900s window).
3. Fix the issue in a new commit and allow the next CI/CD cycle to produce a new candidate digest.

See [`runbooks/progressive-delivery-rollback.md`](../../runbooks/progressive-delivery-rollback.md) for the full operational runbook.

---

## Post-100% Observation Window

After the canary reaches 100% and the final 2-minute pause completes:

1. A **15-minute post-shift analysis** window runs the same `forgepay-release-health` template.
2. This extended observation period catches latent issues that only manifest under full production load.
3. If the 15-minute analysis passes, the rollout is marked as **complete** and the previous stable ReplicaSet enters the `scaleDownDelaySeconds` countdown.
4. If the analysis fails, an automatic rollback occurs to the previous stable revision.

---

## Canary vs. Blue-Green Comparison

| Attribute                | Blue-Green (dev/staging)         | Canary (production)               |
| :----------------------- | :------------------------------- | :-------------------------------- |
| **Traffic Model**        | Binary 0% ↔ 100% cutover        | Incremental 10→25→50→100%         |
| **Blast Radius**         | Full environment                 | Progressively expanding           |
| **Promotion Gate**       | Manual operator approval         | Automated metric-driven           |
| **Rollback Speed**       | Instant (service selector swap)  | Instant (weight → 0%)             |
| **Observation Time**     | 5-min pre + 5-min post           | ~38 min total with 15-min tail    |
| **Best For**             | Pre-production verification      | Production with live traffic       |

For blue-green details, see [01-blue-green-strategy.md](01-blue-green-strategy.md).
