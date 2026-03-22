#!/bin/bash
# DevOps Security Monitor - Main Script
# Monitorea vulnerabilidades en herramientas DevOps
# Incluye detección de supply chain attacks
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

# KNOWN COMPROMISED VERSIONS - CRITICAL FOR SUPPLY CHAIN DETECTION
# Updated: March 2026
declare -A KNOWN_COMPROMISED=(
    ["trivy:0.69.4"]="Supply chain attack - malicious code injected via GitHub Actions"
    ["trivy:0.69.3"]="CVE-2024-21626 - Container breakout via privileged containers"
    ["log4j:2.14.0"]="CVE-2021-44228 - Log4Shell RCE"
    ["log4j:2.15.0"]="CVE-2021-44228 - Log4Shell RCE (initial fix incomplete)"
    ["spring4shell:2.3"]="CVE-2022-22965 - Spring Framework RCE"
    ["xz:5.6.0"]="CVE-2024-3094 - Backdoor in xz/lzma"
    ["xz:5.6.1"]="CVE-2024-3094 - Backdoor in xz/lzma"
)

# Supply chain attack patterns
SUPPLY_CHAIN_PATTERNS=(
    "supply chain"
    "typosquatting"
    "dependency confusion"
    "malicious package"
    "compromised dependency"
    "backdoor"
    "supply chain attack"
)

# Thresholds
ALERT_THRESHOLD="${ALERT_THRESHOLD:-7}"
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

log_critical() { 
    log "${RED}[CRITICAL]${NC} $*"
    # Also write to stderr for immediate attention
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [CRITICAL] $*" >&2
}

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

# ============================================
# SUPPLY CHAIN ATTACK DETECTION
# ============================================

# Check for known compromised versions
check_known_compromised() {
    local tool=$1
    local version=$2
    local key="${tool}:${version}"
    
    if [[ -v "KNOWN_COMPROMISED[$key]" ]]; then
        echo "{\"compromised\": true, \"reason\": \"${KNOWN_COMPROMISED[$key]}\", \"cve\": \"${key}\"}"
        return 0
    fi
    echo "{\"compromised\": false}"
}

# Check GitHub Advisory Database for supply chain vulnerabilities
check_supply_chain_advisories() {
    local advisories=()
    
    log_info "Consultando advisories de supply chain..."
    
    # Query GitHub Advisory API for supply chain related CVEs
    local response
    response=$(curl -s --max-time 15 \
        "https://api.github.com/advisories?type=reviewed&per_page=20" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        2>/dev/null || echo "[]")
    
    if [ "$response" = "[]" ] || [ -z "$response" ]; then
        echo "[]"
        return
    fi
    
    # Filter for supply chain vulnerabilities
    echo "$response" | python3 -c "
import sys, json
import re

try:
    data = json.load(sys.stdin)
    supply_chain_cves = []
    
    # Keywords that indicate supply chain attacks
    keywords = ['supply chain', 'typosquatting', 'dependency confusion', 'malicious', 'compromised', 'backdoor', 'dependency hijacking']
    
    for adv in data:
        summary = adv.get('summary', '').lower()
        description = adv.get('description', '').lower()
        cve_id = adv.get('cve_id', '')
        ghsa_id = adv.get('ghsa_id', '')
        severity = adv.get('severity', 'UNKNOWN')
        
        # Check if it's supply chain related
        is_supply_chain = any(k in summary or k in description for k in keywords)
        
        # Also check for specific known supply chain CVEs
        known_supply_chain = ['CVE-2024-21626', 'CVE-2024-3094', 'CVE-2021-44228', 'CVE-2022-22965', 'CVE-2023-44487']
        is_known = any(cve in cve_id for cve in known_supply_chain)
        
        if is_supply_chain or is_known:
            # Determine numeric severity
            severity_map = {'CRITICAL': 10, 'HIGH': 7, 'MEDIUM': 5, 'LOW': 2, 'UNKNOWN': 1}
            numeric_severity = severity_map.get(severity.upper(), 1)
            
            supply_chain_cves.append({
                'cve_id': cve_id,
                'ghsa_id': ghsa_id,
                'summary': adv.get('summary', '')[:200],
                'severity': severity,
                'numeric_severity': numeric_severity,
                'published_at': adv.get('published_at', ''),
                'url': adv.get('html_url', ''),
                'vulnerable_version': adv.get('vulnerabilities', [{}])[0].get('vulnerable_version_range', 'Unknown'),
                'package': adv.get('vulnerabilities', [{}])[0].get('package', {}).get('name', 'Unknown')
            })
    
    # Sort by severity
    supply_chain_cves.sort(key=lambda x: x['numeric_severity'], reverse=True)
    print(json.dumps(supply_chain_cves[:10]))
except Exception as e:
    print('[]')
" 2>/dev/null || echo "[]"
}

