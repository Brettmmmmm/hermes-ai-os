#!/usr/bin/env bash
# ==============================================================================
# VoxFlow Drift Detection — v1.0.0
# ==============================================================================
# Compares current infrastructure state against Pulumi stacks across AWS, Azure,
# and GCP. Detects configuration drift and outputs in format suitable for
# alerting pipelines (PagerDuty, Slack webhook, email).
#
# Works with the existing pulumi-drift-detection cron job:
#   .github/workflows/pulumi-preview.yml
#
# Environment variables:
#   VOXFLOW_REPO             — Path to VoxFlow repo (default: auto-detect)
#   PULUMI_ACCESS_TOKEN      — Pulumi Cloud access token (required for cloud)
#   PULUMI_BACKEND_URL       — Self-hosted backend URL (optional)
#   SLACK_WEBHOOK_URL        — Slack webhook for alerts (optional)
#   DRIFT_ALERT_EMAIL        — Email for drift alerts (optional)
#   DRIFT_SEVERITY_THRESHOLD — 'info'|'warning'|'critical' (default: warning)
#
# Exit codes:
#   0 — No drift detected
#   1 — Drift detected (one or more stacks)
#   2 — Configuration error
#   3 — Pulumi command failed
#   130 — User interrupt
#
# Usage:
#   ./drift-detection.sh
#   ./drift-detection.sh --json
#   ./drift-detection.sh --cloud aws     # Check only AWS
#   ./drift-detection.sh --stacks gcp,aws
# ==============================================================================

set -uo pipefail

# ── Colour definitions ────────────────────────────────────────────────────────
if [[ -t 2 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; NC=''
fi

# ── Configuration ─────────────────────────────────────────────────────────────
JSON_MODE=false
TARGET_STACKS=""
DRIFT_SEVERITY_THRESHOLD="${DRIFT_SEVERITY_THRESHOLD:-warning}"

# Auto-detect VoxFlow repo
if [[ -d /home/brett/.openclaw.pre-migration/workspace-infra/voxflow ]]; then
    VOXFLOW_REPO="${VOXFLOW_REPO:-/home/brett/.openclaw.pre-migration/workspace-infra/voxflow}"
elif [[ -d "${VOXFLOW_REPO:-}" ]]; then
    :  # Use env-provided path
else
    VOXFLOW_REPO="$(pwd)"
fi

# Pulumi infra directories
declare -A PULUMI_DIRS
PULUMI_DIRS[gcp]="${VOXFLOW_REPO}/infrastructure/gcp"
PULUMI_DIRS[aws]="${VOXFLOW_REPO}/infrastructure/aws"
PULUMI_DIRS[azure]="${VOXFLOW_REPO}/infrastructure/azure"

# Drift results
declare -A DRIFT_RESULTS
declare -A DRIFT_DETAILS
declare -A DRIFT_SEVERITY
STACKS_CHECKED=0
STACKS_WITH_DRIFT=0
STACKS_ERROR=0

# ── Help ──────────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'
Usage: drift-detection.sh [OPTIONS]

Detect infrastructure configuration drift across AWS/Azure/GCP Pulumi stacks.

Options:
  --json              Output results as JSON
  --cloud CLOUD       Check only one cloud (aws|azure|gcp)
  --stacks STACKS     Comma-separated stack list (e.g. gcp,aws)
  --severity LEVEL    Minimum severity to flag (info|warning|critical; default: warning)
  -h, --help          Show this help

Environment variables:
  VOXFLOW_REPO              Path to VoxFlow repo
  PULUMI_ACCESS_TOKEN       Pulumi Cloud access token
  PULUMI_BACKEND_URL        Self-hosted backend URL
  SLACK_WEBHOOK_URL         Slack webhook for alerts
  DRIFT_ALERT_EMAIL         Email for drift alerts
  DRIFT_SEVERITY_THRESHOLD  Minimum severity (default: warning)

Exit codes:
  0  No drift detected
  1  Drift detected
  2  Configuration error
  3  Pulumi error
EOF
    exit 0
}

# ── Parse arguments ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)
            JSON_MODE=true
            shift
            ;;
        --cloud)
            TARGET_STACKS="$2"
            shift 2
            ;;
        --stacks)
            TARGET_STACKS="$2"
            shift 2
            ;;
        --severity)
            DRIFT_SEVERITY_THRESHOLD="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Run with --help for usage" >&2
            exit 2
            ;;
    esac
done

# ── Prerequisites ─────────────────────────────────────────────────────────────
if ! command -v pulumi &>/dev/null; then
    echo "ERROR: pulumi CLI is required but not installed" >&2
    echo "Install: curl -fsSL https://get.pulumi.com | sh" >&2
    exit 2
fi

if [[ ! -d "$VOXFLOW_REPO" ]]; then
    echo "ERROR: VoxFlow repo not found at $VOXFLOW_REPO" >&2
    echo "Set VOXFLOW_REPO environment variable" >&2
    exit 2
fi

