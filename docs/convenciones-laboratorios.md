# Convenciones de los laboratorios

Reglas que siguen todos los laboratorios de este repositorio, para que cualquier entorno se entienda con solo mirar `docker ps`.

## Nombres

| Pieza | Patrón | Ejemplo |
|---|---|---|
| Proyecto de Compose | `lab<NN>` | `lab11` |
| Contenedor | `lab<NN>-<rol>-<qué-pasa>` | `lab11-api-solo-local` |
| Red | `lab<NN>-red` (o `lab<NN>-red-<uso>` si hay varias) | `lab11-red` |
| Imagen propia | `lab<NN>-<contenido>:<versión>` | `lab11-herramientas:1` |
| Volumen | `lab<NN>-<qué-guarda>` | `lab21-datos-postgres` |

- `<NN>` es el número del laboratorio sin punto: el 1.1 es `11`.
- `<rol>` dice para qué sirve: cliente, web, api, base-datos, proxy.
- `<qué-pasa>` dice cómo se comporta: sano, solo-local, bloqueado, lento.
- Todo en minúsculas, sin tildes y con guiones.
- En los incidentes con falla escondida, `<qué-pasa>` es neutro (por ejemplo `servicio`), para no delatar la falla.

## Nombre de servicio y nombre de contenedor

- **Servicio:** corto (`client`, `api`). Es el que se escribe en `docker compose exec` y el nombre DNS dentro de la red.
- **Contenedor (`container_name`):** largo y descriptivo. Es el que aparece en `docker ps`, `docker logs` y `docker inspect`.
- El `hostname` es igual al nombre del contenedor, para que el prompt de la terminal dentro del contenedor diga dónde estás.

## Etiquetas

Cada contenedor, red e imagen lleva etiquetas `academia.*`. Viajan dentro de Docker, así que se pueden consultar y filtrar sin abrir el `compose.yaml`.

| Etiqueta | Qué guarda |
|---|---|
| `academia.lab` | Número del laboratorio, por ejemplo `1.1` |
| `academia.rol` | Para qué sirve |
| `academia.descripcion` | Qué hace, en una frase |
| `academia.puerto` | Puerto que ofrece, o `ninguno` |
| `academia.estado-esperado` | `sano` o `falla a proposito` |

## Cómo inspeccionar un laboratorio

```bash
# Solo los contenedores de un laboratorio
docker ps --filter "label=academia.lab=1.1"

# Con columnas elegidas
docker ps --filter "label=academia.lab=1.1" --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"

# Tabla completa: rol, IP, puerto, red y volúmenes
bash info.sh

# Toda la configuración de un contenedor
docker inspect lab11-api-solo-local

# Una sola etiqueta
docker inspect --format '{{index .Config.Labels "academia.descripcion"}}' lab11-api-solo-local

# La red
docker network inspect lab11-red
```

## Qué trae cada laboratorio

- `compose.yaml` con un comentario al principio que resume cada contenedor.
- `README.md` con una ficha por contenedor, la red, los volúmenes y la imagen.
- `info.sh`: inventario en tabla. Solo lee.
- `verify.sh`: comprobación automática.
- `guia-laboratorio.html`: guía paso a paso.

## Por qué `container_name`

Fijar el nombre impide tener dos copias del mismo servicio a la vez (escalar). En un laboratorio no hace falta escalar, y a cambio los nombres son legibles. En producción se suele dejar el nombre automático de Compose.
