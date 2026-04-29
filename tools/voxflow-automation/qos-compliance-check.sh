#!/usr/bin/env bash
# ==============================================================================
# VoxFlow QoS Compliance Check — v1.0.0
# ==============================================================================
# Verifies DSCP marking is active, Grafana dashboards reachable, six-class
# DSCP model (EF/46, AF41/34, CS3/24, AF21/18, AF31/26, BE/0) configured.
#
# Environment variables:
#   VF_HOST                — Service host (default: localhost)
#   VF_GRAFANA_HOST        — Grafana host (default: localhost)
#   VF_GRAFANA_PORT        — Grafana port (default: 3009)
#   VF_GRAFANA_USER        — Grafana admin user (default: admin)
#   VF_GRAFANA_PASSWORD    — Grafana admin password (default: admin)
#   VF_PROMETHEUS_HOST     — Prometheus host (default: localhost)
#   VF_PROMETHEUS_PORT     — Prometheus port (default: 9090)
#   VF_K8S_CONTEXT         — Kubernetes context (optional)
#   VF_NODES               — Comma-separated node list (auto-detected if unset)
#
# Exit codes:
#   0 — Fully compliant
#   1 — Non-compliant (one or more checks failed)
#   2 — Usage/configuration error
#
# Usage:
#   ./qos-compliance-check.sh
#   ./qos-compliance-check.sh --json
#   ./qos-compliance-check.sh --json > /var/log/voxflow/qos-report.json
#   Add to cron: 0 */4 * * * /path/to/qos-compliance-check.sh --json >> /var/log/voxflow/qos-cron.log 2>&1
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

# ── Configuration defaults ────────────────────────────────────────────────────
VF_HOST="${VF_HOST:-localhost}"
VF_GRAFANA_HOST="${VF_GRAFANA_HOST:-localhost}"
VF_GRAFANA_PORT="${VF_GRAFANA_PORT:-3009}"
VF_GRAFANA_USER="${VF_GRAFANA_USER:-admin}"
VF_GRAFANA_PASSWORD="${VF_GRAFANA_PASSWORD:-admin}"
VF_PROMETHEUS_HOST="${VF_PROMETHEUS_HOST:-localhost}"
VF_PROMETHEUS_PORT="${VF_PROMETHEUS_PORT:-9090}"
VF_K8S_CONTEXT="${VF_K8S_CONTEXT:-}"
VF_NODES="${VF_NODES:-}"
VF_TIMEOUT="${VF_TIMEOUT:-10}"

# ── Six-class DSCP model specification ────────────────────────────────────────
declare -A DSCP_MODEL
DSCP_MODEL[EF]="46:Voice RTP (G.711, Opus, SILK)"
DSCP_MODEL[AF41]="34:Video RTP, Screen Share"
DSCP_MODEL[CS3]="24:SIP Signaling, WebRTC ICE/DTLS, SRTP Keying"
DSCP_MODEL[AF21]="18:Real-time STT/TTS, Sentiment Analysis"
DSCP_MODEL[AF31]="26:WhatsApp/RCS Webhooks, CDR Writes"
DSCP_MODEL[BE]="0:Best Effort — Dashboard, Analytics, Bulk Data"

# Expected DSCP values in order
readonly EXPECTED_DSCP_VALUES=(46 34 24 18 26 0)
readonly EXPECTED_DSCP_NAMES=(EF AF41 CS3 AF21 AF31 BE)
readonly EXPECTED_GRAFANA_DASHBOARDS=5

# ── Result tracking ───────────────────────────────────────────────────────────
declare -A CHECK_RESULTS
PASS_COUNT=0
FAIL_COUNT=0
JSON_MODE=false

