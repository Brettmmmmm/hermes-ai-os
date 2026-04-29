# VoxFlow Operations Automation Scripts

Production-grade Bash scripts for managing the VoxFlow QoS-aware CPaaS platform.
All scripts are idempotent, have `--help` output, proper exit codes, and use
environment variables for configuration.

---

## Scripts

### 1. `health-check.sh`

Comprehensive health check for all 9 VoxFlow services plus backing services.

**What it checks:**
- All 9 microservice health endpoints (`/health`)
- Redis connectivity (via `redis-cli` or TCP connect fallback)
- PostgreSQL connectivity (via `psql` or TCP connect fallback)
- eBPF/DSCP marking status (Cilium DaemonSet, tc qdisc, iptables mangle rules, N-API)
- Outputs a colour-coded summary table with PASS/FAIL per service
- Exits non-zero if any service is down

**Usage:**
```bash
# Check local defaults
./health-check.sh

# Check a remote host
VF_HOST=10.0.0.1 ./health-check.sh

# JSON output for log aggregation
./health-check.sh --json

# Skip DSCP check
./health-check.sh --no-dscp
```

**Environment Variables:**

| Variable          | Default      | Description            |
|-------------------|--------------|------------------------|
| `VF_HOST`         | localhost    | Service host           |
| `VF_GATEWAY_PORT` | 3000         | Gateway port           |
| `VF_WHATSAPP_PORT`| 3001         | WhatsApp port          |
| `VF_CALLCTRL_PORT`| 3002         | Call Control port      |
| `VF_SIGNALING_PORT`| 3003        | Signaling port         |
| `VF_MEDIA_PORT`   | 3004         | Media port             |
| `VF_AI_PORT`      | 3005         | AI Pipeline port       |
| `VF_RCS_PORT`     | 3006         | RCS port               |
| `VF_TENANT_PORT`  | 3007         | Tenant Manager port    |
| `VF_QOSENGINE_PORT`| 3008        | QoS Engine port        |
| `VF_TIMEOUT_SECS` | 5            | HTTP timeout (seconds) |
| `VF_REDIS_HOST`   | localhost    | Redis host             |
| `VF_REDIS_PORT`   | 6379         | Redis port             |
| `VF_REDIS_PASSWORD`| voxflow_dev | Redis password         |
| `VF_PG_HOST`      | localhost    | PostgreSQL host        |
| `VF_PG_PORT`      | 5432         | PostgreSQL port        |
| `VF_PG_USER`      | voxflow      | PostgreSQL user        |
| `VF_PG_DATABASE`  | voxflow      | PostgreSQL database    |
| `VF_PG_PASSWORD`  | voxflow_dev  | PostgreSQL password    |
| `VF_NO_DSCP_CHECK`| 0            | Skip DSCP check (1=yes)|

**Exit codes:** 0=all healthy, 1=one or more unhealthy, 2=config error, 3=unexpected error

---

### 2. `qos-compliance-check.sh`

Verifies QoS compliance across the VoxFlow deployment.

**What it checks:**
1. Grafana dashboard availability (all 5 expected dashboards)
2. DSCP marking active on all nodes (via Kubernetes DaemonSet or local tc/iptables)
3. Six-class DSCP model correctly configured (EF/46, AF41/34, CS3/24, AF21/18, AF31/26, BE/0)
4. Prometheus QoS metrics availability (MOS scores, DSCP packet counters)
5. QoS alert rules loaded and active

**Usage:**
```bash
# Standard compliance check
./qos-compliance-check.sh

# JSON output for cron/log aggregation
./qos-compliance-check.sh --json >> /var/log/voxflow/qos-$(date +%Y%m%d).log
```

**Environment Variables:**

| Variable               | Default     | Description               |
|------------------------|-------------|---------------------------|
| `VF_HOST`              | localhost   | Service host              |
| `VF_GRAFANA_HOST`      | localhost   | Grafana host              |
| `VF_GRAFANA_PORT`      | 3009        | Grafana port              |
| `VF_GRAFANA_USER`      | admin       | Grafana admin user        |
| `VF_GRAFANA_PASSWORD`  | admin       | Grafana admin password    |
| `VF_PROMETHEUS_HOST`   | localhost   | Prometheus host           |
| `VF_PROMETHEUS_PORT`   | 9090        | Prometheus port           |
| `VF_K8S_CONTEXT`       | (default)   | Kubernetes context        |
| `VF_NODES`             | (auto)      | Comma-separated node list |
| `VF_TIMEOUT`           | 10          | HTTP timeout (seconds)    |

**Exit codes:** 0=compliant, 1=non-compliant, 2=config error

**Six-Class DSCP Model Reference:**

