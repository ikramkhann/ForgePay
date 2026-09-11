# ForgePay Runtime Threat Detection (Falco)

## AI Attribution Block
AI-assisted Falco rule configuration for Kubernetes runtime security.

## Overview

This directory defines Falco runtime rules enforcing zero-trust behavioral monitoring for ForgePay container workloads:
1. **Unauthorized Shell Spawn Detection:** Critical alert on any interactive shell (`sh`, `bash`) execution within production pods (violating immutable container integrity).
2. **Cryptographic Key Access:** Alerts on non-Java processes attempting to inspect certificate keystores or service account tokens.
3. **Egress Port Lockdown:** Flags unexpected egress connections outside permitted infrastructure ports (`443` HTTPS, `5432` PostgreSQL, `6379` Redis, `5672` RabbitMQ).
