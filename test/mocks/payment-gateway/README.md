# ForgePay Mock Payment Gateway Rail

## AI Attribution Block
AI-assisted mock payment gateway implementation for isolated integration testing.

## Overview

This mock service simulates downstream banking partner rails and payment gateways during local development and automated CI/CD integration testing (Stage 5).

### Features
- Deterministic response simulation (authorizations approved for amounts <= 50,000 INR).
- Health check probe on `/health`.
- Runs as an unprivileged container on port `8088`.
