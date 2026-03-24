# 🔒 DevOps Security Monitor — Automated Security Monitoring

![Shell](https://img.shields.io/badge/Shell-Bash-green?style=flat-square&logo=gnu-bash)
![Docker](https://img.shields.io/badge/Docker-Ready-blue?style=flat-square&logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Support-orange?style=flat-square&logo=kubernetes)
![Grype](https://img.shields.io/badge/Security-Grype-brightgreen?style=flat-square)
![MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)

Sistema automatizado de monitoreo de seguridad para pipelines DevOps. Detecta vulnerabilidades en contenedores y dependencias con notificaciones automáticas.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Requisitos](#-requisitos)
- [Instalación Rápida](#-instalación-rápida)
- [Uso](#-uso)
- [Configuración](#-configuración)
- [Alertas](#-alertas)
- [Kubernetes](#-kubernetes)
- [GitHub Actions](#-github-actions)
- [Estructura](#-estructura)
- [Contribución](#-contribución)

---

## ✨ Características

| Categoría | Descripción |
|-----------|-------------|
| **Escaneo de Vulnerabilidades** | Integración con Grype |
| **Dashboard de Seguridad** | Visualización de resultados |
| **Alertas** | Notificaciones de vulnerabilidades críticas |
| **Reporting** | Informes periódicos |
| **Kubernetes Ready** | Manifestos K8s incluidos |
| **Docker Support** | Contenedorizable |
| **CI/CD Integration** | GitHub Actions |
| **Multi-Registry** | Soporte para múltiples registries |

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY MONITOR                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Scheduler  │  │  Scanner    │  │      Reporter           │  │
│  │  (Cron)     │──▶│  (Grype)    │──▶│  (JSON/HTML/Slack)     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│         │                │                      │                 │
│         ▼                ▼                      ▼                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │  Config     │  │  Database   │  │      Alerter            │  │
│  │  (.env)     │  │  (JSON)     │  │  (Slack/Telegram/Email) │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
         │                │                      │
         ▼                ▼                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TARGETS                                        │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐  │
│  │ Docker Hub   │  │ GitHub CR    │  │   Kubernetes Cluster   │  │
│  │ Registries   │  │ (ghcr.io)    │  │   (ImagePullSecrets)   │  │
│  └──────────────┘  └──────────────┘  └────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📦 Requisitos

- **Bash**: 4.x+
- **Docker**: 20.x+ (para contenedor)
- **kubectl**: 1.24+ (para Kubernetes)
- **Grype**: 0.50+ (incluido en Docker image)
- **jq**: Para procesamiento de JSON
- **curl**: Para notificaciones

---

## 🚀 Instalación Rápida

### Clonar repositorio

```bash
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor
```

### Modo Script (Local)

```bash
chmod +x monitor.sh
./monitor.sh

# Ver resultado
cat /tmp/devops_security_report.json | jq
```

### Modo Docker

```bash
# Build
docker build -t devops-security-monitor:latest .

# Run
docker run devops-security-monitor:latest

# Con configuración
docker run -e GRYPE_DB_UPDATE_INTERVAL=6h \
           -e ALERT_THRESHOLD=high \
           -e SLACK_WEBHOOK=https://hooks.slack.com/... \
           devops-security-monitor:latest
```

### Docker Compose

```bash
docker-compose up -d
```

---

## 📖 Uso

### Escaneo de Imagen Docker

```bash
# Escanear imagen local
./security_scanner.sh --image tu-imagen:latest

# Escanear múltiples imágenes
./security_scanner.sh --image nginx:latest --image postgres:15

# Escanear con salida JSON
./security_scanner.sh --image tu-imagen:latest --format json
```

### Escaneo de Directorio

```bash
# Escanear código fuente
./security_scanner.sh --path ./directorio

# Escanear con exclude
./security_scanner.sh --path ./app --exclude "node_modules,vendor"
```

### Escanear Registry Remoto

```bash
# Docker Hub
./security_scanner.sh --registry docker.io --image nginx:latest

# GHCR
./security_scanner.sh --registry ghcr.io --image username/repo:latest

# Private Registry
./security_scanner.sh --registry myregistry.com --image myapp:latest \
    --username user --password pass
```

### Ver Reports

```bash
# Reporte JSON
cat /tmp/devops_security_report.json | jq

# Reporte con vulnerabilidades críticas
cat /tmp/devops_security_report.json | jq '.vulnerabilities[] | select(.severity == "Critical")'

# Historial de reportes
ls -la /tmp/devops_security_*.json
```

---

## ⚙️ Configuración

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `GRYPE_DB_UPDATE_INTERVAL` | Frecuencia de updates de BD | `6h` |
| `ALERT_THRESHOLD` | Umbral de severidad | `high` |
| `SLACK_WEBHOOK` | Webhook para alertas Slack | - |
| `TELEGRAM_BOT_TOKEN` | Token del bot de Telegram | - |
| `TELEGRAM_CHAT_ID` | Chat ID de Telegram | - |
| `EMAIL_SMTP_HOST` | Servidor SMTP | - |
| `EMAIL_SMTP_PORT` | Puerto SMTP | `587` |
| `EMAIL_TO` | Destinatario de email | - |
| `LOG_LEVEL` | Nivel de logging | `info` |

### Archivo .env

```env
# Database
GRYPE_DB_UPDATE_INTERVAL=6h
GRYPE_DB_CACHE_DIR=/tmp/grype/db

# Alerts
ALERT_THRESHOLD=high
SLACK_WEBHOOK=https://hooks.slack.com/services/XXX/YYY/ZZZ
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
TELEGRAM_CHAT_ID=-1001234567890

# Email (opcional)
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
EMAIL_FROM=alerts@example.com
EMAIL_TO=security@example.com

# Logging
LOG_LEVEL=info
```

---

## 🔔 Alertas

### Slack

```bash
# Alerta simple
./alerts.sh --level high --message "Vulnerabilidad detectada"

# Alerta con detalles
./alerts.sh \
    --level critical \
    --message "Riesgo crítico encontrado" \
    --details '{"image": "nginx:latest", "cve": "CVE-2024-1234", "severity": "Critical"}'
```

### Telegram

```bash
# Configurar primero
export TELEGRAM_BOT_TOKEN="tu-token"
export TELEGRAM_CHAT_ID="tu-chat-id"

# Enviar alerta
./alerts.sh --level medium --message "Scan completado" --telegram
```

### GitHub Advisory Database

```bash
# Ver advisories recientes
./scripts/check_advisories.sh --days 7

# Buscar advisory específico
./scripts/check_advisories.sh --cve CVE-2024-1234
```

---

## ☸️ Kubernetes

### CronJob Manifest

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: security-monitor
  namespace: security
spec:
  schedule: "0 */6 * * *"  # Cada 6 horas
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: security-monitor
          containers:
          - name: scanner
            image: devops-security-monitor:latest
            env:
              - name: ALERT_THRESHOLD
                value: "high"
              - name: SLACK_WEBHOOK
                valueFrom:
                  secretKeyRef:
                    name: alert-secrets
                    key: slack-webhook
            resources:
              requests:
                memory: "256Mi"
                cpu: "250m"
              limits:
                memory: "512Mi"
                cpu: "500m"
          restartPolicy: OnFailure
```

### Aplicar

```bash
kubectl apply -f k8s/cronjob.yaml

# Ver jobs
kubectl get jobs -n security -w

# Ver pods del monitor
kubectl get pods -n security -l app=security-monitor
```

### RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: security-monitor
  namespace: security
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: security-monitor
rules:
- apiGroups: [""]
  resources: ["pods", "secrets"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: security-monitor
subjects:
- kind: ServiceAccount
  name: security-monitor
  namespace: security
roleRef:
  kind: Role
  name: security-monitor
  apiGroup: rbac.authorization.k8s.io
```

---

## 🔄 GitHub Actions

### Workflow de Ejemplo

```yaml
name: Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 */6 * * *'  # Cada 6 horas

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Security Scanner
        uses: anchore/grype-action@v1
        with:
          image: ${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: json
          output-file: scan-results.json
          severity: medium,high,critical

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: security-scan-results
          path: scan-results.json

      - name: Post to Slack on Critical
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Security scan found critical vulnerabilities",
              "blocks": [{
                "type": "section",
                "text": {
                  "type": "mrkdwn",
                  "text": "*Critical Vulnerabilities Found*\n${{ github.repository }}:${{ github.sha }}"
                }
              }]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 📊 Reportes

### Formato JSON

```json
{
  "scan_id": "scan-20260324-120000",
  "timestamp": "2026-03-24T12:00:00Z",
  "target": {
    "type": "image",
    "name": "nginx:latest",
    "digest": "sha256:abc123..."
  },
  "summary": {
    "total": 45,
    "critical": 2,
    "high": 12,
    "medium": 20,
    "low": 11
  },
  "vulnerabilities": [
    {
      "id": "CVE-2024-1234",
      "severity": "Critical",
      "package": "openssl",
      "version": "1.1.1",
      "fixed_version": "1.1.1w",
      "description": "Buffer overflow in..."
    }
  ],
  "scan_duration_seconds": 45
}
```

---

## 📁 Estructura del Proyecto

```
devops-security-monitor/
├── .dockerignore
├── .env.example
├── .gitattributes
├── .gitignore
├── .github/
│   ├── workflows/
│   │   └── ci.yml
│   ├── ISSUE_TEMPLATE/
│   ├── dependabot.yml
│   └── PULL_REQUEST_TEMPLATE.md
├── .grype.yaml                    # Grype config
├── alerts.sh                      # Dispatch de alertas
├── CHANGELOG.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── deploy.sh                      # Script de despliegue
├── LICENSE
├── monitor.sh                     # Script principal de orquestación
├── QUICKSTART.md
├── README.md                      # Este archivo
├── scripts/
│   └── check_advisories.sh        # GitHub Advisory checker
├── SECURITY.md
├── security_scanner.sh            # Escáner principal
├── setup.sh                       # Script de inicialización
├── health_check.py                # Verificación de salud
├── docs/
│   └── architecture.md            # Documentación de arquitectura
└── k8s/
    └── cronjob.yaml               # Kubernetes CronJob
```

---

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama: `git checkout -b feature/nueva-funcionalidad`
3. Commit tus cambios: `git commit -am 'Agregar nueva funcionalidad'`
4. Push a la rama: `git push origin feature/nueva-funcionalidad'`
5. Abre un Pull Request

---

## 📚 Recursos

- [Grype Documentation](https://github.com/anchore/grype)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Advisories](https://github.com/advisories)

---

## 📄 Licencia

MIT License - ver [LICENSE](LICENSE) para detalles.

---

## 👤 Autor

**[@alexkore12](https://github.com/alexkore12)**

---

⭐ **Dale una estrella si te fue útil!**
