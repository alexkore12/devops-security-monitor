#!/bin/bash
#
# Alerta de Monitoreo - Sistema de notificaciones para DevOps
# Uso: ./alerts.sh [comando] [parametros]
#

set -euo pipefail

# Configuración
ALERT_CONFIG="${ALERT_CONFIG:-./alert_config.yaml}"
LOG_FILE="${LOG_FILE:-/var/log/devops-alerts.log}"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log "INFO: $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log "WARN: $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log "ERROR: $1"
}

# Mostrar uso
usage() {
    cat << EOF
Uso: $0 [comando] [parametros]

Comandos:
    cpu         Verificar uso de CPU (umbral: 80%)
    memory      Verificar uso de memoria (umbral: 85%)
    disk        Verificar uso de disco (umbral: 90%)
    processes   Verificar procesos problematicos
    services    Verificar servicios críticos
    network     Verificar conectividad de red
    all         Ejecutar todas las verificaciones
    config      Mostrar configuración actual
    test        Enviar notificación de prueba

Ejemplos:
    $0 cpu
    $0 all
    $0 test

Variables de entorno:
    ALERT_CONFIG    Path al archivo de configuración
    SLACK_WEBHOOK   Webhook de Slack para alertas
    EMAIL_TO        Email para notificaciones
EOF
}

# Verificar CPU
check_cpu() {
    local threshold="${1:-80}"
    local usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    
    log_info "Verificando CPU: ${usage}% (umbral: ${threshold}%)"
    
    if [ "$usage" -gt "$threshold" ]; then
        log_error "ALERTA: CPU al ${usage}% - exceeds ${threshold}%"
        send_alert "CPU" "Critical" "Usage at ${usage}% (threshold: ${threshold}%)"
    else
        log_info "CPU dentro de parámetros: ${usage}%"
    fi
}

# Verificar Memoria
check_memory() {
    local threshold="${1:-85}"
    local usage=$(free | grep Mem | awk '{printf "%.0f", ($3/$2) * 100}')
    
    log_info "Verificando memoria: ${usage}% (umbral: ${threshold}%)"
    
    if [ "$usage" -gt "$threshold" ]; then
        log_error "ALERTA: Memoria al ${usage}% - exceeds ${threshold}%"
        send_alert "Memory" "Critical" "Usage at ${usage}% (threshold: ${threshold}%)"
    else
        log_info "Memoria dentro de parámetros: ${usage}%"
    fi
}

# Verificar Disco
check_disk() {
    local threshold="${1:-90}"
    local usage=$(df -h / | tail -1 | awk '{print int($5)}')
    
    log_info "Verificando disco: ${usage}% (umbral: ${threshold}%)"
    
    if [ "$usage" -gt "$threshold" ]; then
        log_error "ALERTA: Disco al ${usage}% - exceeds ${threshold}%"
        send_alert "Disk" "Warning" "Usage at ${usage}% (threshold: ${threshold}%)"
    else
        log_info "Disco dentro de parámetros: ${usage}%"
    fi
}

# Verificar procesos problematicos
check_processes() {
    log_info "Verificando procesos problematicos..."
    
    local high_cpu=$(ps aux --sort=-%cpu | head -6 | tail -5 | awk '{print $11, $3"%"}')
    local high_mem=$(ps aux --sort=-%mem | head -6 | tail -5 | awk '{print $11, $4"%"}')
    
    if [ -n "$high_cpu" ]; then
        log_warn "Procesos alto CPU: $high_cpu"
    fi
    
    if [ -n "$high_mem" ]; then
        log_warn "Procesos alto memoria: $high_mem"
    fi
}

# Verificar servicios criticos
check_services() {
    local services="${CRITICAL_SERVICES:-nginx docker postgresql redis}"
    
    log_info "Verificando servicios críticos: $services"
    
    for service in $services; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            log_info "✓ $service: Activo"
        else
            log_error "ALERTA: $service no está activo"
            send_alert "Service" "Critical" "$service is not running"
        fi
    done
}

# Verificar conectividad de red
check_network() {
    local hosts="${NETWORK_CHECK_HOSTS:-google.com 8.8.8.8}"
    
    log_info "Verificando conectividad de red..."
    
    for host in $hosts; do
        if ping -c 1 -W 3 "$host" &>/dev/null; then
            log_info "✓ $host: accesible"
        else
            log_error "ALERTA: No se puede alcanzar $host"
            send_alert "Network" "Warning" "Cannot reach $host"
        fi
    done
}

# Enviar alerta
send_alert() {
    local metric="$1"
    local severity="$2"
    local message="$3"
    
    log_info "Enviando alerta: $metric - $severity - $message"
    
    # Slack
    if [ -n "${SLACK_WEBHOOK:-}" ]; then
        curl -s -X POST -H 'Content-Type: application/json' \
            --data "{\"text\":\"🚨 *ALERT: $metric*\n*Severity:* $severity\n*Message:* $message\"}" \
            "$SLACK_WEBHOOK" 2>/dev/null || true
    fi
    
    # Email (requiere configuración SMTP)
    if [ -n "${EMAIL_TO:-}" ]; then
        echo -e "Subject: DevOps Alert: $metric\n\n$severity: $message" | \
            sendmail "$EMAIL_TO" 2>/dev/null || true
    fi
}

# Test de configuración
test_alerts() {
    log_info "Enviando notificación de prueba..."
    send_alert "Test" "Info" "Alerts system is working correctly"
    log_info "Notificación de prueba enviada"
}

# Mostrar configuración
show_config() {
    echo "=== Configuración de Alertas ==="
    echo "Threshold CPU: ${CPU_THRESHOLD:-80}%"
    echo "Threshold Memory: ${MEMORY_THRESHOLD:-85}%"
    echo "Threshold Disk: ${DISK_THRESHOLD:-90}%"
    echo "Servicios críticos: ${CRITICAL_SERVICES:-nginx docker postgresql redis}"
    echo "Slack Webhook: ${SLACK_WEBHOOK:-no configurado}"
    echo "Email: ${EMAIL_TO:-no configurado}"
    echo "================================"
}

# Ejecutar todas las verificaciones
run_all() {
    log_info "Iniciando verificación completa..."
    
    check_cpu
    check_memory
    check_disk
    check_processes
    check_services
    check_network
    
    log_info "Verificación completa terminada"
}

# Main
case "${1:-help}" in
    cpu) check_cpu "${2:-80}" ;;
    memory) check_memory "${2:-85}" ;;
    disk) check_disk "${2:-90}" ;;
    processes) check_processes ;;
    services) check_services ;;
    network) check_network ;;
    all) run_all ;;
    config) show_config ;;
    test) test_alerts ;;
    *) usage ;;
esac