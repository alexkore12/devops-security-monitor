# 🔐 DevOps Security Monitor

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)

## 📋 Descripción

Sistema de monitoreo de seguridad para pipelines DevOps. Monitorea vulnerabilidades en contenedores y dependencias.

## ✨ Características

- 🔍 **Escaneo de Vulnerabilidades**: Grype integration
- 📊 **Dashboard de Seguridad**: Visualización de resultados
- 🔔 **Alertas**: Notificaciones de vulnerabilidades críticas
- 📈 **Reporting**: Informes periódicos
- ☸️ **Kubernetes Ready**: Manifestos K8s incluidos
- 🐳 **Docker Support**: Contenedorizable

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

## 📁 Estructura

```
devops-security-monitor/
├── .dockerignore
├── .env.example
├── .github/
├── .gitignore
├── .grype.yaml
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SECURITY.md
├── docker-compose.yml
├── docs/
├── k8s/
├── monitor.sh
└── security_scanner.sh
```

## 🔒 Configuración

| Variable | Descripción | Default |
|----------|-------------|---------|
| `GRYPE_DB_UPDATE_INTERVAL` | Frecuencia de updates | 6h |
| `ALERT_THRESHOLD` | Umbral de severidad | high |
| `SLACK_WEBHOOK` | Webhook para alertas | - |

## 🤝 Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md).

## 📝 Licencia

MIT - [LICENSE](LICENSE)
