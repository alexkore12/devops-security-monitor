# 🔒 DevOps Security Monitor

Sistema de monitoreo de seguridad automatizado para herramientas DevOps. Monitorea vulnerabilidades, advisories y tendencias de seguridad.

## 📋 Descripción

Script bash que consulta la base de datos de advisories de GitHub, monitorea tendencias de seguridad en Reddit y genera reportes JSON con alertas de vulnerabilidades críticas.

## 🛠️ Características

- 🔍 **GitHub Advisories** - Consulta vulnerabilidades conocidas
- 📊 **Reddit Trends** - Monitorea tendencias de seguridad
- 📝 **Reportes JSON** - Generación automática de reportes
- 🔔 **Slack Notifications** - Alertas a Slack (opcional)
- 🐳 **Kubernetes Ready** - Deploy en K8s
- 📈 **Métricas** - Conteo de alertas críticas

## 🚀 Instalación

### Prerrequisitos

- Bash 4+
- curl
- jq
- python3

### Pasos

```bash
# 1. Clonar
git clone https://github.com/alexkore12/devops-security-monitor.git
cd devops-security-monitor

# 2. Hacer ejecutable
chmod +x monitor.sh

# 3. Ejecutar
./monitor.sh
```

## ⚙️ Configuración

### Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `OUTPUT_DIR` | Directorio de salida | `/tmp` |
| `ALERT_THRESHOLD` | Umbral de alertas (1-10) | 7 |
| `SLACK_WEBHOOK` | Webhook de Slack | (none) |

### Herramientas Monitoreadas

```bash
# Editar en monitor.sh
TOOLS=("trivy" "docker" "kubernetes" "terraform" "ansible" "jenkins" "gitlab" "github-actions")
```

## 📡 Uso

### Ejecución Básica

```bash
./monitor.sh
```

### Con Slack

```bash
export SLACK_WEBHOOK="https://hooks.slack.com/services/XXX/YYY/ZZZ"
./monitor.sh
```

### Programar con Cron

```bash
# Ejecutar cada día a las 8 AM
0 8 * * * /path/to/monitor.sh >> /var/log/security-monitor.log 2>&1
```

## 📊 Salida

### Archivo JSON

```json
{
  "timestamp": "2026-03-21T12:00:00Z",
  "tools_checked": 8,
  "critical_alerts": 2,
  "alert_threshold": 7,
  "advisories": [...],
  "trends": [...]
}
```

### Consola

```
=== RESUMEN DE SEGURIDAD ===

🔴 ALERTAS CRÍTICAS: 2
Herramientas monitoreadas: 8

=== Últimos Advisories ===
  GHSA-xxxx: Vulnerability in trivy...
  GHSA-yyyy: Security issue in docker...

=== Tendencias de Seguridad ===
  [150] New CVE discovered - r/cybersecurity
  [89] Supply chain attack warning - r/devops
```

## 🐳 Docker

### Dockerfile

```dockerfile
FROM alpine:3.19
RUN apk add --no-cache bash curl jq python3
COPY monitor.sh /monitor.sh
RUN chmod +x /monitor.sh
WORKDIR /tmp
CMD ["/monitor.sh"]
```

### Kubernetes CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: security-monitor
spec:
  schedule: "0 8 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: monitor
            image: devops-security-monitor:latest
            env:
            - name: SLACK_WEBHOOK
              valueFrom:
                secretKeyRef:
                  name: security-secrets
                  key: slack-webhook
          restartPolicy: OnFailure
```

## 📁 Estructura

```
devops-security-monitor/
├── monitor.sh           # Script principal
├── Makefile            # Comandos útiles
├── .env.example        # Ejemplo de configuración
├── .gitignore          # Archivos ignorados
├── CONTRIBUTING.md     # Guía de contribución
├── docs/               # Documentación
├── scripts/            # Scripts auxiliares
├── k8s/                # Manifestos K8s
└── README.md           # Este archivo
```

## 🔧 Desarrollo

### Comandos Make

```bash
make help        # Mostrar ayuda
make run         # Ejecutar monitor
make docker      # Build Docker
make k8s-apply   # Aplicar a Kubernetes
make clean       # Limpiar archivos temporales
```

### Agregar Nueva Herramienta

Edita `monitor.sh` y agrega la herramienta al array `TOOLS`:

```bash
TOOLS=("trivy" "docker" "kubernetes" "terraform" "ansible" "jenkins" "gitlab" "github-actions" "nueva_herramienta")
```

## 📈 Métricas

### Severity Levels

| Nivel | Valor Numérico |
|-------|----------------|
| CRITICAL | 10 |
| HIGH | 7 |
| MEDIUM | 5 |
| LOW | 2 |
| UNKNOWN | 1 |

## 🔔 Integraciones

### Slack

```bash
export SLACK_WEBHOOK="https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX"
./monitor.sh
```

### Custom Webhook

Modifica la función `send_notifications()` en `monitor.sh`:

```bash
send_notifications() {
    if [ -n "${CUSTOM_WEBHOOK:-}" ]; then
        curl -X POST -H 'Content-Type: application/json' \
            -d "$(cat $OUTPUT_FILE)" \
            "$CUSTOM_WEBHOOK"
    fi
}
```

## 🧪 Pruebas

### Test Local

```bash
# Simular ejecución sin API calls
export OUTPUT_DIR="/tmp/test"
./monitor.sh

# Ver reporte
cat /tmp/devops_security_report.json | jq .
```

### Modo Debug

```bash
bash -x monitor.sh
```

## 📝 Changelog

- **v1.0.0** - Versión inicial
- **v1.1.0** - Reddit trends, cache, mejoras
- **v1.2.0** - Kubernetes support, Slack integration

## 🤝 Contribución

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/awesome`)
3. Commit tus cambios
4. Push y abre PR

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para detalles.

## ⚠️ Notas

- El script requiere acceso a internet
- GitHub API puede tener rate limits
- Reddit puede bloquear requests sin User-Agent

## 📄 Licencia

MIT License - Uso libre.
