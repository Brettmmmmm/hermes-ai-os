#!/usr/bin/env bash
# ==============================================================================
# VoxFlow Grafana Dashboard Manager — v1.0.0
# ==============================================================================
# Backup, restore, and version-control Grafana dashboards for VoxFlow.
#
# Actions:
#   backup   — Export all dashboards as JSON, save to backup dir, optionally
#              commit to git.
#   restore  — Import dashboards from backup to a Grafana instance.
#   list     — List available backups (local + git).
#   diff     — Show differences between current Grafana dashboards and backup.
#
# Expected dashboards (5 total):
#   - voxflow-overview.json      (System Overview)
#   - qos-monitor.json           (QoS Metrics)
#   - sla-compliance.json        (SLA Compliance)
#   - cdr-explorer.json          (CDR Explorer)
#   - call-quality.json          (Call Quality)
#
# Environment variables:
#   VF_GRAFANA_URL         — Grafana base URL (default: http://localhost:3009)
#   VF_GRAFANA_USER        — Grafana admin user (default: admin)
#   VF_GRAFANA_PASSWORD    — Grafana admin password (default: admin)
#   VF_GRAFANA_TOKEN       — Grafana API token (overrides user/pass auth)
#   VF_DASHBOARD_BACKUP_DIR — Backup directory (default: ./grafana-backups)
#   VF_GIT_BACKUP          — Set to 1 to auto-commit backups to git
#   VF_GIT_REMOTE          — Git remote for backup push (optional)
#
# Exit codes:
#   0 — Success
#   1 — Operation failed
#   2 — Configuration error
#   3 — Grafana unreachable
#
# Usage:
#   ./grafana-dashboard-manager.sh backup
#   ./grafana-dashboard-manager.sh restore 20260429-120000
#   ./grafana-dashboard-manager.sh list
#   ./grafana-dashboard-manager.sh diff
# ==============================================================================

set -uo pipefail

# ── Colour definitions ────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
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
VF_GRAFANA_URL="${VF_GRAFANA_URL:-http://localhost:3009}"
VF_GRAFANA_USER="${VF_GRAFANA_USER:-admin}"
VF_GRAFANA_PASSWORD="${VF_GRAFANA_PASSWORD:-admin}"
VF_GRAFANA_TOKEN="${VF_GRAFANA_TOKEN:-}"
VF_DASHBOARD_BACKUP_DIR="${VF_DASHBOARD_BACKUP_DIR:-${SCRIPT_DIR:-$(pwd)}/grafana-backups}"
VF_GIT_BACKUP="${VF_GIT_BACKUP:-0}"
VF_GIT_REMOTE="${VF_GIT_REMOTE:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

EXPECTED_DASHBOARDS=(
    "voxflow-overview"
    "qos-monitor"
    "sla-compliance"
    "cdr-explorer"
    "call-quality"
)

# ── Help ──────────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'
Usage: grafana-dashboard-manager.sh <ACTION> [ARGS]

Manage Grafana dashboards for VoxFlow — backup, restore, list, and diff.

Actions:
  backup [NAME]         Export all dashboards from Grafana as JSON and save
  restore BACKUP_ID     Restore dashboards from a backup to Grafana
  list                  List available backups
  diff [BACKUP_ID]      Diff current Grafana dashboards against backup

Environment variables:
  VF_GRAFANA_URL           Grafana URL (default: http://localhost:3009)
  VF_GRAFANA_USER          Grafana user (default: admin)
  VF_GRAFANA_PASSWORD      Grafana password (default: admin)
  VF_GRAFANA_TOKEN         API token (overrides user/pass)
  VF_DASHBOARD_BACKUP_DIR  Backup directory (default: ./grafana-backups)
  VF_GIT_BACKUP            Auto-commit to git (1=yes)
  VF_GIT_REMOTE            Git remote for push

Exit codes:
  0  Success
  1  Failed
  2  Config error
  3  Grafana unreachable
EOF
    exit 0
}

