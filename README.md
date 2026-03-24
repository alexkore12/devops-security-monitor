# DevOps Security Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-blue.svg)](.github/workflows/ci.yml)
[![Dependabot](https://img.shields.io/badge/Dependabot-Enabled-brightgreen.svg)](.github/dependabot.yml)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-Passed-green.svg)](.github/workflows/ci.yml)

## 📋 Descripción

Sistema automatizado de monitoreo de seguridad para pipelines DevOps. Detecta vulnerabilidades en contenedores y dependencias.

## ✨ Características

- 🔍 **Escaneo de Vulnerabilidades**: Integración con Grype
- 📊 **Dashboard de Seguridad**: Visualización de resultados
- 🔔 **Alertas**: Notificaciones de vulnerabilidades críticas
- 📈 **Reporting**: Informes periódicos
- ☸️ **Kubernetes Ready**: Manifestos K8s incluidos
- 🐳 **Docker Support**: Contenedorizable
- 🛡️ **CI/CD Integration**: GitHub Actions

## 🚀 Instalación

### Local

```bash
chmod +x monitor.sh
./monitor.sh
```

### Docker

```bash
docker build -t devops-security-monitor .
docker run devops-security-monitor
```

### Docker Compose

```bash
docker-compose up -d
```

## 📁 Estructura

```
devops-security-monitor/
├── .dockerignore
├── .env.example
├── .gitattributes
├── .gitignore
├── .github/
│   ├── workflows/ci.yml
│   ├── ISSUE_TEMPLATE/
│   ├── dependabot.yml
│   └── PULL_REQUEST_TEMPLATE.md
├── .grype.yaml              # Grype vulnerability scanner config
├── alerts.sh                # Dispatch de alertas a Slack/Telegram
├── CHANGELOG.md
├── CODEOWNERS
├── CONTRIBUTING.md
├── deploy.sh                 # Script de despliegue
├── LICENSE
├── monitor.sh                 # Script principal de orquestación
├── QUICKSTART.md
├── README.md
├── scripts/
│   └── check_advisories.sh  # GitHub Advisory Database checker
├── SECURITY.md
├── security_scanner.sh        # Escáner de vulnerabilidades (Trivy/Grype)
├── setup.sh                   # Script de inicialización
├── health_check.py            # Verificación de salud
├── docs/
│   └── architecture.md       # Documentación de arquitectura
└── k8s/
    └── cronjob.yaml          # Kubernetes CronJob manifest
```

## 🔧 Configuración

| Variable | Descripción | Default |
|----------|-------------|---------|
| `GRYPE_DB_UPDATE_INTERVAL` | Frecuencia de updates | 6h |
| `ALERT_THRESHOLD` | Umbral de severidad | high |
| `SLACK_WEBHOOK` | Webhook para alertas | - |

## 🛡️ Escaneo de Seguridad

```bash
# Escanear imagen Docker
./security_scanner.sh --image tu-imagen

# Escanear directorio local
./security_scanner.sh --path ./directorio

# Escanear con formato JSON
./security_scanner.sh --format json
```

## 🚨 Envío de Alertas

```bash
# Enviar alerta de prueba
./alerts.sh --level high --message "Vulnerabilidad detectada"

# Con webhook de Slack
SLACK_WEBHOOK="https://hooks.slack.com/..." ./alerts.sh \
  --level critical --message "Riesgo crítico encontrado"

# Con Telegram
TELEGRAM_BOT_TOKEN="..." TELEGRAM_CHAT_ID="..." ./alerts.sh \
  --level medium --message "Scan completado"
```

## 📊 Reportes

Los reportes JSON se guardan en `/tmp/devops_security_report.json`.
Los logs en `/tmp/devops_security.log`.

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## 📝 Licencia

MIT - ver [LICENSE](LICENSE).

---

⭐️ Dale una estrella si este proyecto te fue útil!

---
⌨️ with ❤️ by [@alexkore12](https://github.com/alexkore12)
