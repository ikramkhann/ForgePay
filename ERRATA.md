# ForgePay Technical Errata Log: Deliberate Technical Defects

> **FORGEPAY - BY FIIFII**

## AI Attribution Block

This document was authored with AI assistance to record the discovery, technical analysis, and resolution of deliberately planted errors in the ForgePay platform codebase. The findings below represent verified static configuration and manifest defects identified and remediated across the code review and finalization cycles.

---

## Overview

In accordance with the ForgePay platform engineering and resilience verification standards, exactly three deliberate technical errors were planted across the repository's configuration and deployment manifests. These errors were designed to evaluate code review diligence, supply chain security enforcement, progressive delivery controller semantics, and Kubernetes networking precision.

This document formally details each of the three errors, their underlying technical cause, compliance/operational impact, and the exact remediation implemented.

---

## Error 1: OPA Image Digest Enforcement Placeholder Bypass

* **Identifier:** `ERR-001`
* **Component:** Policy Gates & Supply Chain Admission
* **Affected File(s):** [`deploy/policy/opa/image_digest.rego`](deploy/policy/opa/image_digest.rego)
* **Status:** Remediated (Fixed by Code Reviewer)

### Original Problem
The Open Policy Agent (OPA) Rego policy intended to validate immutable container image references in Kustomize manifests only checked whether the digest string began with the prefix `sha256:`:

```rego
# Vulnerable rule prior to fix:
deny[msg] {
  input.kind == "Kustomization"
  image := input.images[_]
  not startswith(image.digest, "sha256:")
  msg := sprintf("image %q must use a sha256 digest", [image.name])
}
```

Because environment overlays were committed with the placeholder `digest: sha256:REPLACE_WITH_VERIFIED_DIGEST`, this evaluation evaluated to `true` on the prefix check, permitting unpromoted placeholders to pass policy evaluation.

### Why It Was Incorrect
1. **Supply-Chain Integrity Violation:** Permitted unbuilt, unsigned, and unpromoted container images to satisfy Stage 7 (Policy and Compliance Gates).
2. **False Compliance Verification:** Manifests containing literal placeholder strings would be admitted into cluster deployment pipelines, which would fail only at runtime when kubelet attempted to pull a non-existent digest.
3. **Weak Validation:** The policy failed to validate full hex length (64 characters) or check for sentinel placeholder values.

### Correction Made
An explicit denial rule was added to `deploy/policy/opa/image_digest.rego` to block any image digest containing placeholder strings:

```rego
deny[msg] {
  input.kind == "Kustomization"
  image := input.images[_]
  contains(image.digest, "REPLACE_WITH")
  msg := sprintf("image %q has not been promoted", [image.name])
}
```

Now, any overlay referencing unpromoted placeholders fails Conftest validation immediately during promotion checks.

---

## Error 2: Argo Rollouts Blue-Green Auto-Promotion Default Configuration

* **Identifier:** `ERR-002`
* **Component:** Progressive Delivery & Deployment Strategy
* **Affected File(s):**
  * [`deploy/helm/forgepay/values.yaml`](deploy/helm/forgepay/values.yaml)
  * [`deploy/helm/forgepay/templates/rollout.yaml`](deploy/helm/forgepay/templates/rollout.yaml)
  * [`docs/08-observability/04-verification-and-runtime-dependencies.md`](docs/08-observability/04-verification-and-runtime-dependencies.md)
* **Status:** Remediated (Fixed by Code Reviewer & Harmonized in Phase 1)

### Original Problem
In the workload Helm chart, the blue-green rollout specification did not explicitly disable automatic promotion via `autoPromotionEnabled: false`, or relied on ambiguous timeout settings (`autoPromotionSeconds: 0` or omitting the field).

### Why It Was Incorrect
1. **Unintended Automatic Traffic Shift:** In Argo Rollouts, if `autoPromotionEnabled` is omitted or not explicitly set to `false`, the controller may automatically promote candidate preview pods to active traffic once pre-promotion analysis passes or when `autoPromotionSeconds` expires.
2. **Segregation of Duties Violation:** Under RBI Master Direction and PCI-DSS v4.0 Requirement 6.4/6.5, promoting software to live financial production traffic requires an explicit, auditable human promotion gate independent of the code author. An automatic promotion bypasses this mandatory human gate.
3. **Documentation Drift:** Documentation previously described manual promotion via `autoPromotionSeconds: 0`, which is not the canonical controller parameter for disabling automatic promotion in Argo Rollouts.

