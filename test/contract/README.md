# ForgePay Consumer-Driven Contract Testing (Pact)

## AI Attribution Block
AI-assisted consumer-driven contract test definitions. Formats reflect Pact Specification v3.0 schemas for ForgePay microservices.

## Overview

This directory contains consumer-driven contract definitions for ForgePay's core domain integrations, ensuring backward and forward API compatibility between:
1. **ForgePay Core <-> Payment Gateway Rails**
2. **ForgePay Core <-> Accounts & Ledger Service**

Contract testing runs in **Stage 5 (Integration & Contract Testing)** of the canonical CI pipeline before deployment to prevent breaking API changes from propagating downstream.

---

## Contract Files

- `forgepay_accounts_pact.json`: Pact specification between `ForgePay-Core` (Consumer) and `AccountsService` (Provider).
- `forgepay_payment_gateway_pact.json`: Pact specification between `ForgePay-Core` (Consumer) and `PaymentGateway-Rail` (Provider).
