# DevOps Security Monitor

Monitoreo automatizado de vulnerabilidades en herramientas y flujos DevOps. Detecta tendencias de seguridad, vulnerabilidades CVEs, y alertas en tiempo real.

## 🎯 Características

- **Monitor de CVEs**: Consulta la base de datos de advisories de GitHub
- **Análisis de Reddit**: Scraping de tendencias de seguridad en comunidades DevOps
- **Alertas automatizadas**: Notificaciones de vulnerabilidades críticas
- **Integración con Trivy**: Escaneo de contenedores y configuración
- **Dashboard JSON**: Generación de reportes en formato JSON
- **Monitoreo de Supply Chain**: Detección de ataques en la cadena de suministro

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

## ⚠️ Alerta de Seguridad: Trivy Supply Chain Attack (SEGUNDO ATAQUE)

**⚠️ URGENTE - Segundo ataque detectado: 21-Marzo-2026**

Se han detectado **DOS ataques de supply chain** contra Trivy en menos de un mes:

### Primer Ataque (Febrero 2026)
| Publicación | Puntos | Subtema |
|-------------|--------|---------|
| Auto removal of posts from new accounts | 202 | Supply Chain |
| Trivy - Supply chain attack | 106 | Vulnerabilidad Crítica |
| A Technical Write Up on the Trivy Supply Chain Attack | 33 | Análisis Técnico |

### ⚠️ Segundo Ataque (21-Marzo 2026) - CRÍTICO
| Aspecto | Detalle |
|---------|---------|
| Versiones afectadas | 0.69.4 (maliciosa), 0.69.3, 0.69.2, 0.69.1, 0.69.0 |
| Vector de ataque | GitHub Actions comprometidas (aquasecurity/setup-trivy, aquasecurity/trivy-action) |
| Severidad | CRÍTICA - Ejecución de código arbitrario |
| Impacto | CI/CD pipelines comprometidos |

### Recomendaciones INMEDIATAS

1. **Verificar versión de Trivy**: 
   ```bash
   trivy --version
   # Si es 0.69.x → ACTUALIZAR INMEDIATAMENTE
   ```

2. **Revisar GitHub Actions**: 
   - Verificar uso de `aquasecurity/setup-trivy`
   - Considerar descarga directa de binarios

3. **Firmas de verificación**: Verificar integridad de binarios con signatures
   ```bash
   # Verificar checksum
   cosign verify --key cosign.pub ghcr.io/aquasecurity/trivy:latest
   ```

4. **Escaneo en local**: Ejecutar escaneos en entornos aislados
5. **Monitoreo continuo**: Usar este monitor para detectar nuevas amenazas

```bash
# Verificar versión instalada
trivy --version

# Actualizar DB
trivy db update

# Escaneo completo
trivy fs --security-checks vuln,config .

# Si está comprometido: reinstalar desde fuente confiable
# Descargar desde: https://github.com/aquasecurity/trivy/releases
```

## 🔧 Herramientas Monitoreadas

| Herramienta | Estado | Última Versión |
|-------------|--------|----------------|
| Trivy | ⚠️ | v0.57.0 (verificar) |
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
- **Alertas de Supply Chain**: Trivy vulnerability news (Marzo 2026)

## 🛠️ Desarrollo

### Agregar nueva herramienta

Editar el array `TOOLS` en `monitor.sh`:

```bash
TOOLS=("trivy" "docker" "kubernetes" "terraform" "nueva-herramienta")
```

### Agregar nuevo canal de notificaciones

Editar la función `send_notifications()` en `monitor.sh`.

## 📝 Licencia

MIT License - Ver archivo LICENSE para detalles.

## 👤 Autor

- **GitHub**: [alexkore12](https://github.com/alexkore12)
- **Proyecto**: OpenClaw AI Assistant

---

*Monitoreo activado: 2026-03-21*
*Última actualización: 2026-03-21 16:05 - Segundo ataque supply chain Trivy documentado*

---

## 🚨 Alertas en Tiempo Real

Este monitor ahora incluye detección automática de:

- **CVE-2024-21626 Trivy** - Escape de contenedor (primer ataque)
- **Trivy v0.69.4 supply chain** - Segundo ataque (21-Mar-2026)
- **CVE-2026-28500 ONNX** - CVSS 9.1, silent=True
- **GitHub Actions comprometidas** - Vector del segundo ataque

Ejecutar `./monitor.sh` para obtener alertas actualizadas.