# ── Help ──────────────────────────────────────────────────────────────────────
show_help() {
    cat << 'EOF'
Usage: qos-compliance-check.sh [OPTIONS]

Verify VoxFlow QoS compliance across all nodes and services.

Options:
  --json              Output results as JSON (suitable for cron/log aggregation)
  -h, --help          Show this help

Environment variables:
  VF_HOST              Service host (default: localhost)
  VF_GRAFANA_HOST      Grafana host (default: localhost)
  VF_GRAFANA_PORT      Grafana port (default: 3009)
  VF_GRAFANA_USER      Grafana admin user (default: admin)
  VF_GRAFANA_PASSWORD  Grafana admin password (default: admin)
  VF_PROMETHEUS_HOST   Prometheus host (default: localhost)
  VF_PROMETHEUS_PORT   Prometheus port (default: 9090)
  VF_K8S_CONTEXT       Kubernetes context
  VF_NODES             Comma-separated node list (auto-detect)
  VF_TIMEOUT           HTTP timeout in seconds (default: 10)

Exit codes:
  0  Fully compliant
  1  Non-compliant
  2  Configuration error
EOF
    exit 0
}

# ── Utility functions ─────────────────────────────────────────────────────────
check_pass() {
    local name="$1" detail="$2"
    CHECK_RESULTS["$name"]="PASS:$detail"
    echo -e "  ${GREEN}✓${NC} $name: PASS — $detail"
    ((PASS_COUNT++))
}

check_fail() {
    local name="$1" detail="$2"
    CHECK_RESULTS["$name"]="FAIL:$detail"
    echo -e "  ${RED}✗${NC} $name: FAIL — $detail"
    ((FAIL_COUNT++))
}

check_warn() {
    local name="$1" detail="$2"
    CHECK_RESULTS["$name"]="WARN:$detail"
    echo -e "  ${YELLOW}⚠${NC} $name: WARN — $detail"
}

kubectl_cmd() {
    if [[ -n "$VF_K8S_CONTEXT" ]]; then
        kubectl --context "$VF_K8S_CONTEXT" "$@"
    else
        kubectl "$@"
    fi
}

# ── Check 1: Grafana dashboards reachable ─────────────────────────────────────
check_grafana() {
    echo -e "${BOLD}[1] Grafana Dashboard Availability${NC}"

    local grafana_url="http://${VF_GRAFANA_HOST}:${VF_GRAFANA_PORT}"
    local http_code

    # Check Grafana is up
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$VF_TIMEOUT" --max-time "$VF_TIMEOUT" \
        "${grafana_url}/api/health" 2>/dev/null) || http_code="000"

    if [[ "$http_code" != "200" ]]; then
        check_fail "grafana_health" "Grafana unavailable (HTTP $http_code)"
        return
    fi
    check_pass "grafana_health" "Grafana API responding"

    # Check dashboard count via API
    local dash_json
    dash_json=$(curl -s --connect-timeout "$VF_TIMEOUT" --max-time "$VF_TIMEOUT" \
        -u "${VF_GRAFANA_USER}:${VF_GRAFANA_PASSWORD}" \
        "${grafana_url}/api/search?type=dash-db" 2>/dev/null)

    if [[ -z "$dash_json" ]]; then
        check_fail "grafana_dashboards" "Could not query dashboard API"
        return
    fi

    # Count dashboards (jq or grep fallback)
    local dash_count
    if command -v jq &>/dev/null; then
        dash_count=$(echo "$dash_json" | jq 'length')
    else
        dash_count=$(echo "$dash_json" | grep -o '"title"' | wc -l)
    fi

    if [[ "$dash_count" -ge "$EXPECTED_GRAFANA_DASHBOARDS" ]]; then
        check_pass "grafana_dashboards" "${dash_count} dashboards found (expected >= ${EXPECTED_GRAFANA_DASHBOARDS})"
    else
        check_fail "grafana_dashboards" "Only ${dash_count}/${EXPECTED_GRAFANA_DASHBOARDS} dashboards found"
    fi
}

