#!/bin/bash
# DevOps Security Monitor - Main Script
# Monitorea vulnerabilidades en herramientas DevOps
# Genera alertas y reportes en JSON

set -euo pipefail

# ============================================
# CONFIGURATION
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp}"
OUTPUT_FILE="${OUTPUT_DIR}/devops_security_report.json"
LOG_FILE="${OUTPUT_DIR}/devops_security.log"

# Tools to monitor
TOOLS=("trivy" "docker" "kubernetes" "terraform" "ansible" "jenkins" "gitlab" "github-actions")

# Thresholds
ALERT_THRESHOLD="${ALERT_THRESHOLD:-7}"  # 1-10 scale
CRITICAL_THRESHOLD=9

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# FUNCTIONS
# ============================================

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_info() { log "${GREEN}[INFO]${NC} $*"; }
log_warn() { log "${YELLOW}[WARN]${NC} $*"; }
log_error() { log "${RED}[ERROR]${NC} $*"; }

check_dependencies() {
    local deps=("curl" "jq" "python3")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_error "Dependencia faltante: $dep"
            exit 1
        fi
    done
    log_info "Dependencias verificadas"
}

# Check GitHub Advisory Database
check_advisories() {
    local tool=$1
    local advisories=()
    
    log_info "Consultando advisories para: $tool"
    
    local response
    response=$(curl -s --max-time 10 \
        "https://api.github.com/advisories?affects=$tool&per_page=5" \
        2>/dev/null || echo "[]")
    
    if [ "$response" = "[]" ] || [ -z "$response" ]; then
        echo "[]"
        return
    fi
    
    echo "$response"
}

# Parse severity to numeric
parse_severity() {
    local severity=$1
    case "$severity" in
        CRITICAL) echo "10" ;;
        HIGH) echo "7" ;;
        MEDIUM) echo "5" ;;
        LOW) echo "2" ;;
        *) echo "1" ;;
    esac
}

# Check Reddit trends
check_reddit_trends() {
    local subreddit=$1
    local output_file="/tmp/reddit_${subreddit}_check.json"
    
    # Check if we have cached data
    if [ -f "$output_file" ]; then
        local age
        age=$(($(date +%s) - $(stat -c %Y "$output_file" 2>/dev/null || echo 0)))
        if [ "$age" -lt 3600 ]; then  # Less than 1 hour old
            log_info "Usando cache de Reddit: $output_file"
            cat "$output_file"
            return
        fi
    fi
    
    log_info "Consultando Reddit: $subreddit"
    local response
    response=$(curl -s --max-time 10 \
        "https://www.reddit.com/r/${subreddit}/hot.json?limit=25" \
        -H "User-Agent: DevOpsSecurityMonitor/1.0" \
        2>/dev/null || echo '{"data":{"children":[]}}')
    
    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    posts = data.get('data', {}).get('children', [])
    security_posts = []
    keywords = ['trivy', 'vulnerability', 'cve', 'security', 'attack', 'breach', 'hack', 'exploit', 'supply chain']
    for p in posts:
        title = p.get('data', {}).get('title', '').lower()
        if any(k in title for k in keywords):
            security_posts.append({
                'title': p.get('data', {}).get('title', ''),
                'score': p.get('data', {}).get('score', 0),
                'url': p.get('data', {}).get('url', '')
            })
    print(json.dumps(security_posts[:5]))
except:
    print('[]')
" 2>/dev/null || echo "[]"
}

