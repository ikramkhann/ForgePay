# PostgreSQL connection-pool exhaustion

## AI Attribution Block

AI-assisted target runbook. Pool exhaustion is an drill simulation reference, not evidence of a production condition.

1. Confirm active/max >=90% for 5 minutes or pending connections >0 for 5 minutes; correlate query latency, errors, pods, deployment digest and PostgreSQL health.
2. Pause progressive promotion and abort the candidate if it is implicated. Do not restart, terminate sessions, change database configuration, or roll back schema without the database owner and the approved migration process.
3. Capture redacted query/trace evidence and connection-pool configuration for the database owner. Verify pool recovery and API SLI before resuming release activity.