# ============================================
# TRIVY SPECIFIC MONITORING (CRITICAL AFTER SUPPLY CHAIN ATTACKS)
# ============================================

check_trivy_security() {
    log_info "Ejecutando verificación específica de Trivy..."
    
    local trivy_status="unknown"
    local installed_version=""
    local vulnerabilities=()
    local alerts=()
    
    # Check if trivy is installed
    if command -v trivy &> /dev/null; then
        installed_version=$(trivy version 2>/dev/null | head -1 || echo "unknown")
        trivy_status="installed"
        
        # CRITICAL: Check for compromised versions
        if [[ "$installed_version" == *"0.69.4"* ]]; then
            log_critical "DETECTADO: Trivy v0.69.4 - VERSIÓN COMPROMETIDA"
            log_critical "Esta versión fue victima de supply chain attack"
            alerts+=("CRITICAL: Trivy v0.69.4 is compromised - DO NOT USE")
        fi
        
        # Check for vulnerabilities in trivy itself
        log_info "Buscando vulnerabilidades en Trivy..."
        local vuln_output
        vuln_output=$(trivy image --severity CRITICAL,HIGH aquasec/trivy:latest 2>/dev/null | head -20 || echo "")
        
        if [[ -n "$vuln_output" ]]; then
            vulnerabilities+=("$vuln_output")
        fi
    else
        trivy_status="not_installed"
        log_warn "Trivy no está instalado en este sistema"
    fi
    
    # Return JSON status
    cat <<EOF
{
  "status": "$trivy_status",
  "installed_version": "$installed_version",
  "is_compromised": $([ "$installed_version" == *"0.69.4"* ] && echo "true" || echo "false"),
  "alerts": $(printf '%s\n' "${alerts[@]:-}" | jq -R . | jq -s .),
  "vulnerabilities": $(printf '%s\n' "${vulnerabilities[@]:-}" | jq -R . | jq -s . 2>/dev/null || echo "[]")
}
EOF
}

# ============================================
# REDDIT TREND MONITORING
# ============================================

check_reddit_trends() {
    local subreddit=$1
    local output_file="/tmp/reddit_${subreddit}_check.json"
    
    # Check cache (1 hour)
    if [ -f "$output_file" ]; then
        local age
        age=$(($(date +%s) - $(stat -c %Y "$output_file" 2>/dev/null || echo 0)))
        if [ "$age" -lt 3600 ]; then
            log_info "Usando cache de Reddit: $subreddit"
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
    keywords = ['trivy', 'vulnerability', 'cve', 'security', 'attack', 'breach', 'hack', 'exploit', 'supply chain', 'compromised']
    for p in posts:
        title = p.get('data', {}).get('title', '').lower()
        if any(k in title for k in security_posts):
            security_posts.append({
                'title': p.get('data', {}).get('title', ''),
                'score': p.get('data', {}).get('score', 0),
                'url': p.get('data', {}).get('url', ''),
                'subreddit': 'r/${subreddit}'
            })
    print(json.dumps(security_posts[:5]))
except:
    print('[]')
" 2>/dev/null || echo "[]"
    
    # Cache the result
    echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    posts = data.get('data', {}).get('children', [])
    security_posts = []
    keywords = ['trivy', 'vulnerability', 'cve', 'security', 'attack', 'breach', 'hack', 'exploit', 'supply chain', 'compromised']
    for p in posts:
        title = p.get('data', {}).get('title', '').lower()
        if any(k in title for k in keywords):
            security_posts.append({
                'title': p.get('data', {}).get('title', ''),
                'score': p.get('data', {}).get('score', 0),
                'url': p.get('data', {}).get('url', ''),
                'subreddit': 'r/${subreddit}'
            })
    print(json.dumps(security_posts[:5]))
except:
    print('[]')
" > "$output_file" 2>/dev/null || true
}

# ============================================
# GENERATE COMPREHENSIVE REPORT
# ============================================

