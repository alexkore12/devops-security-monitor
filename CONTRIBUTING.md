# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir al Security Monitor!

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Setup](#setup)
- [Cómo Contribuir](#cómo-contribuir)
- [Estándares de Código](#estándares-de-código)
- [Scripts](#scripts)
- [Testing](#testing)
- [Security](#security)

## Código de Conducta

Mantén un ambiente respetuoso y profesional.

## Setup

### Prerequisites

```bash
# Herramientas requeridas
brew install grype        # Scanner de vulnerabilidades
pip install checkov       # IaC scanner
docker --version           # Container runtime
kubectl                    # Kubernetes CLI (opcional)
```

### Instalación

```bash
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor

# Configurar
cp .env.example .env
# Editar .env con tus credenciales

# Verificar
./monitor.sh verify
```

## Cómo Contribuir

### Issues

- 🐛 Bug reports con steps para reproducir
- 💡 Feature requests con use cases
- 🔒 Security findings (ver SECURITY.md)

### Pull Requests

1. Fork → Branch
2. Code → Test
3. Commit → Push → PR

## Estándares de Código

### Shell Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${LOG_FILE:-/var/log/security-monitor.log}"
readonly GRYPE_DB_UPDATE_INTERVAL="${GRYPE_DB_UPDATE_INTERVAL:-24h}"

# Logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
log_info() { log "INFO: $*"; }
log_warn() { log "WARN: $*"; }
log_error() { log "ERROR: $*" >&2; }

# Error handler
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Verify prerequisites
check_prereqs() {
    command -v grype >/dev/null || error_exit "Grype not installed"
    command -v docker >/dev/null || error_exit "Docker not installed"
}
```

### Python (si aplica)

```python
#!/usr/bin/env python3
"""Security monitoring utilities."""

import logging
import sys
from dataclasses import dataclass
from enum import Enum
from typing import Optional

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


class Severity(Enum):
    UNKNOWN = "Unknown"
    LOW = "Low"
    MEDIUM = "Medium"
    HIGH = "High"
    CRITICAL = "Critical"


@dataclass
class Vulnerability:
    id: str
    severity: Severity
    package: str
    description: str
    fixed_in: Optional[str] = None


def scan_image(image: str) -> list[Vulnerability]:
    """Scan Docker image for vulnerabilities."""
    logger.info(f"Scanning image: {image}")
    # Implementation
    return []
```

## Scripts

### monitor.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Load configuration
source .env

case "${1:-help}" in
    scan)
        ./monitor.sh scan-all
        ;;
    scan-all)
        echo "Scanning all targets..."
        # Implementation
        ;;
    report)
        ./monitor.sh report --format="${2:-json}"
        ;;
    verify)
        echo "Verifying prerequisites..."
        command -v grype >/dev/null && echo "✅ Grype"
        command -v docker >/dev/null && echo "✅ Docker"
        ;;
    *)
        echo "Usage: $0 {scan|scan-all|report|verify}"
        ;;
esac
```

### alerts.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

send_slack_alert() {
    local severity="$1"
    local message="$2"
    local image="$3"
    
    local payload=$(cat <<EOF
{
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "🚨 Security Alert: ${severity}"
            }
        },
        {
            "type": "section",
            "fields": [
                {"type": "mrkdwn", "text": "*Image:*\n${image}"},
                {"type": "mrkdwn", "text": "*Severity:*\n${severity}"}
            ]
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "${message}"
            }
        }
    ]
}
EOF
)
    
    curl -s -X POST \
        -H 'Content-type: application/json' \
        -d "${payload}" \
        "${SLACK_WEBHOOK}"
}

send_telegram_alert() {
    local severity="$1"
    local message="$2"
    local image="$3"
    
    local text="🚨 *Security Alert: ${severity}*

📦 Image: ${image}
⚠️ ${message}"

    curl -s -X POST \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}&text=${text}&parse_mode=Markdown"
}
```

## Testing

```bash
# Test sin API calls (dry run)
DRY_RUN=true ./monitor.sh scan alpine:latest

# Verificar scanner
docker run --rm anchore/grype:latest alpine:latest

# Test de alertas
MOCK_ALERTS=true ./monitor.sh test-alerts
```

## Security

### No Loggear Secrets

```bash
# ❌ BAD
log "Token: ${API_TOKEN}"

# ✅ GOOD
log "Token: ***"
```

### Validate Input

```bash
validate_image() {
    local image="$1"
    if [[ ! "$image" =~ ^[a-zA-Z0-9._/-]+:[a-zA-Z0-9._-]+$ ]]; then
        error_exit "Invalid image format: $image"
    fi
}
```

## 📧 Contacto

Issues: https://github.com/alexkore12/devops-security-monitor/issues

---

¡Gracias por contribuir! 🙏
