-- AI Attribution Block: AI-assisted database active connection & lock contention view.
CREATE OR REPLACE VIEW forgepay_connection_pool_metrics AS
SELECT
  count(*) FILTER (WHERE state = 'active') AS active_connections,
  count(*) FILTER (WHERE state = 'idle') AS idle_connections,
  count(*) FILTER (WHERE state = 'idle in transaction') AS idle_in_transaction_connections,
  count(*) FILTER (WHERE wait_event_type IS NOT NULL) AS waiting_connections,
  (SELECT setting::int FROM pg_settings WHERE name = 'max_connections') AS max_connections
FROM pg_stat_activity
WHERE datname = current_database();
