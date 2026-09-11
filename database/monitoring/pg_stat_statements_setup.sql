-- AI Attribution Block: AI-assisted PostgreSQL performance & query telemetry setup.
-- Configures pg_stat_statements for ForgePay PostgreSQL 16 database.

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Grant read-only telemetry access to monitoring role
GRANT SELECT ON pg_stat_statements TO forgepay_monitor;

-- Sample query to inspect slowest financial transaction queries
-- SELECT query, calls, total_exec_time, mean_exec_time, rows
-- FROM pg_stat_statements
-- ORDER BY total_exec_time DESC
-- LIMIT 20;
