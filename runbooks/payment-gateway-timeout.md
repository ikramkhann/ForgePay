# Payment gateway timeout response

## AI Attribution Block

AI-assisted target runbook. The 35% timeout condition is an drill simulation reference, not evidence of a production incident or alert.

1. Confirm payment gateway timeout rate >10% for 5 minutes, distinguishing gateway timeouts from application 5xx responses.
2. Inspect gateway outcome metrics, redacted traces, idempotency behavior and current rollout digest. Do not log payment credentials or payloads.
3. Abort an implicated candidate release; retain/restore stable traffic through the existing progressive-delivery path. Use the 15-minute post-deployment observation window before declaring recovery.
4. Escalate the dependency through the approved operational channel and record actual customer impact, timestamps and gateway correlation references.
