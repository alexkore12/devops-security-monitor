# DevOps Security Monitor

Sistema de monitoreo automatizado de seguridad para herramientas DevOps, con énfasis especial en **detección de ataques a la cadena de suministro (Supply Chain Attacks)**.

## ⚠️ Alerta Reciente: Trivy Supply Chain Attack

<<<<<<< HEAD
- **Monitor de CVEs**: Consulta la base de datos de advisories de GitHub
- **Análisis de Reddit**: Scraping de tendencias de seguridad en comunidades DevOps
- **Alertas automatizadas**: Notificaciones de vulnerabilidades críticas
- **Integración con Trivy**: Escaneo de contenedores y configuración
- **Dashboard JSON**: Generación de reportes en formato JSON
=======
**Marzo 2026**: Trivy fue comprometido por segunda vez en un mes mediante un ataque a la cadena de suministro.
>>>>>>> 17cde975f33226af9b551a96579cda1da3d5307f

- **Versión comprometida**: 0.69.4
- **Vector**: GitHub Actions malicioso
- **Alternativas recomendadas**: Grype, Checkov

Este monitor incluye detección específica para estas amenazas.

## Características

### 🔍 Monitoreo de Seguridad

- **Vulnerabilidades conocidas**: Consulta la base de datos de advisories de GitHub
- **Detección de Supply Chain Attacks**: Identifica ataques a la cadena de suministro
- **Monitoreo específico de Trivy**: Alertas para versiones comprometidas
- **Tendencias de seguridad**: Monitoreo de Reddit para detección temprana

### 📊 Reportes

- Reportes en formato JSON
- Score de amenaza (1-10)
- Nivel de amenaza: CRITICAL / HIGH / MEDIUM / LOW
- Alertas de vulnerabilidades de supply chain

### 🔔 Notificaciones

- Slack Webhook
- Discord Webhook

## Uso

### Básico

```bash
./monitor.sh
```

### Con variables de entorno

```bash
# Configurar threshold de alertas
export ALERT_THRESHOLD=7

# Webhooks
export SLACK_WEBHOOK="https://hooks.slack.com/services/xxx"
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxx"

# Directorio de salida
export OUTPUT_DIR="/tmp"

./monitor.sh
```

<<<<<<< HEAD
## 🔧 Herramientas Monitoreadas

| Herramienta | Estado | Última Versión |
|-------------|--------|----------------|
| Trivy | ✅ | v0.57.0 |
| Docker | ✅ | 27.0 |
| Kubernetes | ✅ | 1.31 |
| Terraform | ✅ | 1.10 |
| Ansible | ✅ | 2.18 |
| Jenkins | ✅ | 2.480 |
| GitLab | ✅ | 17.6 |
| GitHub Actions | ✅ | - |
=======
### Programar con Cron

```bash
# Ejecutar cada hora
0 * * * * /path/to/monitor.sh >> /var/log/security.log 2>&1
```

## Configuración

### Herramientas monitoreadas
>>>>>>> 17cde975f33226af9b551a96579cda1da3d5307f

```bash
TOOLS=("trivy" "docker" "kubernetes" "terraform" "ansible" "jenkins" "gitlab" "github-actions")
```

### Versiones comprometidas conocidas

El script mantiene una lista actualizada de versiones conocidas como comprometidas:

| Herramienta | Versión | CVE | Descripción |
|------------|---------|-----|-------------|
| Trivy | 0.69.4 | - | Supply chain attack (GitHub Actions) |
| Trivy | 0.69.3 | CVE-2024-21626 | Container breakout |
| Log4j | 2.14.0 | CVE-2021-44228 | Log4Shell RCE |
| XZ | 5.6.0/5.6.1 | CVE-2024-3094 | Backdoor |

## Salida

### Archivo JSON

```json
{
  "timestamp": "2026-03-21T18:00:00Z",
  "threat_score": 8,
  "threat_level": "HIGH",
  "supply_chain_alerts": 3,
  "trivy_status": {
    "status": "installed",
    "is_compromised": false,
    "alerts": []
  },
  "supply_chain_vulnerabilities": [...],
  "trends": [...]
}
```

### Consola

```
========================================
   RESUMEN DE SEGURIDAD DevOps
========================================

Nivel de Amenaza: HIGH (Score: 8/10)
Alertas de Supply Chain: 3

=== Vulnerabilidades de Supply Chain ===
  [CRITICAL] CVE-2024-3094: Backdoor in xz/lzma (pkg: xz)
  [CRITICAL] CVE-2021-44228: Log4Shell RCE (pkg: log4j-core)

=== Tendencias de Seguridad ===
  [↑ 227] Trivy supply chain attack - r/devops
```

## Requisitos

- bash
- curl
- jq
- python3

<<<<<<< HEAD
- **Manual**: `./monitor.sh`
- **Cron**: `0 8 * * * /path/to/monitor.sh`
- **Kubernetes CronJob**: Diariamente a las 8:00 UTC

## 🛡️ Alertas

### Severidades

| Nivel | Color | Acción |
|-------|-------|--------|
| CRITICAL | 🔴 | Notificación inmediata |
| HIGH | 🟠 | Notificación en 1 hora |
| MEDIUM | 🟡 | Resumen diario |
| LOW | 🟢 | Reporte semanal |

### Canales

- **Slack**: Webhook configurado
- **Telegram**: Bot API
- **Email**: SMTP (futuro)

## 🤖 Automatización

Este proyecto fue generado automáticamente basándose en:

- Trends detectados en r/devops, r/programming, r/cybersecurity
- GitHub Advisory Database
- OpenClaw autonomous agents
=======
## Instalación

```bash
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor
chmod +x monitor.sh

# Probar
./monitor.sh
```

## Docker

```bash
docker build -t devops-security-monitor .
docker run -it -e SLACK_WEBHOOK="$SLACK_WEBHOOK" devops-security-monitor
```
>>>>>>> 17cde975f33226af9b551a96579cda1da3d5307f

## Kubernetes

Ver directorio `k8s/` para manifests de despliegue.

## Contribuir

Ver `CONTRIBUTING.md` para guidelines.

## Licencia

<<<<<<< HEAD
*Monitoreo activado: 2026-03-21*
=======
MIT
>>>>>>> 17cde975f33226af9b551a96579cda1da3d5307f
