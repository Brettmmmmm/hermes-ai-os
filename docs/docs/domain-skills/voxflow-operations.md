# VoxFlow Operations Skill

## Purpose

The `voxflow-operations` skill provides full lifecycle management of the VoxFlow / InfraForesight QoS-aware enterprise CPaaS platform. It covers deployment automation, health monitoring, QoS compliance verification, troubleshooting, and operational readiness for the 9-microservice, multi-cloud platform.

## Platform Context

VoxFlow is Brett Moore's enterprise CPaaS/uCaaS platform:

- **9 microservices:** Gateway, Tenant Manager, Call Control, WhatsApp, RCS, Media Processor, QoS Classifier, Analytics, Billing
- **Multi-cloud:** AWS, Azure, GCP via Pulumi IaC
- **Media/Signaling:** FreeSWITCH + Kamailio
- **QoS:** eBPF DSCP marking via Cilium
- **Observability:** Vector + Grafana + TimescaleDB hypertables

## When to Use

- Daily health checks (full platform sweep)
- QoS compliance verification
- Deployment and demo startup
- Cross-cloud VPN tunnel health
- API key cache hit ratio monitoring
- Tenant usage anomaly detection
- Pre-deployment checklist verification
- Incident response and root cause analysis

## Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | string | yes | One of: `health-check`, `qos-compliance`, `deploy`, `demo-start`, `incident`, `checklist`, `tunnel-check` |
| `service` | string | no | Specific service to target (defaults to all 9) |
| `incident_id` | string | for `incident` | Incident reference for RCA |
| `logs` | string | no | Relevant log excerpts for diagnosis |
| `environment` | string | no | Target environment (dev, staging, prod) |

## Outputs

All outputs follow the enforced structure: **Platform Status → Findings → Actions → Verification**

### Health Check Output
- Service-by-service status (healthy/degraded/down)
- Redis connection state (keyPrefix: 'vf:')
- PostgreSQL pool metrics
- eBPF DSCP marking status
- Cross-cloud VPN tunnel status
- Grafana dashboard provisioning status

### QoS Compliance Output
- DSCP marking status per cloud
- QoS policy propagation state
- SLA breach timeline review
- Call quality map assessment

## Policy

- **Personality:** operator
- **Default Model:** ollama:kimi-k2.6:cloud
- **Output Format:** markdown
- **Required Structure:** Platform Status → Findings → Actions → Verification
- Every action includes explicit verification steps
- Deployment actions include rollback checkpoints
- Health checks produce actionable pass/fail with remediation guidance

## Example Usage

```bash
# Full platform health check
hermes run --skill voxflow-operations \
  --input '{"task": "health-check"}'

# QoS compliance verification
hermes run --skill voxflow-operations \
  --input '{"task": "qos-compliance"}'

# Demo startup (all 9 services)
hermes run --skill voxflow-operations \
  --input '{"task": "demo-start", "environment": "dev"}'

# Incident response
hermes run --skill voxflow-operations \
  --input '{
    "task": "incident",
    "service": "gateway",
    "incident_id": "INC-2026-0429-01",
    "logs": "Fastify request timeout on tenantApiKey lookup"
  }'

# Pre-deployment checklist
hermes run --skill voxflow-operations \
  --input '{"task": "checklist", "environment": "prod"}'
```

## Deployment Checklist

After any operation, verify:

- All 9 services healthy (health endpoint check)
- Redis connected and responsive
- PostgreSQL pool active (connection count check)
- eBPF DSCP marking operational (Cilium DaemonSet running)
- Grafana dashboards auto-provisioned
- Vector log aggregation flowing
- TimescaleDB hypertable receiving metrics
- Cross-cloud VPN tunnels up (AWS<->Azure<->GCP)
- API key cache hit ratio > 95%

## Known Issues

- **TS6306:** `tsc --noEmit` fails on service packages — use `pnpm test` (vitest) instead
- **Azure Pulumi OOM:** Use `pnpm run typecheck` (has --max-old-space-size=8192)
- **Main branch protected:** Always use feature branches + PRs
- **Fastify request casting:** `(req as Record<string, unknown>).tenantApiKey` — legacy pattern
- **Rate limiter config:** Accepts plain config object, NOT ioredis instance