generate_report() {
    local advisories_json="$OUTPUT_DIR/advisories_temp.json"
    local trends_json="$OUTPUT_DIR/trends_temp.json"
    local supply_chain_json="$OUTPUT_DIR/supply_chain_temp.json"
    local trivy_status_json="$OUTPUT_DIR/trivy_status_temp.json"
    
    log_info "Generando reporte completo de seguridad..."
    
    # 1. Collect supply chain advisories (MOST IMPORTANT)
    log_info "Recolectando advisories de supply chain..."
    check_supply_chain_advisories > "$supply_chain_json"
    
    # 2. Check Trivy specifically (CRITICAL after recent attacks)
    log_info "Verificando estado de Trivy..."
    check_trivy_security > "$trivy_status_json"
    
    # 3. Collect general advisories
    echo "[" > "$advisories_json"
    local first=true
    for tool in "${TOOLS[@]}"; do
        local adv
        adv=$(curl -s --max-time 10 \
            "https://api.github.com/advisories?affects=$tool&per_page=3" \
            2>/dev/null || echo "[]")
        
        if [ "$adv" != "[]" ] && [ -n "$adv" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                echo "," >> "$advisories_json"
            fi
            echo "$adv" | jq -c '.[] | . + {"tool": "'$tool'"}' 2>/dev/null | head -2 >> "$advisories_json"
        fi
    done
    echo "]" >> "$advisories_json"
    
    # 4. Collect trends
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
            echo "$trends" | jq -c '.[]' >> "$trends_json"
        fi
    done
    echo "]}" >> "$trends_json"
    
    # 5. Calculate threat score
    local supply_chain_count
    supply_chain_count=$(cat "$supply_chain_json" | jq 'length' 2>/dev/null || echo "0")
    local trivy_compromised
    trivy_compromised=$(cat "$trivy_status_json" | jq -r '.is_compromised' 2>/dev/null || echo "false")
    local critical_advisories
    critical_advisories=$(cat "$advisories_json" | jq '[.[] | select(.severity == "CRITICAL")] | length' 2>/dev/null || echo "0")
    
    # Calculate overall threat score (1-10)
    local threat_score=1
    if [ "$trivy_compromised" = "true" ]; then
        threat_score=10
    elif [ "$supply_chain_count" -gt 5 ]; then
        threat_score=8
    elif [ "$supply_chain_count" -gt 2 ]; then
        threat_score=6
    elif [ "$critical_advisories" -gt 0 ]; then
        threat_score=5
    fi
    
    # 6. Build final report
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > "$OUTPUT_FILE" <<EOF
{
  "timestamp": "$timestamp",
  "threat_score": $threat_score,
  "threat_level": $([ "$threat_score" -ge 8 ] && echo "\"CRITICAL\"" || ([ "$threat_score" -ge 6 ] && echo "\"HIGH\"" || ([ "$threat_score" -ge 4 ] && echo "\"MEDIUM\"" || echo "\"LOW\""))),
  "tools_checked": ${#TOOLS[@]},
  "supply_chain_alerts": $supply_chain_count,
  "critical_advisories": $critical_advisories,
  "trivy_status": $(cat "$trivy_status_json"),
  "supply_chain_vulnerabilities": $(cat "$supply_chain_json"),
  "general_advisories": $(cat "$advisories_json"),
  "trends": $(cat "$trends_json" | jq '.trends')
}
EOF
    
    # Cleanup temp files
    rm -f "$advisories_json" "$trends_json" "$supply_chain_json" "$trivy_status_json"
    
    log_info "Reporte generado: $OUTPUT_FILE"
}

# ============================================
# CONSOLE SUMMARY
# ============================================

print_summary() {
    log_info "========================================"
    log_info "   RESUMEN DE SEGURIDAD DevOps"
    log_info "========================================"
    echo ""
    
    if [ -f "$OUTPUT_FILE" ]; then
        local threat_score
        threat_score=$(cat "$OUTPUT_FILE" | jq -r '.threat_score // 0')
        local threat_level
        threat_level=$(cat "$OUTPUT_FILE" | jq -r '.threat_level // "UNKNOWN"')
        local supply_chain_alerts
        supply_chain_alerts=$(cat "$OUTPUT_FILE" | jq -r '.supply_chain_alerts // 0')
        local trivy_compromised
        trivy_compromised=$(cat "$OUTPUT_FILE" | jq -r '.trivy_status.is_compromised // false')
        
        # Threat level color
        local level_color="$NC"
        case "$threat_level" in
            "CRITICAL") level_color="$RED" ;;
            "HIGH") level_color="$YELLOW" ;;
            "MEDIUM") level_color="$BLUE" ;;
            "LOW") level_color="$GREEN" ;;
        esac
        
        echo -e "Nivel de Amenaza: ${level_color}$threat_level${NC} (Score: $threat_score/10)"
        echo "Alertas de Supply Chain: $supply_chain_alerts"
        
        # CRITICAL: Trivy warning
        if [ "$trivy_compromised" = "true" ]; then
            echo ""
            echo -e "${RED}🔴 ATENCIÓN: Trivy comprometido detectado${NC}"
            echo -e "${RED}   Versión 0.69.4 fue victima de supply chain attack${NC}"
            echo -e "${RED}   Recomendación: Cambiar a alternativa (grype, checkov)${NC}"
        fi
        
        echo ""
        echo "=== Vulnerabilidades de Supply Chain ==="
        cat "$OUTPUT_FILE" | jq -r '.supply_chain_vulnerabilities[:5][]? | 
            "  [\(.severity)] \(.cve_id // "N/A"): \(.summary // "N/A")[:70]" + 
            " (pkg: \(.package // "N/A"))"' 2>/dev/null || echo "  (Sin datos)"
        
        echo ""
        echo "=== Tendencias de Seguridad ==="
        cat "$OUTPUT_FILE" | jq -r '.trends[:5][]? | 
            "  [↑\(.score // 0)] \(.title // "N/A")[:60] - \(.subreddit // "N/A")"' 2>/dev/null || echo "  (Sin datos)"
    fi
    
    echo ""
    log_info "Reporte completo: $OUTPUT_FILE"
}