# ── Authentication helper ─────────────────────────────────────────────────────
grafana_auth() {
    if [[ -n "$VF_GRAFANA_TOKEN" ]]; then
        echo "Authorization: Bearer ${VF_GRAFANA_TOKEN}"
    else
        echo "-u ${VF_GRAFANA_USER}:${VF_GRAFANA_PASSWORD}"
    fi
}

# ── Check Grafana connectivity ────────────────────────────────────────────────
check_grafana_up() {
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout 10 --max-time 10 \
        "$VF_GRAFANA_URL/api/health" 2>/dev/null) || http_code="000"
    if [[ "$http_code" != "200" ]]; then
        echo -e "${RED}ERROR:${NC} Grafana not reachable at ${VF_GRAFANA_URL} (HTTP ${http_code})" >&2
        return 1
    fi
    return 0
}

# ── Backup action ─────────────────────────────────────────────────────────────
do_backup() {
    local backup_name="${1:-$(date +%Y%m%d-%H%M%S)}"
    local backup_dir="${VF_DASHBOARD_BACKUP_DIR}/${backup_name}"

    echo -e "${BOLD}═══ Grafana Dashboard Backup ═══${NC}"
    echo "Grafana: ${VF_GRAFANA_URL}"
    echo "Backup: ${backup_dir}"
    echo ""

    check_grafana_up || exit 3

    mkdir -p "$backup_dir"

    # Get all dashboards
    local dashboards_json
    dashboards_json=$(curl -s --connect-timeout 10 --max-time 30 \
        $(grafana_auth) \
        "${VF_GRAFANA_URL}/api/search?type=dash-db" 2>/dev/null)

    if [[ -z "$dashboards_json" ]]; then
        echo -e "${RED}ERROR:${NC} Could not fetch dashboard list from Grafana" >&2
        exit 3
    fi

    local dashboard_uids
    if command -v jq &>/dev/null; then
        dashboard_uids=$(echo "$dashboards_json" | jq -r '.[].uid')
    else
        # Fallback: extract UIDs with grep/sed
        dashboard_uids=$(echo "$dashboards_json" | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)
    fi

    if [[ -z "$dashboard_uids" ]]; then
        echo -e "${YELLOW}WARNING:${NC} No dashboards found in Grafana"
        exit 1
    fi

    local exported=0
    local failed=0

    while IFS= read -r uid; do
        [[ -z "$uid" ]] && continue
        echo -n "  Exporting ${uid}... "

        local dash_json
        dash_json=$(curl -s --connect-timeout 10 --max-time 30 \
            $(grafana_auth) \
            "${VF_GRAFANA_URL}/api/dashboards/uid/${uid}" 2>/dev/null)

        if [[ -z "$dash_json" ]]; then
            echo -e "${RED}FAIL${NC}"
            ((failed++))
            continue
        fi

        # Extract the dashboard model (without Grafana metadata)
        local clean_json
        if command -v jq &>/dev/null; then
            clean_json=$(echo "$dash_json" | jq '.dashboard')
        else
            clean_json="$dash_json"  # store raw — restorable
        fi

        echo "$clean_json" > "${backup_dir}/${uid}.json"
        echo -e "${GREEN}OK${NC}"
        ((exported++))
    done <<< "$dashboard_uids"

    # Create manifest
    cat > "${backup_dir}/manifest.json" << EOF
{
  "backup_id": "${backup_name}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "grafana_url": "${VF_GRAFANA_URL}",
  "dashboards_exported": ${exported},
  "dashboards_failed": ${failed}
}
EOF

    echo ""
    echo -e "${GREEN}✓${NC} Backup complete: ${exported} exported, ${failed} failed"
    echo "  Location: ${backup_dir}"

    # Git operations
    if [[ "$VF_GIT_BACKUP" == "1" ]]; then
        echo ""
        echo "Committing to git..."
        (cd "$VF_DASHBOARD_BACKUP_DIR" && \
            git add "$backup_name" && \
            git commit -m "grafana: backup ${backup_name}" && \
            ${VF_GIT_REMOTE:+git push "$VF_GIT_REMOTE"}) 2>&1 || {
            echo -e "${YELLOW}WARNING:${NC} Git commit/push failed (backup files are saved locally)"
        }
    fi

    (( failed > 0 )) && exit 1 || exit 0
}

