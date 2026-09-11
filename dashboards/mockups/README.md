# Dashboard mockups

## AI Attribution Block

AI-assisted dashboard wireframes. They are design references only; no values, alerts, deployments, telemetry, SLO attainment, PCI-DSS or RBI compliance outcome is depicted or asserted.

## Engineering

```text
[ Availability SLI 30d ] [ 5xx 5m ] [ p99 latency ] [ pool utilisation ]
[ payment timeout trend                  ] [ rollout phase / release digest ]
[ Loki redacted log drill-down           ] [ Jaeger trace drill-down         ]
```

## Management

```text
[ deployment frequency ] [ lead-time p50/p90 ] [ change failure rate ] [ restore p90 ]
[ verified promotions and failed gates ] [ error-budget policy state ]
```

## Regulatory

```text
[ verification audit trail ] [ source/digest/release correlation ]
[ redaction-control findings ] [ approved audit-log and trace lookup ]
```

Each live dashboard requires approved, separately configured Prometheus, Loki and Jaeger data sources and role-based access under the existing identity model.
