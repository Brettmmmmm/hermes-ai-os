#!/usr/bin/env bash
# ==============================================================================
# VoxFlow Platform Health Check
# Checks all 9 microservices, infrastructure, and QoS compliance.
#
# Usage: ./health-check.sh [--json] [--host HOST] [--port PORT]
#   --json    Output results as JSON (for cron/alerting)
#   --host    Target host (default: localhost)
#   --port    Health endpoint port (default: 3000)
# ==============================================================================

set -euo pipefail

# ─── Configuration ─────────────────────────────────────────
HOST="${HOST:-localhost}"
PORT="${PORT:-3000}"
TIMEOUT=5
JSON_MODE=false
PASS=0; FAIL=0; WARN=0
RESULTS=()

# ─── Parse arguments ───────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --json)       JSON_MODE=true ;;
        --host)       HOST="${2}"; shift ;;
        --port)       PORT="${2}"; shift ;;
        --help|-h)    echo "Usage: $0 [--json] [--host HOST] [--port PORT]"
                      exit 0 ;;
    esac
    shift 2>/dev/null || true
done

BASE_URL="http://${HOST}:${PORT}"

# ─── Color helpers ─────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

green()  { echo -e "${GREEN}$1${NC}"; }
red()    { echo -e "${RED}$1${NC}"; }
yellow() { echo -e "${YELLOW}$1${NC}"; }
bold()   { echo -e "${BOLD}$1${NC}"; }

# ─── Core check function ───────────────────────────────────
check_service() {
    local name="$1" endpoint="$2" description="${3:-}"
    local url="${BASE_URL}${endpoint}"
    local status=""

    if status=$(curl -sf --max-time "$TIMEOUT" "$url" 2>/dev/null | \
                python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('status','UNKNOWN'))" 2>/dev/null); then
        case "$status" in
            healthy|ok|ready) RESULT="PASS"; ((PASS++)) ;;
            *)                RESULT="WARN"; ((WARN++)) ;;
        esac
    else
        status="DOWN"
        RESULT="FAIL"
        ((FAIL++))
    fi

    RESULTS+=("$name|$status|$RESULT|$endpoint")
}

# ─── Infrastructure checks ─────────────────────────────────
check_db() {
    local result
    if curl -sf --max-time "$TIMEOUT" "${BASE_URL}/health" 2>/dev/null | \
       python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('database','UNKNOWN'))" 2>/dev/null | \
       grep -q "ok\|healthy\|connected"; then
        result="PASS"; ((PASS++))
    else
        result="FAIL"; ((FAIL++))
    fi
    RESULTS+=("PostgreSQL|$(curl -sf --max-time "$TIMEOUT" "${BASE_URL}/health" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('database','UNKNOWN'))" 2>/dev/null || echo 'DOWN')|$result|/health")
}

check_redis() {
    local result
    if curl -sf --max-time "$TIMEOUT" "${BASE_URL}/health" 2>/dev/null | \
       python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('redis','UNKNOWN'))" 2>/dev/null | \
       grep -q "ok\|healthy\|connected"; then
        result="PASS"; ((PASS++))
    else
        result="FAIL"; ((FAIL++))
    fi
    RESULTS+=("Redis|$(curl -sf --max-time "$TIMEOUT" "${BASE_URL}/health" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('redis','UNKNOWN'))" 2>/dev/null || echo 'DOWN')|$result|/health")
}

check_dscp() {
    local result
    if curl -sf --max-time "$TIMEOUT" "${BASE_URL}/health/qos-classifier" 2>/dev/null | \
       python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('dscp_active','false'))" 2>/dev/null | \
       grep -q "true"; then
        result="PASS"; ((PASS++))
    else
        result="WARN"; ((WARN++))
    fi
    RESULTS+=("eBPF/DSCP|$(curl -sf --max-time "$TIMEOUT" "${BASE_URL}/health/qos-classifier" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('dscp_active','false'))" 2>/dev/null || echo 'DOWN')|$result|/health/qos-classifier")
}

# ─── HEADER ────────────────────────────────────────────────
if ! $JSON_MODE; then
    bold "╔══════════════════════════════════════════════════════════╗"
    bold "║              VOXFLOW HEALTH CHECK — $(date '+%Y-%m-%d %H:%M:%S')      ║"
    bold "╚══════════════════════════════════════════════════════════╝"
    echo ""
fi

# ─── Service checks ────────────────────────────────────────
if ! $JSON_MODE; then
    bold "━━━ Microservices ━━━"
fi

check_service "Gateway"          "/health"                 "API gateway"
check_service "Tenant Manager"   "/health/tenant-manager"  "Tenant & API key management"
check_service "Call Control"     "/health/call-control"    "SIP call routing"
check_service "WhatsApp"         "/health/whatsapp"        "WhatsApp Business API"
check_service "RCS"              "/health/rcs"             "RCS Rich Messaging"
check_service "Media Processor"  "/health/media-processor" "FreeSWITCH integration"
check_service "QoS Classifier"   "/health/qos-classifier"  "DSCP marking engine"
check_service "Analytics"        "/health/analytics"       "TimescaleDB metrics"
check_service "Billing"          "/health/billing"         "Usage & invoicing"

# ─── Infrastructure checks ─────────────────────────────────
if ! $JSON_MODE; then
    echo ""
    bold "━━━ Infrastructure ━━━"
fi

check_db
check_redis
check_dscp

# ─── Output ────────────────────────────────────────────────
if $JSON_MODE; then
    # JSON output for machine consumption
    echo '{"timestamp":"'"$(date -Iseconds)"'","summary":{"pass":'"$PASS"',"fail":'"$FAIL"',"warn":'"$WARN"'},"services":['
    first=true
    for r in "${RESULTS[@]}"; do
        IFS='|' read -r name status result endpoint <<< "$r"
        $first || echo -n ","
        first=false
        echo -n "{\"name\":\"$name\",\"status\":\"$status\",\"result\":\"$result\",\"endpoint\":\"$endpoint\"}"
    done
    echo ']}'
else
    # Table output
    echo ""
    printf "  %-20s %-15s %-6s  %s\n" "SERVICE" "STATUS" "RESULT" "ENDPOINT"
    printf "  %-20s %-15s %-6s  %s\n" "──────" "──────" "────" "────────"
    for r in "${RESULTS[@]}"; do
        IFS='|' read -r name status result endpoint <<< "$r"
        case "$result" in
            PASS) status_color=$(green "$status")  ;;
            FAIL) status_color=$(red "$status")    ;;
            WARN) status_color=$(yellow "$status")  ;;
        esac
        printf "  %-20s %b %-6s  %s\n" "$name" "$status_color" "$result" "$endpoint"
    done

    echo ""
    echo -n "  SUMMARY: "
    echo -n "$(green "✓ ${PASS} PASS")  "
    [[ $WARN -gt 0 ]] && echo -n "$(yellow "⚠ ${WARN} WARN")  "
    [[ $FAIL -gt 0 ]] && echo -n "$(red "✗ ${FAIL} FAIL")"
    echo ""

    if [[ $FAIL -gt 0 ]]; then
        echo ""
        red "  ╔══════════════════════════════════════════════════════╗"
        red "  ║  HEALTH CHECK FAILED — ${FAIL} service(s) down             ║"
        red "  ╚══════════════════════════════════════════════════════╝"
    fi
fi

# ─── Exit code ─────────────────────────────────────────────
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
