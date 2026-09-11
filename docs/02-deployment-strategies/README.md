# ForgePay Deployment Strategies

## AI Attribution Block

AI-assisted operational and deployment architecture specification. All rollout specifications, traffic weight percentages, analysis queries, and promotion parameters describe target configurations for Argo Rollouts on AWS EKS; they do not assert that active deployments or cluster controllers are running.

---

## Overview

ForgePay utilizes **Argo Rollouts** to deliver application updates safely to Kubernetes without downtime. Depending on the environment risk profile and database compatibility phase, two progressive delivery strategies are supported:

1. **Blue-Green Deployment:** Used primarily in development and staging environments where high confidence, full isolation, and immediate manual verification on a standalone preview service are required prior to cutover.
2. **Canary Deployment:** Used in production environments to expose new releases to real user traffic in incremental steps (10% $\to$ 25% $\to$ 50% $\to$ 100%) backed by automated 5-minute Prometheus health evaluations at every step.

---

## Document Map

| Document | Scope | Target Controller |
| :--- | :--- | :--- |
| [01-blue-green-strategy.md](01-blue-green-strategy.md) | Blue-green rollout mechanics, preview services, manual promotion gates, and scale-down delay buffers | Argo Rollouts (`strategy.blueGreen`) |
| [02-canary-progression.md](02-canary-progression.md) | Stepwise canary weighting, automated metric analysis windows, abort thresholds, and failure recovery | Argo Rollouts (`strategy.canary`) |

---

## Strategy Comparison Matrix

| Attribute | Blue-Green (`dev` / `staging`) | Canary (`production`) |
| :--- | :--- | :--- |
| **Active Service** | `forgepay-active` | `forgepay-active` |
| **Preview/Canary Service** | `forgepay-preview` | `forgepay-preview` |
| **Promotion Gate** | Manual approval (`autoPromotionEnabled: false`) | Automated metric progression via Prometheus analysis |
| **Traffic Split** | 0% or 100% binary cutover | 10%, 25%, 50%, 100% incremental weighting |
| **Step Pauses** | Manual hold after pre-promotion analysis | 2-minute hold between steps |
| **Pre-Promotion Analysis** | 2 health checks (30s) + 5m Prometheus analysis | Synthetic health check probe |
| **Post-Promotion Analysis** | 5m Prometheus analysis on active service | 5m Prometheus analysis per step + 15m post-100% |
| **Rollback Mechanism** | Revert active service selector to prior ReplicaSet | Abort rollout; route 100% traffic to stable ReplicaSet |
| **Cold-Start Buffer** | 900s (`scaleDownDelaySeconds`) | 900s (`abortScaleDownDelaySeconds`) |