# ── Determine which stacks to check ───────────────────────────────────────────
if [[ -z "$TARGET_STACKS" ]]; then
    # All stacks that have Pulumi.yaml
    TARGET_STACKS=""
    for cloud in gcp aws azure; do
        if [[ -f "${PULUMI_DIRS[$cloud]}/Pulumi.yaml" ]]; then
            [[ -n "$TARGET_STACKS" ]] && TARGET_STACKS+=","
            TARGET_STACKS+="$cloud"
        fi
    done
    if [[ -z "$TARGET_STACKS" ]]; then
        echo "ERROR: No Pulumi stacks found in $VOXFLOW_REPO/infrastructure/" >&2
        exit 2
    fi
fi

# ── Severity numeric mapping ──────────────────────────────────────────────────
severity_num() {
    case "$1" in
        info)     echo 1;;
        warning)  echo 2;;
        critical) echo 3;;
        *)        echo 0;;
    esac
}

# ── Check a single Pulumi stack ───────────────────────────────────────────────
check_stack() {
    local cloud="$1"
    local dir="${PULUMI_DIRS[$cloud]}"
    local stack_name="voxflow-${cloud}"

    if [[ ! -d "$dir" ]]; then
        DRIFT_RESULTS["$cloud"]="SKIP"
        DRIFT_DETAILS["$cloud"]="Infrastructure directory not found"
        return
    fi

    if [[ ! -f "${dir}/Pulumi.yaml" ]]; then
        DRIFT_RESULTS["$cloud"]="SKIP"
        DRIFT_DETAILS["$cloud"]="No Pulumi.yaml"
        return
    fi

    # Ensure pnpm/node_modules exist
    if [[ ! -d "${dir}/node_modules" ]]; then
        echo "  ${YELLOW}⚠${NC} Installing dependencies for $cloud..." >&2
        (cd "$dir" && pnpm install --frozen-lockfile &>/dev/null) || {
            DRIFT_RESULTS["$cloud"]="ERROR"
            DRIFT_DETAILS["$cloud"]="Failed to install dependencies"
            ((STACKS_ERROR++))
            return
        }
    fi

    # Run pulumi refresh --preview-only (non-destructive drift check)
    local pulumi_output
    pulumi_output=$(cd "$dir" && pulumi refresh --preview-only --diff 2>&1) || {
        local exit_code=$?
        DRIFT_RESULTS["$cloud"]="ERROR"
        DRIFT_DETAILS["$cloud"]="pulumi refresh failed (exit $exit_code): ${pulumi_output:0:200}"
        ((STACKS_ERROR++))
        return
    }

    ((STACKS_CHECKED++))

    # Analyse output for drift indicators
    if echo "$pulumi_output" | grep -q "no changes"; then
        DRIFT_RESULTS["$cloud"]="OK"
        DRIFT_DETAILS["$cloud"]="No drift detected"
        DRIFT_SEVERITY["$cloud"]="info"
        return
    fi

    # Count the number of changes
    local changes_added=0 changes_updated=0 changes_deleted=0
    changes_added=$(echo "$pulumi_output" | grep -c "+ " 2>/dev/null || echo 0)
    changes_updated=$(echo "$pulumi_output" | grep -c "~ " 2>/dev/null || echo 0)
    changes_deleted=$(echo "$pulumi_output" | grep -c "- " 2>/dev/null || echo 0)

    local total_changes=$((changes_added + changes_updated + changes_deleted))

    if (( total_changes == 0 )); then
        DRIFT_RESULTS["$cloud"]="OK"
        DRIFT_DETAILS["$cloud"]="No drift detected"
        DRIFT_SEVERITY["$cloud"]="info"
        return
    fi

    # Determine severity based on change count and type
    local severity="info"
    if (( changes_deleted > 0 )); then
        severity="critical"
    elif (( changes_updated > 3 )); then
        severity="critical"
    elif (( changes_updated > 0 )); then
        severity="warning"
    elif (( changes_added > 5 )); then
        severity="warning"
    fi

    DRIFT_RESULTS["$cloud"]="DRIFT"
    DRIFT_DETAILS["$cloud"]="${total_changes} changes: +${changes_added} ~${changes_updated} -${changes_deleted}"
    DRIFT_SEVERITY["$cloud"]="$severity"
    ((STACKS_WITH_DRIFT++))
}

# ── JSON output ───────────────────────────────────────────────────────────────
print_json_output() {
    echo "{"
    echo '  "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",'
    echo '  "voxflow_repo": "'"$VOXFLOW_REPO"'",'
    echo '  "stacks_checked": '"$STACKS_CHECKED"','
    echo '  "stacks_with_drift": '"$STACKS_WITH_DRIFT"','
    echo '  "stacks_with_error": '"$STACKS_ERROR"','
    echo '  "stacks": {'
    local first=true
    for cloud in gcp aws azure; do
        local result="${DRIFT_RESULTS[$cloud]:-SKIP}"
        local detail="${DRIFT_DETAILS[$cloud]:-Not checked}"
        local severity="${DRIFT_SEVERITY[$cloud]:-info}"
        [[ "$result" == "SKIP" ]] && continue
        [[ "$first" == false ]] && echo ","
        first=false
        printf '    "%s": {"status": "%s", "severity": "%s", "detail": "%s"}' \
            "$cloud" "$result" "$severity" "$detail"
    done
    echo ""
    echo '  }'
    echo "}"
}