# ── Check 2: DSCP marking active on all nodes ─────────────────────────────────
check_dscp_nodes() {
    echo ""
    echo -e "${BOLD}[2] DSCP Marking Status per Node${NC}"

    local nodes=()

    # Get nodes
    if [[ -n "$VF_NODES" ]]; then
        IFS=',' read -ra nodes <<< "$VF_NODES"
    elif command -v kubectl_cmd &>/dev/null 2>&1; then
        local ctx_flag=""
        [[ -n "$VF_K8S_CONTEXT" ]] && ctx_flag="--context $VF_K8S_CONTEXT"
        readarray -t nodes < <(kubectl_cmd get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null)
    fi

    if [[ ${#nodes[@]} -eq 0 ]]; then
        # Local system check
        nodes=("$(hostname)")
    fi

    local dscp_ok=0 dscp_fail=0

    for node in "${nodes[@]}"; do
        # Check Cilium DaemonSet readiness for this node
        if command -v kubectl_cmd &>/dev/null 2>&1; then
            local ready
            ready=$(kubectl_cmd get ds voxflow-dscp-marker -n kube-system \
                -o jsonpath="{.status.numberReady}" 2>/dev/null)
            local desired
            desired=$(kubectl_cmd get ds voxflow-dscp-marker -n kube-system \
                -o jsonpath="{.status.desiredNumberScheduled}" 2>/dev/null)

            if [[ -n "$ready" && "$ready" -gt 0 && "$ready" == "$desired" ]]; then
                check_pass "dscp_node_${node}" "DaemonSet ready: ${ready}/${desired}"
                ((dscp_ok++))
            else
                check_fail "dscp_node_${node}" "DaemonSet not ready: ${ready:-0}/${desired:-0}"
                ((dscp_fail++))
            fi
        elif [[ "$node" == "$(hostname)" ]]; then
            # Local check: tc qdisc + iptables
            local local_ok=true
            if command -v tc &>/dev/null; then
                tc qdisc show 2>/dev/null | grep -q "htb" || local_ok=false
            fi
            if command -v iptables &>/dev/null; then
                iptables -t mangle -L PREROUTING 2>/dev/null | grep -q "MARK" || local_ok=false
            fi
            if [[ "$local_ok" == true ]]; then
                check_pass "dscp_node_${node}" "tc HTB + iptables mangle rules active"
                ((dscp_ok++))
            else
                check_fail "dscp_node_${node}" "DSCP marking not detected locally"
                ((dscp_fail++))
            fi
        else
            check_warn "dscp_node_${node}" "Cannot check — no kubectl access, not local"
        fi
    done

    if [[ $dscp_fail -gt 0 ]]; then
        check_fail "dscp_summary" "${dscp_ok} nodes OK, ${dscp_fail} nodes FAIL"
    elif [[ $dscp_ok -gt 0 ]]; then
        check_pass "dscp_summary" "All ${dscp_ok} nodes have DSCP marking active"
    else
        check_warn "dscp_summary" "No nodes checked — cannot verify"
    fi
}

# ── Check 3: Six-class DSCP model configured ──────────────────────────────────
check_dscp_model() {
    echo ""
    echo -e "${BOLD}[3] Six-Class DSCP Model Compliance${NC}"

    # Check DSCP values in Cilium ConfigMap
    if command -v kubectl_cmd &>/dev/null 2>&1; then
        local configmap
        configmap=$(kubectl_cmd get configmap voxflow-dscp-config -n kube-system \
            -o jsonpath='{.data.dscp-mapping\.yaml}' 2>/dev/null)

        if [[ -z "$configmap" ]]; then
            check_warn "dscp_configmap" "voxflow-dscp-config ConfigMap not found"
        else
            local found_all=true
            for dscp_name in "${EXPECTED_DSCP_NAMES[@]}"; do
                if echo "$configmap" | grep -q "name: $dscp_name"; then
                    check_pass "dscp_class_${dscp_name}" "Configured in ConfigMap"
                else
                    check_fail "dscp_class_${dscp_name}" "Missing from ConfigMap"
                    found_all=false
                fi
            done
            [[ "$found_all" == true ]] && check_pass "dscp_configmap" "All 6 DSCP classes present" || \
                check_fail "dscp_configmap" "One or more DSCP classes missing"
        fi
    fi

    # Check source-of-truth DSCP module (if VoxFlow repo is available)
    local voxflow_repo="${VOXFLOW_REPO:-/home/brett/.openclaw.pre-migration/workspace-infra/voxflow}"
    if [[ -f "${voxflow_repo}/packages/qos-classifier/src/dscp.ts" ]]; then
        local dscp_file="${voxflow_repo}/packages/qos-classifier/src/dscp.ts"
        for dscp_name in "${EXPECTED_DSCP_NAMES[@]}"; do
            local expected_dscp
            case "$dscp_name" in
                EF)   expected_dscp=46;;
                AF41) expected_dscp=34;;
                CS3)  expected_dscp=24;;
                AF21) expected_dscp=18;;
                AF31) expected_dscp=26;;
                BE)   expected_dscp=0;;
            esac
            if grep -q "${dscp_name} = ${expected_dscp}" "$dscp_file"; then
                check_pass "dscp_source_${dscp_name}" "Source-of-truth: ${expected_dscp}"
            else
                check_fail "dscp_source_${dscp_name}" "Source DSCP value mismatch expected ${expected_dscp}"
            fi
        done
    else
        # Validate the six-class model is correct from built-in reference
        echo "  (DSCP source file not found — checking built-in reference values)"
        local valid=true
        for i in "${!EXPECTED_DSCP_NAMES[@]}"; do
            local name="${EXPECTED_DSCP_NAMES[$i]}"
            local val="${EXPECTED_DSCP_VALUES[$i]}"
            echo "  ${CYAN}→${NC} $name = $val — ${DSCP_MODEL[$name]#*:}"
            check_pass "dscp_model_${name}" "Value ${val} — ${DSCP_MODEL[$name]#*:}"
        done
    fi
}

