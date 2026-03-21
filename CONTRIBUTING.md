# Contribución a DevOps Security Monitor

¡Gracias por tu interés en contribuir!

## Formas de Contribuir

1. **Reportar bugs** - Abre un issue
2. **Sugerir features** - Crea un issue con la etiqueta "enhancement"
3. **Pull requests** - Envía mejoras

## Proceso de Desarrollo

### Entorno Local

```bash
# Clonar repositorio
git clone https://github.com/alexkore12/devops-security-monitor.git

# Crear branch
git checkout -b feature/nueva-caracteristica

# Desarrollo
./monitor.sh

# Testing
./scripts/test.sh

# Commit
git add .
git commit -m "feat: nueva característica"

# Push
git push origin feature/nueva-caracteristica
```

## Estándares de Código

### Bash

- Usar `set -euo pipefail`
- Funciones con documentación
- Nombres descriptivos
- Comentar código complejo

### JSON

- Validar con `jq`
- Usar pretty print para lectura

## Testing

```bash
# Test de integración
./scripts/test_integration.sh

# Test de unit
./scripts/test_unit.sh

# Validar output JSON
./monitor.sh | jq .
```

## Proceso de Pull Request

1. Fork del repositorio
2. Crear branch feature
3. Asegurar que tests pasen
4. Actualizar documentación
5. Describir cambios en PR

## Commits

Usar Conventional Commits:

```
feat: nueva característica
fix: bug fix
docs: documentación
refactor: refactorización
test: tests
chore: mantenimiento
```

## Licencia

MIT
