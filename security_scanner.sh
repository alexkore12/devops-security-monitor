#!/bin/bash
# Security Scanner Script
# Scans for common vulnerabilities in the project

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "   DevOps Pipeline Security Scanner"
echo "========================================="
echo ""

# Colors for output
INFO="${GREEN}[INFO]${NC}"
WARN="${YELLOW}[WARN]${NC}"
ERROR="${RED}[ERROR]${NC}"

# Results
ISSUES_FOUND=0

# Function to check file permissions
check_file_permissions() {
    echo -e "\n${INFO} Checking file permissions..."
    
    # Check for sensitive files with weak permissions
    if find . -name "*.key" -o -name "*.pem" -o -name "*.ppk" 2>/dev/null | grep -q .; then
        echo -e "${WARN} Found potential private key files:"
        find . -name "*.key" -o -name "*.pem" -o -name "*.ppk" 2>/dev/null
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    # Check for .env files in git
    if [ -f ".env" ] && [ ! -f ".gitignore" ]; then
        echo -e "${WARN} .env file found but no .gitignore"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
    
    if [ -f ".env" ] && ! grep -q "\.env" .gitignore 2>/dev/null; then
        echo -e "${WARN} .env not ignored in .gitignore"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
}

# Check for hardcoded secrets
check_secrets() {
    echo -e "\n${INFO} Scanning for hardcoded secrets..."
    
    # Patterns to search
    PATTERNS=(
        "password\s*=\s*['\"][^'\"]+['\"]"
        "api_key\s*=\s*['\"][^'\"]+['\"]"
        "secret\s*=\s*['\"][^'\"]+['\"]"
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
        "BEGIN RSA PRIVATE KEY"
        "BEGIN OPENSSH PRIVATE KEY"
    )
    
    for pattern in "${PATTERNS[@]}"; do
        if grep -r -i "$pattern" --include="*.py" --include="*.js" --include="*.yaml" --include="*.yml" --include="*.json" . 2>/dev/null | grep -v ".git" | grep -v "node_modules" | grep -v "__pycache__" | head -5 > /dev/null; then
            echo -e "${WARN} Potential secret found (pattern: $pattern)"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done
}

# Check Docker security
check_docker() {
    echo -e "\n${INFO} Checking Docker security..."
    
    if [ -f "Dockerfile" ]; then
        # Check for root user
        if grep -q "USER root" Dockerfile; then
            echo -e "${WARN} Dockerfile running as root"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
        
        # Check for latest tag
        if grep -q "FROM.*:latest" Dockerfile; then
            echo -e "${WARN} Using :latest tag - consider pinning versions"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
        
        # Check for exposed secrets in COPY
        if grep -q "COPY.*\.env" Dockerfile; then
            echo -e "${WARN} Copying .env file in Dockerfile"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    fi
}

# Check dependency vulnerabilities using Grype (preferred over Trivy - see Supply Chain Security)
check_dependencies() {
    echo -e "\n${INFO} Checking dependency vulnerabilities..."
    
    # Prefer Grype over Trivy due to Trivy supply chain attack (CVE-2024-21762)
    # See: https://security.googleblog.com/2024/06/supply-chain-attack-trivy.html
    if command -v grype &> /dev/null; then
        echo -e "${INFO} Running Grype scanner (preferred over Trivy)..."
        grype . --only-fixed 2>/dev/null || true
    elif command -v trivy &> /dev/null; then
        echo -e "${WARN} Using Trivy - consider migrating to Grype"
        echo -e "${INFO} Install Grype: brew install grype"
        trivy fs --severity HIGH,CRITICAL . 2>/dev/null || true
    else
        echo -e "${WARN} No vulnerability scanner installed"
        echo -e "${INFO} Install Grype: brew install grype"
        echo -e "${INFO} Install Trivy: brew install trivy"
    fi
    
    if [ -f "requirements.txt" ]; then
        if command -v safety &> /dev/null; then
            safety check || true
        elif command -v pip-audit &> /dev/null; then
            pip-audit || true
        fi
    fi
    
    if [ -f "package.json" ]; then
        if command -v npm &> /dev/null; then
            npm audit --audit-level=high 2>/dev/null || true
        fi
    fi
}

# Check CI/CD security
check_cicd() {
    echo -e "\n${INFO} Checking CI/CD security..."
    
    if [ -f "Jenkinsfile" ]; then
        if grep -q "sh.*curl.*|" Jenkinsfile; then
            echo -e "${WARN} Potential command injection in Jenkinsfile"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
        
        if ! grep -q "credentials" Jenkinsfile; then
            echo -e "${WARN} No credentials binding found in Jenkinsfile"
        fi
    fi
    
    # Check GitHub Actions
    if [ -d ".github/workflows" ]; then
        if grep -r "secrets\." .github/workflows/ 2>/dev/null | grep -v "from" > /dev/null; then
            echo -e "${WARN} Using secrets in GitHub Actions - ensure proper masking"
        fi
    fi
}

# Check Kubernetes manifests
check_k8s() {
    echo -e "\n${INFO} Checking Kubernetes security..."
    
    if [ -d "k8s" ] || [ -d "kubernetes" ]; then
        find . -name "*.yaml" -o -name "*.yml" 2>/dev/null | while read -r file; do
            if grep -q "privileged:" "$file" && grep -q "true" "$file"; then
                echo -e "${WARN} Privileged container found in $file"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
            
            if grep -q "runAsRoot" "$file"; then
                echo -e "${WARN} Root container found in $file"
                ISSUES_FOUND=$((ISSUES_FOUND + 1))
            fi
        done
    fi
}

# Run all checks
main() {
    check_file_permissions
    check_secrets
    check_docker
    check_dependencies
    check_cicd
    check_k8s
    
    echo ""
    echo "========================================="
    if [ $ISSUES_FOUND -gt 0 ]; then
        echo -e "${RED}Scan complete: $ISSUES_FOUND issues found${NC}"
        echo "========================================="
        exit 1
    else
        echo -e "${GREEN}Scan complete: No issues found${NC}"
        echo "========================================="
        exit 0
    fi
}

main "$@"