# ── Restore action ────────────────────────────────────────────────────────────
do_restore() {
    local backup_id="$1"
    local backup_dir="${VF_DASHBOARD_BACKUP_DIR}/${backup_id}"

    echo -e "${BOLD}═══ Grafana Dashboard Restore ═══${NC}"
    echo "Backup: ${backup_id}"
    echo "Grafana: ${VF_GRAFANA_URL}"
    echo ""

    if [[ ! -d "$backup_dir" ]]; then
        echo -e "${RED}ERROR:${NC} Backup '${backup_id}' not found at ${backup_dir}" >&2
        echo "Run 'list' to see available backups" >&2
        exit 2
    fi

    check_grafana_up || exit 3

    # Read manifest
    if [[ -f "${backup_dir}/manifest.json" ]]; then
        echo "Backup info:"
        grep -E 'timestamp|dashboards' "${backup_dir}/manifest.json" | sed 's/^/  /'
        echo ""
    fi

    local imported=0
    local failed=0

    for json_file in "${backup_dir}"/*.json; do
        [[ "$(basename "$json_file")" == "manifest.json" ]] && continue
        [[ ! -f "$json_file" ]] && continue

        local dashboard_json
        dashboard_json=$(cat "$json_file")

        # Wrap for Grafana import API
        local import_payload
        if command -v jq &>/dev/null; then
            import_payload=$(echo "{\"dashboard\": $(cat "$json_file"), \"overwrite\": true}" | jq -c .)
        else
            # Simple wrapping
            local escaped
            escaped=$(cat "$json_file" | python3 -c "import sys,json; print(json.dumps(json.dumps(json.load(sys.stdin))))" 2>/dev/null || echo "")
            if [[ -z "$escaped" ]]; then
                import_payload="{\"dashboard\":${dashboard_json},\"overwrite\":true}"
            else
                import_payload="{\"dashboard\":${escaped},\"overwrite\":true}"
            fi
        fi

        local uid
        uid=$(basename "$json_file" .json)
        echo -n "  Importing ${uid}... "

        local result
        result=$(curl -s --connect-timeout 10 --max-time 30 \
            -X POST -H "Content-Type: application/json" \
            $(grafana_auth) \
            -d "$import_payload" \
            "${VF_GRAFANA_URL}/api/dashboards/db" 2>/dev/null)

        if echo "$result" | grep -q '"status":"success"'; then
            echo -e "${GREEN}OK${NC}"
            ((imported++))
        else
            local err
            err=$(echo "$result" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
            echo -e "${RED}FAIL${NC} (${err:-unknown error})"
            ((failed++))
        fi
    done

    echo ""
    echo -e "${GREEN}✓${NC} Restore complete: ${imported} imported, ${failed} failed"
    (( failed > 0 )) && exit 1 || exit 0
}

# ── List action ───────────────────────────────────────────────────────────────
do_list() {
    echo -e "${BOLD}═══ Grafana Dashboard Backups ═══${NC}"
    echo ""

    if [[ ! -d "$VF_DASHBOARD_BACKUP_DIR" ]]; then
        echo "No backups directory at ${VF_DASHBOARD_BACKUP_DIR}"
        echo "Run 'backup' to create your first backup"
        exit 0
    fi

    local found=0
    for backup_dir in "${VF_DASHBOARD_BACKUP_DIR}"/*/; do
        [[ ! -d "$backup_dir" ]] && continue
        local name
        name=$(basename "$backup_dir")
        local dash_count
        dash_count=$(find "$backup_dir" -maxdepth 1 -name "*.json" ! -name "manifest.json" | wc -l)
        local ts=""
        if [[ -f "${backup_dir}/manifest.json" ]]; then
            ts=$(grep '"timestamp"' "${backup_dir}/manifest.json" | head -1 | cut -d'"' -f4)
        fi
        printf "  ${GREEN}%-25s${NC} %3d dashboards  %s\n" "$name" "$dash_count" "${ts:-unknown date}"
        ((found++))
    done

    if [[ $found -eq 0 ]]; then
        echo "  No backups found"
    fi
    echo ""
}

