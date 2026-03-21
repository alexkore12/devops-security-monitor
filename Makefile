.PHONY: help install test run clean

help:
	@echo "DevOps Security Monitor - Comandos disponibles"
	@echo ""
	@echo "make install    - Instalar dependencias"
	@echo "make test       - Ejecutar tests"
	@echo "make run        - Ejecutar monitor"
	@echo "make clean      - Limpiar archivos temporales"
	@echo "make docker     - Ejecutar con Docker"

install:
	@echo "Instalando dependencias..."
	chmod +x monitor.sh
	chmod +x scripts/*.sh

test:
	@echo "Ejecutando tests..."
	./monitor.sh
	@echo "Validando JSON..."
	cat /tmp/devops_security_report.json | jq .

run:
	@echo "Ejecutando monitor..."
	./monitor.sh

clean:
	@echo "Limpiando..."
	rm -f /tmp/devops_security_*.json
	rm -f /tmp/devops_security.log
	rm -f /tmp/reddit_*.json

docker:
	@echo "Ejecutando con Docker..."
	docker build -t devops-monitor .
	docker run -v /tmp:/tmp devops-monitor
