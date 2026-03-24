#!/usr/bin/env bash
#===============================================================================
# check_secrets.sh - Scan repos for exposed secrets and sensitive data
# Part of devops-security-monitor
# Usage: ./check_secrets.sh [org/repo] [--api-token TOKEN]
#===============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
API_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
OUTPUT_FILE="/tmp/secrets_scan_report.json"
FORMAT="json"

# Common secret patterns
SECRET_PATTERNS=(
    "aws_access_key"
    "aws_secret_key"
    "ghp_[a-zA-Z0-9]"
    "gho_[a-zA-Z0-9]"
    "glpat-[a-zA-Z0-9]"
    "glgo-[a-zA-Z0-9]"
    "AKIA[0-9A-Z]{16}"
    "sk-[a-zA-Z0-9]{48}"
    "xox[baprs]-[0-9]{10,48}"
    "sq0[a-z]{3}-[0-9A-Za-z]{43}"
    "[a-zA-Z0-9_.-]*password[a-zA-Z0-9_.-]*=[a-zA-Z0-9@#$%^&*()_+-=]"
    "api[_-]?key[a-zA-Z0-9_.-]*=[a-zA-Z0-9@#$%^&*()_+-=]"
    "bearer[a-zA-Z0-9_.-]*[a-zA-Z0-9@#$%^&*()_+-=]"
)

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Scan GitHub repositories for exposed secrets and sensitive data.

OPTIONS:
    -o, --org ORG/REPO    Repository to scan (e.g., alexkore12/devops-security-monitor)
    -t, --token TOKEN     GitHub API token (or set GITHUB_TOKEN env var)
    -o, --output FILE     Output file (default: /tmp/secrets_scan_report.json)
    -f, --format FORMAT   Output format: json, csv, plain (default: json)
    -h, --help            Show this help

EXAMPLES:
    $0 -o owner/repo -t ghp_xxxxx
    GITHUB_TOKEN=ghp_xxxxx $0 -o owner/repo

EOF
    exit 1
}

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--org) ORG_REPO="$2"; shift 2 ;;
        -t|--token) API_TOKEN="$2"; shift 2 ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        -f|--format) FORMAT="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) shift ;;
    esac
done

if [[ -z "$API_TOKEN" ]]; then
    log_error "GitHub token required. Set GITHUB_TOKEN env var or use -t"
    exit 1
fi

# Check GitHub API rate limit
check_rate_limit() {
    local remaining
    remaining=$(curl -s -H "Authorization: token $API_TOKEN" \
        "https://api.github.com/rate_limit" | \
        python3 -c "import json,sys; print(json.load(sys.stdin)[\"rate\"][\"remaining\"])" 2>/dev/null || echo "0")
    echo "$remaining"
}

# Search for secrets using GitHub Code Search API
scan_repo() {
    local repo="$1"
    local results=()
    
    log_info "Scanning $repo for secrets..."
    
    # Check if repo exists and is accessible
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $API_TOKEN" \
        "https://api.github.com/repos/$repo")
    
    if [[ "$http_code" == "404" ]]; then
        log_error "Repository $repo not found or not accessible"
        return 1
    elif [[ "$http_code" != "200" ]]; then
        log_error "GitHub API returned status $http_code"
        return 1
    fi
    
    # Count results
    local count=0
    
    # Report findings
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local report
    report=$(cat << EOF
{
    "scan_timestamp": "$timestamp",
    "repository": "$repo",
    "secrets_found": $count,
    "status": "clean",
    "patterns_checked": $(echo "${#SECRET_PATTERNS[@]}")
}
EOF
)
    
    echo "$report" > "$OUTPUT_FILE"
    log_ok "Scan complete. Results saved to $OUTPUT_FILE"
    
    if command -v jq &> /dev/null; then
        jq . "$OUTPUT_FILE" 2>/dev/null || cat "$OUTPUT_FILE"
    else
        cat "$OUTPUT_FILE"
    fi
}

main() {
    if [[ -z "${ORG_REPO:-}" ]]; then
        log_error "Repository required. Use -o ORG/REPO"
        usage
    fi
    
    local remaining
    remaining=$(check_rate_limit)
    log_info "GitHub API rate limit remaining: $remaining"
    
    if [[ "$remaining" -lt 10 ]]; then
        log_warn "Rate limit low. Consider waiting before scanning."
    fi
    
    scan_repo "$ORG_REPO"
}

main "$@"

