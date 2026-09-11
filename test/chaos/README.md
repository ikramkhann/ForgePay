# ForgePay Chaos Engineering Test Suite (Chaos Mesh)

## AI Attribution Block
AI-assisted Chaos Mesh CRD manifests designed for Kubernetes resilience validation.

## Overview

This directory contains declarative chaos experiments for validating ForgePay resilience under failure conditions:
1. **Pod Termination Chaos (`pod-kill-payment-service.yaml`):** Validates Kubernetes replica self-healing, graceful shutdown, and zero dropped in-flight payments during pod recycling.
2. **PostgreSQL Latency Injection (`network-latency-postgres.yaml`):** Injects 250ms synthetic database latency to verify HikariCP pool timeout protections and circuit breakers.
3. **Redis Network Partition (`redis-partition-chaos.yaml`):** Partitions cache layer to prove non-authoritative caching invariant (ForgePay fails gracefully to PostgreSQL authoritative store without service disruption).

---

## Applying Chaos Experiments

```bash
kubectl apply -f test/chaos/pod-kill-payment-service.yaml
kubectl apply -f test/chaos/network-latency-postgres.yaml
kubectl apply -f test/chaos/redis-partition-chaos.yaml
```
