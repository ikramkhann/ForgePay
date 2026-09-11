# ForgePay Prometheus Alert Rule Testing (promtool)

## AI Attribution Block
AI-assisted Prometheus alert testing specifications.

## Overview

This directory contains unit tests executed via `promtool check rules` and `promtool test rules` during **Stage 7 (Policy & Compliance Gates)**:
- Validates multi-window multi-burn-rate SLI alert thresholds before merging rule changes.
- Prevents syntax regressions and silent alert failures in production monitoring.