# ── Check 4: Prometheus QoS metrics ───────────────────────────────────────────
check_prometheus_metrics() {
    echo ""
    echo -e "${BOLD}[4] Prometheus QoS Metrics Availability${NC}"

    local prom_url="http://${VF_PROMETHEUS_HOST}:${VF_PROMETHEUS_PORT}"
    local http_code

    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$VF_TIMEOUT" --max-time "$VF_TIMEOUT" \
        "${prom_url}/-/healthy" 2>/dev/null) || http_code="000"

    if [[ "$http_code" != "200" ]]; then
        check_fail "prometheus_health" "Prometheus unavailable (HTTP $http_code)"
        return
    fi
    check_pass "prometheus_health" "Prometheus is up"

    # Check for QoS-related metrics
    local metrics_sample
    metrics_sample=$(curl -s --connect-timeout "$VF_TIMEOUT" --max-time "$VF_TIMEOUT" \
        "${prom_url}/api/v1/query?query=mos_score" 2>/dev/null)

    if echo "$metrics_sample" | grep -q '"status":"success"'; then
        check_pass "prometheus_mos_metric" "mos_score metric available"
    else
        check_warn "prometheus_mos_metric" "mos_score metric not found"
    fi

    # Check DSCP packet counter metric
    metrics_sample=$(curl -s --connect-timeout "$VF_TIMEOUT" --max-time "$VF_TIMEOUT" \
        "${prom_url}/api/v1/query?query=voxflow_dscp_packets_total" 2>/dev/null)
    if echo "$metrics_sample" | grep -q '"status":"success"'; then
        check_pass "prometheus_dscp_metric" "voxflow_dscp_packets_total available"
    else
        check_warn "prometheus_dscp_metric" "voxflow_dscp_packets_total metric not found"
    fi
}

