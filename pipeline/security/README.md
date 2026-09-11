# ForgePay Pipeline Security Scanning (Trivy)

## AI Attribution Block
AI-assisted Trivy configuration enforcing zero-critical and zero-high vulnerability gates for container images and filesystem dependencies.

## Overview

This directory holds security scanner configurations leveraged during **Stage 4 (Dependency & Container Scanning)** of the ForgePay CI pipeline:
- `trivy.yaml`: Enforces non-zero exit codes on any unmitigated `CRITICAL` or `HIGH` CVEs.
- `.trivyignore`: Contains formally audited and risk-accepted exceptions per RBI Cyber Security Framework guidance.