### Correction Made
1. In `deploy/helm/forgepay/values.yaml`, explicitly set:
   ```yaml
   rollout:
     strategy: blueGreen
     autoPromotionEnabled: false
     autoPromotionSeconds: 120
   ```
2. In `deploy/helm/forgepay/templates/rollout.yaml`, explicitly bound the controller field:
   ```yaml
   blueGreen:
     activeService: {{ include "forgepay.name" . }}-active
     previewService: {{ include "forgepay.name" . }}-preview
     autoPromotionEnabled: {{ .Values.rollout.autoPromotionEnabled }}
     {{- if .Values.rollout.autoPromotionEnabled }}
     autoPromotionSeconds: {{ .Values.rollout.autoPromotionSeconds }}
     {{- end }}
   ```
3. In `docs/08-observability/04-verification-and-runtime-dependencies.md`, updated the reference table to specify `manual promotion (autoPromotionEnabled: false)`.

---

## Error 3: AnalysisTemplate Preview Health Endpoint Port Omission

* **Identifier:** `ERR-003`
* **Component:** Progressive Delivery Analysis & Rollback Verification
* **Affected File(s):** [`deploy/helm/forgepay/templates/analysis-template.yaml`](deploy/helm/forgepay/templates/analysis-template.yaml)
* **Status:** Remediated (Fixed in Phase 1)

### Original Problem
In `deploy/helm/forgepay/templates/analysis-template.yaml`, the synthetic web health check for candidate preview pods was constructed without specifying a port:

```yaml
# Vulnerable URL definition:
provider:
  web:
    url: http://{{ include "forgepay.name" . }}-preview.{{ .Release.Namespace }}.svc.cluster.local/actuator/health
    jsonPath: '{$.status}'
```

### Why It Was Incorrect
1. **Implicit Port 80 Resolution:** When an HTTP URL omits an explicit port, the HTTP client default is port `80`.
2. **Kubernetes Service Port Mismatch:** In [`deploy/helm/forgepay/templates/service.yaml`](deploy/helm/forgepay/templates/service.yaml), the Service resource exposes:
   ```yaml
   ports: [{ name: http, port: {{ .Values.service.port }}, targetPort: http }]
   ```
   where `values.yaml` sets `service.port: 8080`.
3. **Deterministic Rollout Failure:** The ClusterIP service for `forgepay-preview` does not listen on port 80. Consequently, all HTTP calls to port 80 fail with `connection refused`. Because `failureLimit: 0` is set on the analysis metric, this defect causes every candidate release to fail analysis and abort immediately, creating an artificial release outage.

### Correction Made
Updated line 16 of `deploy/helm/forgepay/templates/analysis-template.yaml` to explicitly include the parameterized service port in the URL:

```yaml
provider:
  web:
    url: http://{{ include "forgepay.name" . }}-preview.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.service.port }}/actuator/health
    jsonPath: '{$.status}'
```

---

## Summary Matrix

| Error ID | Description | Root Cause | Impact | Fix Applied |
| :--- | :--- | :--- | :--- | :--- |
| **ERR-001** | OPA placeholder bypass | Regex checked `startswith("sha256:")` only | Placeholder digests passed policy gate | Added `contains("REPLACE_WITH")` deny rule |
| **ERR-002** | Argo Rollouts auto-promotion default | `autoPromotionEnabled` was not explicitly `false` | Violated manual promotion / segregation of duties | Explicitly enforced `autoPromotionEnabled: false` in values & template |
| **ERR-003** | Preview health probe port omission | URL omitted `:{{ .Values.service.port }}` | Health check defaulted to port 80 $\to$ connection refused $\to$ abort | Added `:{{ .Values.service.port }}` to web probe URL |

No additional deliberate errors exist or were added to the project.