| Class  | DSCP Value | Traffic Type                                |
|--------|-----------|---------------------------------------------|
| EF     | 46        | Voice RTP (G.711, Opus, SILK) — LLQ        |
| AF41   | 34        | Video RTP, Screen Share — CBWFQ             |
| CS3    | 24        | SIP Signaling, ICE/DTLS, SRTP Keying        |
| AF21   | 18        | Real-time STT/TTS, Sentiment Analysis       |
| AF31   | 26        | WhatsApp/RCS Webhooks, CDR Writes           |
| BE     | 0         | Best Effort — Dashboard, Analytics, Bulk    |

---

### 3. `drift-detection.sh`

Compares current infrastructure state against Pulumi stacks across AWS, Azure, and GCP.
Detects configuration drift with severity grading and alerting integration.

**What it does:**
- Runs `pulumi refresh --preview-only --diff` for each cloud stack
- Analyses diffs for additions, updates, and deletions
- Grades severity (info/warning/critical) based on change count and type
- Outputs in format suitable for alerting (Slack webhook, email)
- Works with the existing `.github/workflows/pulumi-preview.yml` CI job

**Usage:**
```bash
# Check all configured stacks
./drift-detection.sh

# Check only AWS
./drift-detection.sh --cloud aws

# Check specific stacks
./drift-detection.sh --stacks aws,gcp

# JSON output
./drift-detection.sh --json

# Set severity threshold (only flag critical+)
./drift-detection.sh --severity critical
```

**Environment Variables:**

| Variable                   | Default     | Description                         |
|----------------------------|-------------|-------------------------------------|
| `VOXFLOW_REPO`             | (auto)      | Path to VoxFlow repository          |
| `PULUMI_ACCESS_TOKEN`      | (required)  | Pulumi Cloud access token           |
| `PULUMI_BACKEND_URL`       | (none)      | Self-hosted backend URL             |
| `SLACK_WEBHOOK_URL`        | (none)      | Slack webhook for alerts            |
| `DRIFT_ALERT_EMAIL`        | (none)      | Email for drift alerts              |
| `DRIFT_SEVERITY_THRESHOLD` | warning     | Min severity: info/warning/critical |

**Severity classification:**
- **info** — No drift or cosmetic changes
- **warning** — Up to 5 additions or up to 3 updates
- **critical** — Any deletions or more than 3 updates

**Exit codes:** 0=no drift, 1=drift detected, 2=config error, 3=Pulumi error

---

### 4. `deploy.sh`

Full deployment pipeline with staged rollout, health verification, and rollback.

**Pipeline stages (8 total):**
1. Pre-deploy health check (all services + Redis + PG)
2. Build Docker images (all 9 services)
3. Run test suite (`pnpm test`)
4. Deploy to staging
5. Verify staging health
6. Prompt for production confirmation
7. Deploy to production (blue/green)
8. Verify production health

**Rollback feature:**
- Automatically records the previous production tag before deployment
- Provides `--rollback` flag for manual rollback
- Auto-rolls back staging or production on health check failure
- Tags releases in git for traceability

**Usage:**
```bash
# Standard deployment
./deploy.sh

# Deploy with specific tag
./deploy.sh --tag v1.2.3

# Fast path: skip staging, skip tests, auto-approve
./deploy.sh --skip-staging --skip-tests --auto-approve-prod

# Rollback to previous version
./deploy.sh --rollback v1.2.2
```

**Environment Variables:**

| Variable            | Default                  | Description                    |
|---------------------|--------------------------|--------------------------------|
| `VOXFLOW_REPO`      | (auto)                   | Path to VoxFlow repo           |
| `VF_HOST`           | localhost                | Health check host              |
| `DOCKER_TAG`        | git SHA                  | Docker image tag               |
| `STAGING_HOST`      | staging.voxflow.internal | Staging host                   |
| `PROD_HOST`         | api.voxflow.io           | Production host                |
| `SKIP_TESTS`        | 0                        | Skip test suite (1=yes)        |
| `SKIP_STAGING`      | 0                        | Skip staging deploy (1=yes)    |
| `AUTO_APPROVE_PROD` | 0                        | Skip production prompt (1=yes) |
| `ROLLBACK_TAG`      | (auto)                   | Rollback target tag            |

**Exit codes:**
- 0=success, 1=failed (rolled back), 2=config error, 3=health check fail,
- 4=build fail, 5=tests fail, 6=staging fail, 7=production fail

---

### 5. `grafana-dashboard-manager.sh`

Backup, restore, and version-control Grafana dashboards.

**Actions:**
| Action      | Description                                          |
|-------------|------------------------------------------------------|
| `backup`    | Export all dashboards as JSON with manifest          |
| `restore`   | Import dashboards from a backup into Grafana         |
| `list`      | List available backups with dates and dashboard count|
| `diff`      | Compare current Grafana dashboards against a backup  |

