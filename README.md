# 🔐 DevOps Security Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)

## 📋 Descripción

Sistema de monitoreo de seguridad para pipelines DevOps. Monitorea vulnerabilidades en contenedores y dependencias usando Grype y GitHub Advisory Database.

## ✨ Características

- 🔍 **Escaneo de Vulnerabilidades**: Grype + GitHub Advisory Database
- 📊 **Dashboard de Seguridad**: Visualización de resultados JSON
- 🔔 **Alertas**: Notificaciones via Slack/Telegram
- 📈 **Reporting**: Informes periódicos en JSON
- ☸️ **Kubernetes Ready**: CronJob manifests incluidos
- 🐳 **Docker Support**: Contenedorizable

## 🚀 Instalación

### Local

```bash
# Clonar el repositorio
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor

# Configurar variables de entorno
cp .env.example .env
# Editar .env: SLACK_WEBHOOK, TELEGRAM_BOT_TOKEN, GRYPE_DB_UPDATE_INTERVAL, ALERT_THRESHOLD

# Ejecutar
chmod +x monitor.sh
./monitor.sh
```

### Docker

```bash
# Construir imagen
docker build -t devops-security-monitor .

# Ejecutar (configura tu .env primero)
docker run --env-file .env devops-security-monitor
```

### Kubernetes

```bash
# Aplicar el CronJob
kubectl apply -f k8s/cronjob.yaml

# Ver jobs
kubectl get jobs --namespace=devops-security
```

## 📁 Estructura del Proyecto

```
devops-security-monitor/
├── .dockerignore
├── .env.example
├── .github/
├── .gitignore
├── .grype.yaml              # Grype vulnerability scanner config
├── CHANGELOG.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── LICENSE
├── QUICKSTART.md
├── README.md
├── SECURITY.md
├── alerts.sh                # Alert dispatch (Slack/Telegram)
├── deploy.sh                # Deployment script
├── docs/
│   └── architecture.md      # Architecture documentation
├── health_check.py          # Health check script
├── k8s/
│   └── cronjob.yaml         # Kubernetes CronJob manifest
├── monitor.sh               # Main orchestration script
├── scripts/
│   └── check_advisories.sh  # GitHub Advisory Database checker
├── security_scanner.sh      # Container vulnerability scanner
└── setup.sh                 # Setup/installation script
```

## ⚙️ Configuración

| Variable | Descripción | Default |
|----------|-------------|---------|
| `GRYPE_DB_UPDATE_INTERVAL` | Frecuencia de updates de DB | 6h |
| `ALERT_THRESHOLD` | Umbral de severidad | high |
| `SLACK_WEBHOOK` | Webhook para alertas Slack | - |
| `TELEGRAM_BOT_TOKEN` | Token del bot de Telegram | - |
| `TELEGRAM_CHAT_ID` | Chat ID para Telegram | - |
| `GITHUB_TOKEN` | Token GitHub (para mayor rate limit) | - |

## 📊 Herramientas Soportadas

El monitor revisa advisories para:
- `trivy`
- `docker`
- `grype`
- `checkov`

Para agregar más herramientas, edita el array `TOOLS` en `monitor.sh`.

## 📊 Reportes

- **JSON Reports**: `/tmp/devops_security_report.json`
- **Logs**: `/tmp/devops_security.log`

## 🔧 Arquitectura

Ver [docs/architecture.md](docs/architecture.md) para detalles completos.

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ GitHub Advisory │────▶│   monitor.sh     │────▶│  JSON Report    │
│    API          │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                │
                                ▼
                        ┌──────────────────┐
                        │  Notifications   │
                        │ (Slack/Telegram) │
                        └──────────────────┘
```

## 🤝 Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md).

## 📝 Licencia

MIT - [LICENSE](LICENSE)
