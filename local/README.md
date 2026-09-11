# ForgePay Local Infrastructure Emulation (LocalStack)

## AI Attribution Block
AI-assisted local development emulation manifests.

## Overview

This directory provides a lightweight, offline AWS emulation environment utilizing LocalStack:
- **S3 & DynamoDB:** Emulates remote Terraform state storage and state lock tables.
- **KMS:** Emulates Customer Managed Keys (CMK) for secret encryption testing.
- **STS & ECR:** Tests keyless token exchanges locally without incurring AWS cloud charges.

---

## Starting LocalStack

```bash
docker compose -f local/docker-compose.localstack.yml up -d
```