# ── Slack alert ───────────────────────────────────────────────────────────────
send_slack_alert() {
    local slack_url="${SLACK_WEBHOOK_URL:-}"
    if [[ -z "$slack_url" ]]; then
        return 0
    fi

    local message="🚨 *VoxFlow Configuration Drift Detected*\n\n"
    message+="*Timestamp:* $(date -u +%Y-%m-%dT%H:%M:%SZ)\n"

    for cloud in gcp aws azure; do
        local result="${DRIFT_RESULTS[$cloud]:-SKIP}"
        [[ "$result" != "DRIFT" ]] && continue
        local detail="${DRIFT_DETAILS[$cloud]}"
        local sev="${DRIFT_SEVERITY[$cloud]}"
        message+="• *${cloud}:* ${detail} (${sev})\n"
    done

    curl -s -X POST -H 'Content-Type: application/json' \
        -d "{\"text\": \"${message}\"}" "$slack_url" &>/dev/null || true
}

# ── Main execution ────────────────────────────────────────────────────────────
IFS=',' read -ra STACK_ARRAY <<< "$TARGET_STACKS"

echo ""
echo -e "${BOLD}═══ VoxFlow Infrastructure Drift Detection ═══${NC}"
echo "Date: $(date)"
echo "Repo: $VOXFLOW_REPO"
echo "Stacks: ${TARGET_STACKS}"
echo ""

for cloud in "${STACK_ARRAY[@]}"; do
    cloud="${cloud## }"  # trim leading space
    cloud="${cloud%% }"  # trim trailing space
    echo -e "${BOLD}[${cloud}]${NC} Checking ${cloud} stack..."
    check_stack "$cloud"

    case "${DRIFT_RESULTS[$cloud]:-SKIP}" in
        OK)
            echo -e "  ${GREEN}✓${NC} ${cloud}: NO DRIFT"
            ;;
        DRIFT)
            local sev="${DRIFT_SEVERITY[$cloud]}"
            local sev_colour="${YELLOW}"
            [[ "$sev" == "critical" ]] && sev_colour="${RED}"
            echo -e "  ${sev_colour}⚠${NC} ${cloud}: DRIFT DETECTED (${sev}) — ${DRIFT_DETAILS[$cloud]}"
            ;;
        ERROR)
            echo -e "  ${RED}✗${NC} ${cloud}: ERROR — ${DRIFT_DETAILS[$cloud]}"
            ;;
        SKIP)
            echo -e "  ${CYAN}○${NC} ${cloud}: SKIPPED — ${DRIFT_DETAILS[$cloud]:-not configured}"
            ;;
    esac
    echo ""
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════"
echo -e "  Stacks checked:  $STACKS_CHECKED"
echo -e "  ${GREEN}No drift:${NC}       $(( STACKS_CHECKED - STACKS_WITH_DRIFT - STACKS_ERROR ))"
echo -e "  ${RED}Drift detected:${NC}  $STACKS_WITH_DRIFT"
echo -e "  ${YELLOW}Errors:${NC}          $STACKS_ERROR"
echo "═══════════════════════════════════════════════════"
echo ""

# ── Alerting ──────────────────────────────────────────────────────────────────
if (( STACKS_WITH_DRIFT > 0 )); then
    # Apply severity threshold filter
    local threshold_num
    threshold_num=$(severity_num "$DRIFT_SEVERITY_THRESHOLD")

    local actionable_drift=0
    for cloud in gcp aws azure; do
        [[ "${DRIFT_RESULTS[$cloud]:-SKIP}" != "DRIFT" ]] && continue
        local sev_num
        sev_num=$(severity_num "${DRIFT_SEVERITY[$cloud]}")
        if (( sev_num >= threshold_num )); then
            ((actionable_drift++))
        fi
    done

    if (( actionable_drift > 0 )); then
        # Send Slack alert if webhook configured
        if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
            echo -e "${CYAN}→${NC} Sending Slack alert..."
            send_slack_alert
        fi

        # Email alert placeholder
        if [[ -n "${DRIFT_ALERT_EMAIL:-}" ]] && command -v mail &>/dev/null; then
            echo "VoxFlow drift detected: ${actionable_drift} stacks" | \
                mail -s "VoxFlow Drift Alert" "$DRIFT_ALERT_EMAIL"
        fi
    fi
fi

# ── JSON output ───────────────────────────────────────────────────────────────
if [[ "$JSON_MODE" == true ]]; then
    print_json_output
fi

# ── Exit ──────────────────────────────────────────────────────────────────────
if (( STACKS_WITH_DRIFT > 0 || STACKS_ERROR > 0 )); then
    exit 1
else
    exit 0
fi