**Expected dashboards:** voxflow-overview, qos-monitor, sla-compliance, cdr-explorer, call-quality

**Usage:**
```bash
# Backup all dashboards
./grafana-dashboard-manager.sh backup

# Backup with a custom name
./grafana-dashboard-manager.sh backup pre-upgrade-v1.3

# List backups
./grafana-dashboard-manager.sh list

# Diff current state vs latest backup
./grafana-dashboard-manager.sh diff

# Diff against a specific backup
./grafana-dashboard-manager.sh diff 20260429-120000

# Restore from a backup
./grafana-dashboard-manager.sh restore 20260429-120000
```

**Environment Variables:**

| Variable                | Default              | Description                      |
|-------------------------|----------------------|----------------------------------|
| `VF_GRAFANA_URL`        | http://localhost:3009| Grafana base URL                 |
| `VF_GRAFANA_USER`       | admin                | Grafana admin user               |
| `VF_GRAFANA_PASSWORD`   | admin                | Grafana admin password           |
| `VF_GRAFANA_TOKEN`      | (none)               | API token (overrides user/pass)  |
| `VF_DASHBOARD_BACKUP_DIR`| ./grafana-backups   | Backup directory                 |
| `VF_GIT_BACKUP`         | 0                    | Auto-commit to git (1=yes)       |
| `VF_GIT_REMOTE`         | (none)               | Git remote for push              |

**Exit codes:** 0=success, 1=failed, 2=config error, 3=Grafana unreachable

---

## Cron Integration

### Health Check every 5 minutes
```cron
*/5 * * * * /home/brett/hermes-ai-os/tools/voxflow-automation/health-check.sh >> /var/log/voxflow/health-check.log 2>&1
```

### QoS Compliance every 4 hours
```cron
0 */4 * * * /home/brett/hermes-ai-os/tools/voxflow-automation/qos-compliance-check.sh --json >> /var/log/voxflow/qos-compliance.log 2>&1
```

### Drift Detection daily (midnight)
```cron
0 0 * * * /home/brett/hermes-ai-os/tools/voxflow-automation/drift-detection.sh --json >> /var/log/voxflow/drift-detection.log 2>&1
```

### Dashboard Backup daily (2 AM)
```cron
0 2 * * * /home/brett/hermes-ai-os/tools/voxflow-automation/grafana-dashboard-manager.sh backup >> /var/log/voxflow/grafana-backup.log 2>&1
```

### Alert pipeline example
```
# In /etc/cron.d/voxflow-alerts
SHELL=/bin/bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXX/YYY/ZZZ

# Health alert on failure
*/5 * * * * root /home/brett/hermes-ai-os/tools/voxflow-automation/health-check.sh || /usr/local/bin/send-slack-alert.sh "VoxFlow health check FAILED"

# QoS non-compliance alert
30 */4 * * * root /home/brett/hermes-ai-os/tools/voxflow-automation/qos-compliance-check.sh || /usr/local/bin/send-slack-alert.sh "VoxFlow QoS non-compliant"

# Drift alert
15 1 * * * root /home/brett/hermes-ai-os/tools/voxflow-automation/drift-detection.sh || /usr/local/bin/send-slack-alert.sh "VoxFlow infrastructure drift detected"
```

---

## Architecture Notes

These scripts are designed to work with the VoxFlow platform architecture:

- **9 microservices** (gateway, whatsapp, call-control, signaling, media, ai, rcs, tenant-manager, qos-engine)
- All services expose health endpoints via Fastify + `@voxflow/common` HealthManager
- Health endpoints: `/health`, `/health/ready`, `/health/live`, `/health/startup`
- Redis with `keyPrefix: 'vf:'` for caching
- PostgreSQL for relational data
- TimescaleDB for QoS metrics
- eBPF DSCP marking via Cilium DaemonSet (iptables mangle + tc HTB)
- Grafana dashboards auto-provisioned from `/infrastructure/grafana/dashboards/`
- Pulumi infrastructure as code for AWS, Azure, GCP

**Canonical source:** `/home/brett/.openclaw.pre-migration/workspace-infra/voxflow/`

---

## Requirements

- **Bash 4.0+** (associative arrays)
- **curl** — all scripts
- **jq** (optional, fallback available) — for JSON parsing in compliance and dashboard scripts
- **pulumi CLI** — drift-detection.sh
- **docker CLI** — deploy.sh
- **redis-cli / psql** (optional) — health checks fall back to TCP connect if not available
- **kubectl** (optional) — for K8s-aware checks
- **pnpm** (optional) — for running test suite in deploy.sh
