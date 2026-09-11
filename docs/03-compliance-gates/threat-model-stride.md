# ForgePay Threat Modeling & STRIDE Security Analysis

## AI Attribution Block
AI-assisted STRIDE threat analysis. Documents designed security controls for ForgePay payment processing pipelines in accordance with PCI-DSS v4.0 Requirement 6.2 and RBI Cyber Security Guidelines.

---

## 1. System Scope & Trust Boundaries

```
[Untrusted Client Network]
        │ (TLS 1.3 Termination, WAF)
[Edge Ingress Gateway]
        │ (Mutual TLS, NetworkPolicy)
[ForgePay Spring Boot Workload] ─── (IRSA OIDC) ─── [AWS Secrets Manager / KMS]
        │ (Encrypted Pool, Subnet Isolation)
[PostgreSQL 16 Air-Gapped DB]
```

---

## 2. STRIDE Threat Assessment Matrix

| Threat Category | Specific Attack Vector | Mitigating Platform Control | Verification Method |
| :--- | :--- | :--- | :--- |
| **Spoofing** | Forged client identity or impersonated payment partner rail | Mutual TLS (mTLS), HMAC request signing, OAuth2 token validation | Stage 5 Contract Tests & DAST scan |
| **Tampering** | In-flight payload modification or replay of authorization | Strict Idempotency Keys, AES-256 GCM envelope encryption, TLS 1.3 | Pact Verification & Automated Rollback |
| **Repudiation** | Disputed transaction state or denial of transfer initiation | Immutable Ledger architecture, cryptographically signed audit trail | PostgreSQL ACID guarantees & OIDC logs |
| **Information Disclosure** | Leakage of Primary Account Numbers (PAN), CVV, or JWT tokens in logs | OpenTelemetry redaction processors, Falco runtime alerts, KMS encryption | OTel Collector config & Conftest OPA |
| **Denial of Service** | Volumetric payment request floods or connection pool starvation | Nginx rate limiting, HikariCP pool timeouts, HPA auto-scaling | k6 Load & Stress Testing Suite |
| **Elevation of Privilege** | Container escape or unauthorized AWS administrative IAM actions | Read-only container rootfs, non-root user (10001), IRSA least privilege | Kyverno policies & Checkov IaC scans |