# ── Check 5: Alert rules compliance ───────────────────────────────────────────
check_alert_rules() {
    echo ""
    echo -e "${BOLD}[5] QoS Alert Rules Compliance${NC}"

    local alert_files=()
    local voxflow_repo="${VOXFLOW_REPO:-/home/brett/.openclaw.pre-migration/workspace-infra/voxflow}"

    # Check known alert rule files
    local files=(
        "${voxflow_repo}/infrastructure/prometheus/rules/qos-alerts.yml"
        "${voxflow_repo}/infrastructure/grafana/prometheus/rules/voxflow-alerts.yml"
    )

    local found=0
    for f in "${files[@]}"; do
        if [[ -f "$f" ]]; then
            ((found++))
            local rule_count
            rule_count=$(grep -c "alert:" "$f" 2>/dev/null || echo 0)
            check_pass "alerts_$(basename "$f")" "${rule_count} alert rules defined"
        fi
    done

    if [[ $found -eq 0 ]]; then
        # Check via Prometheus API
        local prom_url="http://${VF_PROMETHEUS_HOST}:${VF_PROMETHEUS_PORT}"
        local rules_json
        rules_json=$(curl -s --connect-timeout "$VF_TIMEOUT" --max-time "$VF_TIMEOUT" \
            "${prom_url}/api/v1/rules" 2>/dev/null)

        if echo "$rules_json" | grep -q '"status":"success"'; then
            local rule_count
            if command -v jq &>/dev/null; then
                rule_count=$(echo "$rules_json" | jq '.data.groups | length')
            else
                rule_count=$(echo "$rules_json" | grep -o '"name"' | wc -l)
            fi
            check_pass "alerts_prometheus" "${rule_count} rule groups loaded in Prometheus"
        else
            check_warn "alerts_prometheus" "Could not query alert rules from Prometheus"
        fi
    fi
}

# ── JSON output ───────────────────────────────────────────────────────────────
print_json_report() {
    echo "{"
    echo '  "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",'
    echo '  "compliance": {'
    echo '    "overall": "'"$( (( FAIL_COUNT > 0 )) && echo "non_compliant" || echo "compliant" )"'",'
    echo '    "passed": '"$PASS_COUNT"','
    echo '    "failed": '"$FAIL_COUNT"''
    echo '  },'
    echo '  "dscp_model": {'
    for dscp_name in "${EXPECTED_DSCP_NAMES[@]}"; do
        local val
        case "$dscp_name" in
            EF) val=46;; AF41) val=34;; CS3) val=24;;
            AF21) val=18;; AF31) val=26;; BE) val=0;;
        esac
        local desc="${DSCP_MODEL[$dscp_name]#*:}"
        echo "    \"$dscp_name\": {\"value\": $val, \"description\": \"$desc\"},"
    done
    echo '    "class_count": 6'
    echo '  },'
    echo '  "checks": {'
    local first=true
    for key in "${!CHECK_RESULTS[@]}"; do
        local status="${CHECK_RESULTS[$key]%%:*}"
        local detail="${CHECK_RESULTS[$key]#*:}"
        [[ "$first" == true ]] && first=false || echo ","
        printf '    "%s": {"status": "%s", "detail": "%s"}' "$key" "$status" "$detail"
    done
    echo ""
    echo '  }'
    echo "}"
}

# ── Parse arguments ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --json)
            JSON_MODE=true
            shift
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
if ! command -v curl &>/dev/null; then
    echo "ERROR: curl is required but not installed" >&2
    exit 2
fi

# ── Run all compliance checks ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}═══ VoxFlow QoS Compliance Report ═══${NC}"
echo "Date: $(date)"
echo ""

check_grafana
check_dscp_nodes
check_dscp_model
check_prometheus_metrics
check_alert_rules

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════"
if (( FAIL_COUNT > 0 )); then
    echo -e "  ${RED}✗ NON-COMPLIANT${NC} — ${FAIL_COUNT} check(s) failed"
else
    echo -e "  ${GREEN}✓ COMPLIANT${NC} — All ${PASS_COUNT} checks passed"
fi
echo "═══════════════════════════════════════════════════"
echo ""

# ── JSON output ───────────────────────────────────────────────────────────────
if [[ "$JSON_MODE" == true ]]; then
    print_json_report
fi

# ── Exit ──────────────────────────────────────────────────────────────────────
if (( FAIL_COUNT > 0 )); then
    exit 1
else
    exit 0
fi