# ── Diff action ───────────────────────────────────────────────────────────────
do_diff() {
    local diff_backup="${1:-}"
    echo -e "${BOLD}═══ Grafana Dashboard Diff ═══${NC}"

    check_grafana_up || exit 3

    if [[ -z "$diff_backup" ]]; then
        # Find latest backup
        diff_backup=$(ls -1t "$VF_DASHBOARD_BACKUP_DIR" 2>/dev/null | head -1)
        if [[ -z "$diff_backup" ]]; then
            echo -e "${RED}ERROR:${NC} No backups found to diff against" >&2
            exit 2
        fi
        echo "Using latest backup: ${diff_backup}"
    fi

    local backup_dir="${VF_DASHBOARD_BACKUP_DIR}/${diff_backup}"
    if [[ ! -d "$backup_dir" ]]; then
        echo -e "${RED}ERROR:${NC} Backup '${diff_backup}' not found" >&2
        exit 2
    fi
    echo ""

    local diff_found=0
    for dashboard_name in "${EXPECTED_DASHBOARDS[@]}"; do
        local backup_file="${backup_dir}/${dashboard_name}.json"
        local current_json

        echo -n "  ${dashboard_name}: "

        # Fetch current from Grafana
        current_json=$(curl -s --connect-timeout 10 --max-time 30 \
            $(grafana_auth) \
            "${VF_GRAFANA_URL}/api/dashboards/uid/${dashboard_name}" 2>/dev/null)

        if [[ -z "$current_json" ]]; then
            echo -e "${YELLOW}NOT IN GRAFANA${NC}"
            diff_found=1
            continue
        fi

        if [[ ! -f "$backup_file" ]]; then
            echo -e "${YELLOW}NEW (not in backup)${NC}"
            diff_found=1
            continue
        fi

        # Extract dashboard model for comparison
        local current_model
        if command -v jq &>/dev/null; then
            current_model=$(echo "$current_json" | jq -c '.dashboard')
        else
            current_model="$current_json"
        fi

        # Compare (ignore version/timestamp fields)
        local current_clean backup_clean
        current_clean=$(echo "$current_model" | grep -v '"version":' | grep -v '"updated":' | grep -v '"created":')
        backup_clean=$(grep -v '"version":' "$backup_file" | grep -v '"updated":' | grep -v '"created":')

        if [[ "$current_clean" == "$backup_clean" ]]; then
            echo -e "${GREEN}MATCH${NC}"
        else
            echo -e "${RED}DIFFERENT${NC}"
            diff_found=1
        fi
    done

    echo ""
    if (( diff_found > 0 )); then
        echo -e "${YELLOW}⚠${NC} Differences detected — consider backing up or restoring"
        exit 1
    else
        echo -e "${GREEN}✓${NC} All dashboards match backup"
        exit 0
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
ACTION="${1:-}"
ARGS="${2:-}"

case "$ACTION" in
    backup)
        do_backup "$ARGS"
        ;;
    restore)
        if [[ -z "$ARGS" ]]; then
            echo "ERROR: restore requires a BACKUP_ID" >&2
            echo "Run 'list' to see available backups" >&2
            exit 2
        fi
        do_restore "$ARGS"
        ;;
    list)
        do_list
        ;;
    diff)
        do_diff "$ARGS"
        ;;
    -h|--help|"")
        show_help
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        echo "Run with --help for usage" >&2
        exit 2
        ;;
esac
