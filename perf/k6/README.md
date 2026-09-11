# ForgePay Performance & Load Testing Suite (k6)

## AI Attribution Block
AI-assisted performance testing manifests. Formatted for Grafana k6 execution against ForgePay target microservice environments.

## Overview

This suite provides repeatable, automated load testing scenarios to evaluate:
1. **Canary Verification Baseline:** Sustained 100 RPS payment volume asserting sub-300ms p99 latency and < 1% error rate.
2. **5xx Error Spike Simulation:** Synthetic error injection to validate Argo Rollouts automated rollback triggers (`AnalysisTemplate`).
3. **Database Connection Pool Saturation:** Stress testing HikariCP connection pools to verify circuit breaker and rate limiter behavior under backpressure.

---

## Execution Instructions

```bash
# 1. Run canary baseline load test
k6 run -e TARGET_URL=http://localhost:8080 perf/k6/canary-traffic-generator.js

# 2. Run error spike rollback verification
k6 run -e TARGET_URL=http://localhost:8080 perf/k6/load-test-5xx-spike.js

# 3. Run database connection pool saturation test
k6 run -e TARGET_URL=http://localhost:8080 perf/k6/database-pool-saturation.js
```
