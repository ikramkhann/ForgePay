# HTTP 5xx / latency release rollback

## AI Attribution Block

AI-assisted target runbook. The 12% HTTP 500 condition is an drill simulation reference, not evidence of an incident or alert.

1. Confirm HTTP 5xx >5% for 5 minutes or p99 latency >300ms for 5 minutes using Prometheus; inspect release digest, rollout phase, traces and redacted Loki logs.
2. For a canary, Argo Rollouts analysis should abort and retain stable traffic. For blue-green, do not promote the preview; if already promoted, restore the stable application revision/service selection through the approved GitOps/Rollouts path.
3. Verify two health checks, then observe the restored stable revision for 15 minutes. Record the actual verification outcome.
4. Do not perform a database rollback. Escalate to the database migration runbook only if an approved migration is involved; expand-contract compatibility governs the application rollback window.
