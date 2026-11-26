# Laboratorios

Entornos de práctica con Docker Compose. Cada uno tiene su `compose.yaml`, un README con la ficha de cada contenedor, un `info.sh` que muestra quién es quién y un `verify.sh` que comprueba el estado. Todos siguen las [convenciones de nombres y etiquetas](../docs/convenciones-laboratorios.md).

| Laboratorio | Se usa en | Qué simula |
|---|---|---|
| [lab-1-1](lab-1-1/) | Módulo 1 | Red `lab11-red` con cuatro contenedores: `lab11-cliente-pruebas`, `lab11-web-sano`, `lab11-api-solo-local` y `lab11-web-bloqueado` |
