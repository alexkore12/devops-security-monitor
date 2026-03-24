# 🔐 DevOps Security Monitor

> Sistema integral de monitoreo de seguridad para pipelines DevOps. Detecta vulnerabilidades en contenedores, dependencias y configuración usando Grype y GitHub Advisory Database.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://docker.com)
[![Security: Grype](https://img.shields.io/badge/Security-Grype-orange.svg)](.grype.yaml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-CronJob-blue.svg)](k8s/)
[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://python.org)

## 📋 Descripción

Sistema automatizado de monitoreo de seguridad que ejecuta análisis periódicos de vulnerabilidades en contenedores y dependencias, enviando alertas cuando se detectan problemas críticos.

## ✨ Características

- 🔍 **Escaneo de Vulnerabilidades** - Grype + GitHub Advisory Database
- 📊 **Dashboard de Seguridad** - Visualización de resultados en JSON/HTML
- 🔔 **Alertas Multi-Canal** - Slack, Telegram, Email
- 📈 **Reporting** - Informes periódicos en JSON y HTML
- ☸️ **Kubernetes CronJob** - Ejecución programada automática
- 🐳 **Docker Support** - Ejecutable como contenedor
- 📦 **SBOM Generation** - Generación de Bill of Materials
- 🔄 **Baseline Comparisons** - Comparación con escaneos anteriores
- 🎯 **Threshold Alerts** - Alertas configurables por severidad
- 📜 **Audit Trail** - Logs completos de vulnerabilidades

## 🚀 Instalación

### Prerrequisitos

- Python 3.9+ o Docker
- Acceso a la registry de contenedores a escanear
- (Opcional) kubectl para Kubernetes

### Instalación Local

```bash
# Clonar repositorio
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor

# Configurar variables
cp .env.example .env
# Editar .env con tus credenciales

# Ejecutar
chmod +x monitor.sh
./monitor.sh
```

### Docker

```bash
# Construir imagen
docker build -t devops-security-monitor:latest .

# Ejecutar (configurar .env primero)
docker run -d \
  --name security-monitor \
  --env-file .env \
  -v /var/run/docker.sock:/var/run/docker.sock \
  devops-security-monitor:latest
```

### Kubernetes

```bash
# Aplicar CronJob
kubectl apply -f k8s/cronjob.yaml

# Ver estado
kubectl get cronjobs -n security

# Ejecutar manualmente
kubectl create job --from=cronjob/security-monitor manual-scan -n security
```

## ⚙️ Configuración

### Variables de Entorno

```bash
# Requeridas
SLACK_WEBHOOK=https://hooks.slack.com/services/XXX/YYY/ZZZ
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
ALERT_THRESHOLD=CRITICAL  # LOW, MEDIUM, HIGH, CRITICAL

# Opcionales
GRYPE_DB_UPDATE_INTERVAL=24h
SCAN_INTERVAL=6h
ENABLE_SBOM=true
ENABLE_EMAIL_ALERTS=true
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=587
```

### Scanning Targets

Edita `config.yaml` para definir qué imágenes/registries escanear:

```yaml
scan_targets:
  - name: production-api
    image: docker.io/alexkore12/api:latest
    schedule: "0 */6 * * *"  # Cada 6 horas
    
  - name: staging-frontend
    image: docker.io/alexkore12/frontend:latest
    schedule: "0 */12 * * *"  # Cada 12 horas
```

## 📊 Uso

### Comandos

```bash
# Escanear imagen específica
./monitor.sh scan mi-imagen:latest

# Escanear múltiples imágenes
./monitor.sh scan-all

# Generar reporte
./monitor.sh report --format=html --output=security-report.html

# Ver historial
./monitor.sh history --days=30

# Comparar con baseline
./monitor.sh compare --baseline=baseline.json
```

### API Endpoints (si usas el servidor)

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/scan` | POST | Iniciar nuevo scan |
| `/status` | GET | Estado del scanner |
| `/report` | GET | Último reporte |
| `/history` | GET | Historial de scans |
| `/health` | GET | Health check |

## 🔍 Tipos de Escaneo

### Container Image Scan

```bash
grype mi-imagen:latest \
  --scope all-layers \
  --fail-on CRITICAL \
  --output json
```

### SBOM Generation

```bash
syft mi-imagen:latest -o cyclonedx-json
```

### IaC Scanning

```bash
checkov --directory ./k8s --output json
```

## 📁 Estructura del Proyecto

```
devops-security-monitor/
├── monitor.sh              # Script principal
├── alerts.sh               # Script de alertas
├── deploy.sh               # Deployment script
├── SECURITY.md             # Política de seguridad
├── CONTRIBUTING.md         # Guía de contribución
├── .env.example            # Template variables
├── .grype.yaml             # Config Grype
├── config.yaml             # Configuración general
├── k8s/
│   └── cronjob.yaml        # Kubernetes CronJob
├── .github/
│   ├── dependabot.yml       # Dependabot config
│   └── CODEOWNERS          # Propietarios del código
├── LICENSE
└── README.md
```

## 🔔 Configuración de Alertas

### Slack

```json
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🚨 Alerta de Seguridad"
      }
    },
    {
      "type": "section",
      "fields": [
        {"type": "mrkdwn", "text": "*Imagen:*\nmi-api:latest"},
        {"type": "mrkdwn", "text": "*Severidad:*\nCRITICAL"}
      ]
    }
  ]
}
```

### Telegram

```
🚨 *Alerta de Seguridad*
━━━━━━━━━━━━━━━
📦 Imagen: mi-api:latest
⚠️ Vulnerabilidades: 5 CRITICAL
🔗 Ver detalles: [Link]
```

## 📈 Reportes

### JSON Output

```json
{
  "timestamp": "2026-03-23T22:00:00Z",
  "image": "mi-api:latest",
  "vulnerabilities": {
    "critical": 2,
    "high": 5,
    "medium": 12,
    "low": 30
  },
  "fixed_in": ["1.2.3", "1.2.4"],
  "sbom": "cyclonedx.json"
}
```

## 🔒 Seguridad

Ver [SECURITY.md](SECURITY.md) para:
- Política de revelación de vulnerabilidades
- Configuración segura
- Mejores prácticas
- Configuración de red

## 🧪 Testing

```bash
# Test local sin API keys
GRYPE_DB_UPDATE_INTERVAL=1h SLACK_WEBHOOK="" ./monitor.sh test-scan

# Verificar scanner
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  anchore/grype:latest alpine:latest
```

## 🤝 Contribuir

1. Fork → Branch → Commit → PR
2. Agregar tests para nueva funcionalidad
3. Actualizar documentación
4. Verificar que `make test` pase

## 📝 Changelog

### v2.0 (Marzo 2026)
- Integración con Telegram
- Soporte para SBOM generation
- Comparación con baselines
- Dashboard HTML

### v1.0 (Enero 2026)
- Escaneo básico con Grype
- Alertas Slack
- Kubernetes CronJob

## 📄 Licencia

MIT - ver [LICENSE](LICENSE)

## 🔗 Recursos

- [Grype Documentation](https://github.com/anchore/grype)
- [Syft Documentation](https://github.com/anchore/syft)
- [Checkov Documentation](https://www.checkov.io/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