# ============================================
# NOTIFICATIONS
# ============================================

send_notifications() {
    if [ -n "${SLACK_WEBHOOK:-}" ]; then
        local threat_level
        threat_level=$(cat "$OUTPUT_FILE" | jq -r '.threat_level // "UNKNOWN"')
        local threat_score
        threat_score=$(cat "$OUTPUT_FILE" | jq -r '.threat_score // 0')
        
        if [ "$threat_score" -ge 7 ]; then
            log_warn "Enviando notificación de alerta a Slack..."
            local payload
            payload=$(cat "$OUTPUT_FILE" | jq -c --arg level "$threat_level" --arg score "$threat_score" '{
                "text": "🚨 DevOps Security Alert",
                "blocks": [
                    {
                        "type": "header",
                        "text": {"type": "plain_text", "text": "🚨 Security Alert: " + $level}
                    },
                    {
                        "type": "section",
                        "fields": [
                            {"type": "mrkdwn", "text": "*Threat Score:*\n" + ($score | tostring) + "/10"},
                            {"type": "mrkdwn", "text": "*Level:*\n" + $level}
                        ]
                    }
                ]
            }')
            curl -s -X POST -H 'Content-Type: application/json' \
                -d "$payload" \
                "$SLACK_WEBHOOK" 2>/dev/null || true
        fi
    fi
    
    # Discord webhook
    if [ -n "${DISCORD_WEBHOOK:-}" ]; then
        local threat_level
        threat_level=$(cat "$OUTPUT_FILE" | jq -r '.threat_level // "UNKNOWN"')
        local threat_score
        threat_score=$(cat "$OUTPUT_FILE" | jq -r '.threat_score // 0')
        
        if [ "$threat_score" -ge 7 ]; then
            log_warn "Enviando notificación a Discord..."
            local payload
            payload=$(cat "$OUTPUT_FILE" | jq -c --arg level "$threat_level" --arg score "$threat_score" '{
                "embeds": [{
                    "title": "🚨 DevOps Security Alert",
                    "color": 16711680,
                    "fields": [
                        {"name": "Threat Level", "value": $level, "inline": true},
                        {"name": "Score", "value": ($score | tostring) + "/10", "inline": true}
                    ]
                }]
            }')
            curl -s -X POST -H 'Content-Type: application/json' \
                -d "$payload" \
                "$DISCORD_WEBHOOK" 2>/dev/null || true
        fi
    fi
}

# ============================================
# MAIN
# ============================================

main() {
    log_info "=== DevOps Security Monitor Started ==="
    log_info "Monitoring ${#TOOLS[@]} tools for security vulnerabilities"
    log_info "Focus: Supply Chain Attack Detection"
    
    check_dependencies
    generate_report
    print_summary
    send_notifications
    
    log_info "=== DevOps Security Monitor Finished ==="
}

main "$@"
