# ForgePay Database Telemetry & Connection Metrics

## AI Attribution Block
AI-assisted PostgreSQL database metrics views and telemetry extensions.

## Overview

This directory contains SQL definitions for real-time PostgreSQL performance telemetry and active connection pool inspection:
- `pg_stat_statements_setup.sql`: Enables query timing, execution frequency, and cache hit metrics.
- `connection_pool_metrics.sql`: Creates `forgepay_connection_pool_metrics` view queried by Prometheus PostgreSQL exporter to track pool saturation and lock wait events.
