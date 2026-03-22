# DevOps Security Monitor

Sistema de monitoreo automatizado de seguridad para herramientas DevOps, con énfasis especial en **detección de ataques a la cadena de suministro (Supply Chain Attacks)**.

## ⚠️ Alerta Reciente: Trivy Supply Chain Attack (2° Ataque)

**Marzo 2026**: Trivy fue comprometido por **segunda vez** en un mes mediante un sofisticado ataque a la cadena de suministro.

### Detalles del Ataque (19-21 Marzo 2026)

| Aspecto | Detalle |
|---------|---------|
| **Versiones comprometidas** | Trivy v0.69.4, trivy-action, setup-trivy |
| **Actor malicioso** | "TeamPCP" |
| **Vector de ataque** | GitHub Actions compromiso |
| **Impacto** | Infostealer --roba credenciales CI/CD |
| **C2 Domain** | scan.aquasecurtiy[.]org |
| **IP Maliciosa** | 45.148.10.212 |

### Acciones Realizadas por Atacantes
- Force-push a 75 de 76 tags en trivy-action
- Compromiso de 3 componentes core
- Distribución de infostealer silente

### Versiones Seguras
| Componente | Versión Segura | Commit |
|-------------|----------------|--------|
| Trivy | v0.69.3 | - |
| trivy-action | v0.35.0 | 57a97c7 |
| setup-trivy | v0.2.6 | 3fb12ec |

### Acción Recomendada
1. **INMEDIATO**: Rotar todos los secretos en pipelines
2. NO usar Trivy v0.69.4
3. Bloquear dominio/IP maliciosa
4. Migrar a Grype o Checkov

**Este monitor incluye detección específica para estas amenazas.**

## 🔐 Alternativas a Trivy Recomendadas

Dado los recientes ataques a la cadena de suministro de Trivy (2° ataque en Marzo 2026), se recomiendan las siguientes alternativas:

### Grype

Escáner de vulnerabilidades de código abierto desarrollado por Anchore.

```bash
# Instalación
brew install grype

# Escaneo de imagen
grype nginx:latest

# Escaneo de directorio
grype dir:/path/to/project

# Generar SBOM
grype sbom:nginx:latest -o json
```

**Ventajas:**
- Base de datos de vulnerabilidades actualizada frecuentemente
- Soporte para múltiples formatos de SBOM (CycloneDX, SPDX, Syft)
- Integración con GitHub Actions
- Menor superficie de ataque (menos dependencias)

### Checkov

Escáner de infraestructura como código (IaC) de Prisma Cloud.

```bash
# Instalación
pip install checkov

# Escaneo Terraform
checkov -d /path/to/terraform

# Escaneo Docker
checkov -f Dockerfile

# Escaneo Kubernetes
checkov -d /path/to/k8s
```

**Ventajas:**
- Más de 1000 políticas predefinidas
- Soporte para Terraform, CloudFormation, Kubernetes, Docker, Azure ARM, etc.
- Integración con CI/CD
- Salida en múltiples formatos (JSON, SARIF, JUnit XML)

### Comparativa

| Característica | Grype | Checkov | Trivy |
|---------------|-------|---------|-------|
| Vulnerabilidades Container | ✅ | ❌ | ✅ |
| IaC Scanning | ❌ | ✅ | Parcial |
| Velocidad | Rápido | Medio | Rápido |
| SBOM Support | ✅ | ✅ | ✅ |
| Supply Chain Security | ✅ | ✅ | ⚠️ Comprometido |

## Características

### 🔍 Monitoreo de Seguridad

- **Vulnerabilidades conocidas**: Consulta la base de datos de advisories de GitHub
- **Detección de Supply Chain Attacks**: Identifica ataques a la cadena de suministro
- **Monitoreo específico de Trivy**: Alertas para versiones comprometidas
- **Tendencias de seguridad**: Monitoreo de Reddit para detección temprana
- **Soporte para alternativas**: Detección de Grype y Checkov

### 📊 Reportes

- Reportes en formato JSON
- Score de amenaza (1-10)
- Nivel de amenaza: CRITICAL / HIGH / MEDIUM / LOW
- Alertas de vulnerabilidades de supply chain

### 🔔 Notificaciones

- Slack Webhook
- Discord Webhook
- Telegram Bot (futuro)

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

### Programar con Cron

```bash
# Ejecutar cada hora
0 * * * * /path/to/monitor.sh >> /var/log/security.log 2>&1
```

## Configuración

### Herramientas monitoreadas

```bash
TOOLS=("trivy" "grype" "checkov" "docker" "kubernetes" "terraform" "ansible" "jenkins" "gitlab" "github-actions")
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
    "status": "compromised",
    "version": "0.69.4",
    "is_compromised": true,
    "alert": "Supply chain attack detected"
  },
  "alternatives_recommended": ["grype", "checkov"],
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

=== Estado de Herramientas de Seguridad ===
  [ALERT] Trivy: Versión 0.69.4 comprometida
  [INFO] Grype: Disponible (v0.80.0)
  [INFO] Checkov: Disponible (v3.0.0)

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

## Kubernetes

Ver directorio `k8s/` para manifests de despliegue.

## Contribuir

Ver `CONTRIBUTING.md` para guidelines.

## 🔄 GitHub Actions - Monitoreo Automatizado

El proyecto incluye un workflow de GitHub Actions en `.github/workflows/security.yml`:

###触发器

| Trigger | Descripción |
|---------|-------------|
| `schedule` | Cada hora (cron: `0 * * * *`) |
| `push` | En push a main |
| `workflow_dispatch` | Ejecución manual |

### Jobs

| Job | Descripción |
|-----|-------------|
| **security-scan** | Ejecuta monitor.sh, verifica herramientas |
| **notify** | Envía alertas a Slack (configurable) |

### Configuración de Secrets

| Secret | Descripción |
|--------|-------------|
| `SLACK_WEBHOOK` | Webhook de Slack para notificaciones |

### Uso Manual

```bash
# Ejecutar workflow manualmente
gh workflow run security.yml
```

## Licencia

MIT

---

*Monitoreo activado: 2026-03-21*
*Actualizado: 2026-03-22 - Agregadas alternativas Grype y Checkov*
*Actualizado: 2026-03-22 - Agregado GitHub Actions CI/CD*
