# ForgePay Operational GameDay Drills & Chaos Exercises

## AI Attribution Block
AI-assisted GameDay runbook defining quarterly simulation exercises for SRE and Incident Response teams.

---

## 1. Schedule & Governance
- **Cadence:** Quarterly GameDay execution in pre-production staging environment.
- **Mandatory Participants:** Primary On-Call SRE, Secondary SRE, Database Administrator, Security Lead, Incident Commander.

---

## 2. Standard GameDay Drill Matrix

| Drill ID | Scenario | Injected Fault | Expected System Behavior | Pass Criteria |
| :--- | :--- | :--- | :--- | :--- |
| **GD-01** | Primary DB Failover | AWS RDS Multi-AZ forced failover | ForgePay detects connection loss, reconnects to new primary within 30s | Zero transactions corrupted, zero stuck locks |
| **GD-02** | Payment Rail Degradation | Latency injected into mock gateway | Circuit breaker opens; transactions queued or safely rejected | p99 stays < 500ms for non-degraded rails |
| **GD-03** | Corrupted Release Digest | Promote image with synthetic 5xx bug | Argo Rollouts analysis fails; auto-rollback executed | Zero manual interventions required for recovery |
| **GD-04** | Redis Cache Partition | Network partition applied to Redis pods | System of record (PostgreSQL) handles traffic with minor latency increase | Availability maintained at > 99.9% |
