# DevOps Security Monitor

Monitoreo automatizado de vulnerabilidades en herramientas y flujos DevOps. Detecta tendencias de seguridad, vulnerabilidades CVEs, y alertas en tiempo real.

## 🎯 Características

- **Monitor de CVEs**: Consulta la base de datos de advisories de GitHub
- **Análisis de Reddit**: Scraping de tendencias de seguridad en comunidades DevOps
- **Alertas automatizadas**: Notificaciones de vulnerabilidades críticas
- **Integración con Trivy**: Escaneo de contenedores y configuración
- **Dashboard JSON**: Generación de reportes en formato JSON

## 📂 Estructura

```
devops-security-monitor/
├── README.md                    # Este archivo
├── monitor.sh                   # Script principal de monitoreo
├── scripts/
│   ├── check_advisories.sh      # Consulta GitHub Advisory Database
│   ├── reddit_scraper.sh        # Scraping de tendencias Reddit
│   └── notify.sh                # Sistema de notificaciones
├── k8s/
│   ├── deployment.yaml          # Deployment Kubernetes
│   ├── service.yaml             # Servicio Kubernetes
│   └── cronjob.yaml             # CronJob para ejecución periódica
└── docs/
    └── architecture.md          # Documentación de arquitectura
```

## 🚀 Uso Rápido

### Instalación

```bash
# Clonar repositorio
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor

# Hacer ejecutable
chmod +x monitor.sh
```

### Ejecución

```bash
# Monitoreo completo
./monitor.sh

# Solo advisory check
./scripts/check_advisories.sh

# Solo scraping Reddit
./scripts/reddit_scraper.sh
```

### Configuración

Crear archivo `.env`:

```bash
export GITHUB_TOKEN="ghp_xxxx"          # Token GitHub (opcional, para mayor rate limit)
export SLACK_WEBHOOK="https://hooks.slack.com/..."
export TELEGRAM_BOT_TOKEN=""
export TELEGRAM_CHAT_ID=""
export ALERT_THRESHOLD=7                 # Nivel mínimo de severidad (1-10)
```

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

## 📊 Salida

### JSON Report

```json
{
  "timestamp": "2026-03-21T12:00:00Z",
  "tools_checked": 8,
  "critical_alerts": 2,
  "advisories": [
    {
      "ghsa_id": "GHSA-xxxx-xxxx",
      "tool": "trivy",
      "severity": "HIGH",
      "summary": "..."
    }
  ],
  "trends": [
    {
      "source": "reddit",
      "subreddit": "r/devops",
      "title": "Trivy Supply Chain Attack",
      "score": 227
    }
  ]
}
```

## 🔄 Integración con Kubernetes

```bash
# Aplicar manifiestos
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Programar ejecución diaria
kubectl apply -f k8s/cronjob.yaml
```

## 📅 Programación

El monitor puede ejecutarse:

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

## 📝 Licencia

MIT License - Ver archivo LICENSE para detalles.

## 👤 Autor

- **GitHub**: [alexkore12](https://github.com/alexkore12)
- **Proyecto**: OpenClaw AI Assistant

---

*Monitoreo activado: 2026-03-21*
