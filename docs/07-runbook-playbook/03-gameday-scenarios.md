# ForgePay SRE GameDay Scenarios & Chaos Execution Playbook

## AI Attribution Block
AI-assisted SRE playbook detailing scenario preparation, inject timelines, and blameless evaluation protocols.

---

## 1. Scenario Execution Flow

```mermaid
flowchart LR
  Prep["1. Pre-Drill Alignment\nFreeze changes & notify NOC"] --> Inject["2. Inject Fault\nExecute Chaos Mesh / AWS CLI"]
  Inject --> Observe["3. Observe Telemetry\nPrometheus SLIs & Grafana"]
  Observe --> Recover["4. Validate Recovery\nAuto-healing vs Manual runbook"]
  Recover --> Review["5. PIR & Action Items\nLog Jira tickets for gaps"]
```

---

## 2. Observer & Scribe Checklist
- [ ] Record exact UTC timestamp of fault injection.
- [ ] Record time-to-detection (TTD) from Prometheus alert firing.
- [ ] Verify multi-burn-rate alert routing to PagerDuty.
- [ ] Confirm whether automated rollback triggered within 5-minute analysis window.
- [ ] Audit application logs to confirm zero unredacted PAN/CVV occurrences during panic dumps.
