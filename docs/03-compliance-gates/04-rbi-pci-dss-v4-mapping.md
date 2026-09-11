# RBI and PCI-DSS v4.0 design mapping

## AI Attribution Block

Platform regulatory mapping specification, not legal advice, an RBI determination, a PCI-DSS attestation, or compliance evidence. A qualified compliance owner must determine scope and applicable requirements.

| Control intent | ForgePay design artifact | PCI-DSS v4.0 theme | RBI relevance | Evidence still required |
| --- | --- | --- | --- | --- |
| Unique, least-privilege privileged access | IAM/OIDC templates and role matrix | Req. 7, 8 | Access control and accountability expectations | Approved policies, identity inventory, role assignments, review records |
| MFA and emergency access governance | Break-glass procedure | Req. 8 | Privileged access governance | MFA settings, activation/review evidence |
| Protect secrets/keys | Secret/KMS ownership boundary | Req. 3, 4 | Encryption/key-management expectations | Key policies, rotation, encryption and secret-access records |
| Secure software supply chain | Signed digest, SBOM, provenance and Kyverno template | Req. 6 | Secure development/change governance | Scan, signing, admission and change records |
| Segregated change/deployment control | GitHub Environment + GitOps approvals | Req. 6, 7 | Change management/accountability | Ruleset/environment configuration and approval trail |
| Auditability | Required GitHub/AWS/EKS/ArgoCD/KMS logs | Req. 10 | Audit trail and incident oversight expectations | Log configuration, retention, sampled events and review records |
| Vulnerability and configuration governance | Existing CI gates, access reviews | Req. 6, 11 | Cybersecurity control expectations | Tool outputs, exceptions, remediation and review evidence |

PCI scope depends on whether cardholder data, payment account data or connected systems enter ForgePay. RBI applicability, data residency, outsourcing, incident reporting, retention and cryptographic requirements need formal legal/compliance assessment. No table entry proves compliance.