# Generate JSON report
generate_report() {
    local advisories_json="$OUTPUT_DIR/advisories_temp.json"
    local trends_json="$OUTPUT_DIR/trends_temp.json"
    
    log_info "Generando reporte..."
    
    # Collect advisories
    echo "[" > "$advisories_json"
    local first=true
    for tool in "${TOOLS[@]}"; do
        local adv
        adv=$(check_advisories "$tool")
        if [ "$adv" != "[]" ] && [ -n "$adv" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$advisories_json"
            fi
            echo "$adv" | jq -c '.[] | . + {"tool": "'$tool'"}' 2>/dev/null | head -3 >> "$advisories_json"
        fi
    done
    echo "]" >> "$advisories_json"
    
    # Collect trends
    echo '{"trends": [' > "$trends_json"
    first=true
    for sub in "devops" "cybersecurity" "programming"; do
        local trends
        trends=$(check_reddit_trends "$sub" 2>/dev/null)
        if [ -n "$trends" ] && [ "$trends" != "[]" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$trends_json"
            fi
            echo "$trends" | jq -c '.[] | . + {"source": "reddit", "subreddit": "r/'$sub'"}' >> "$trends_json"
        fi
    done
    echo "]}" >> "$trends_json"
    
    # Combine into final report
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local critical_count
    critical_count=$(cat "$advisories_json" | jq '[.[] | select(.severity == "CRITICAL")] | length' 2>/dev/null || echo "0")
    
    cat > "$OUTPUT_FILE" <<EOF
{
  "timestamp": "$timestamp",
  "tools_checked": ${#TOOLS[@]},
  "critical_alerts": $critical_count,
  "alert_threshold": $ALERT_THRESHOLD,
  "advisories": $(cat "$advisories_json"),
  "trends": $(cat "$trends_json" | jq '.trends')
}
EOF
    
    # Cleanup
    rm -f "$advisories_json" "$trends_json"
    
    log_info "Reporte generado: $OUTPUT_FILE"
}

# Print summary to console
print_summary() {
    log_info "=== RESUMEN DE SEGURIDAD ==="
    echo ""
    
    if [ -f "$OUTPUT_FILE" ]; then
        local critical
        critical=$(cat "$OUTPUT_FILE" | jq -r '.critical_alerts // 0')
        local total_tools
        total_tools=$(cat "$OUTPUT_FILE" | jq -r '.tools_checked // 0')
        
        if [ "$critical" -gt 0 ]; then
            echo -e "${RED}🔴 ALERTAS CRÍTICAS: $critical${NC}"
        else
            echo -e "${GREEN}✅ Sin alertas críticas${NC}"
        fi
        
        echo "Herramientas monitoreadas: $total_tools"
        echo ""
        
        # Show top advisories
        echo "=== Últimos Advisories ==="
        cat "$OUTPUT_FILE" | jq -r '.advisories[:3][]? | "  \(.ghsa_id // "N/A"): \(.summary // "N/A")[:60]"' 2>/dev/null || echo "  (Sin datos)"
        echo ""
        
        # Show top trends
        echo "=== Tendencias de Seguridad ==="
        cat "$OUTPUT_FILE" | jq -r '.trends[:3][]? | "  [\(.score // 0)] \(.title // "N/A")[:60]" - r/\(.subreddit // "N/A")' 2>/dev/null || echo "  (Sin datos)"
    fi
    
    echo ""
    log_info "Reporte completo: $OUTPUT_FILE"
}

# Send notifications (if configured)
send_notifications() {
    if [ -n "${SLACK_WEBHOOK:-}" ]; then
        log_info "Enviando notificación a Slack..."
        local payload
        payload=$(cat "$OUTPUT_FILE" | jq -c '{text: "DevOps Security Report: " + (.critical_alerts | tostring) + " critical alerts"}')
        curl -s -X POST -H 'Content-Type: application/json' \
            -d "$payload" \
            "$SLACK_WEBHOOK" 2>/dev/null || true
    fi
}

# ============================================
# MAIN
# ============================================

main() {
    log_info "=== DevOps Security Monitor Started ==="
    log_info "Tools: ${TOOLS[*]}"
    
    check_dependencies
    generate_report
    print_summary
    send_notifications
    
    log_info "=== DevOps Security Monitor Finished ==="
}

# Run
main "$@"
