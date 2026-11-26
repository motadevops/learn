# 1. Qué es una red

- **Fecha:** 2026-11-26
- **La idea en una línea:** una red son máquinas conectadas que se mandan mensajes.

## Situación real

En una empresa, la web, la base de datos y el servidor de pagos están en máquinas distintas. Para que alguien pueda comprar, esas máquinas tienen que hablarse. Cuando algo "no conecta", el problema suele estar en esa conversación.

## Palabras nuevas

| Palabra | Qué es | Se parece a | En el laboratorio |
|---|---|---|---|
| Máquina | Un computador que ejecuta programas | Una casa | Cada uno de los cuatro contenedores |
| Contenedor | Una máquina pequeña y aislada que Docker crea dentro de mi computador | Un apartamento con su propia puerta dentro de una casa | `lab11-web-sano` |
| Red | El camino que conecta máquinas para que se manden mensajes | Las calles de un barrio | `lab11-red` |
| Nodo | Cada máquina conectada a una red | Cada casa de la calle | Los cuatro contenedores |
| Etiqueta | Una nota `nombre=valor` pegada a un contenedor | La etiqueta de una caja en una mudanza | `academia.lab=1.1` |

## Dibujo

```
 [cliente]   [web sano]   [api]   [web bloqueado]
     |            |          |            |
 ====================== lab11-red =====================
     └──── un mensaje ────►┘
```

## Ejemplo resuelto

Ver qué máquinas hay y a qué red están conectadas:

```
docker ps --filter "label=academia.lab=1.1" --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"
```

- `docker ps`: lista los contenedores encendidos.
- `--filter "label=academia.lab=1.1"`: solo los que tienen la etiqueta de este laboratorio. La etiqueta está escrita en `compose.yaml`, en la sección `labels`.
- `--format "table ..."`: elige las columnas nombre, estado y red.

Columnas: `NAMES` es el nombre, `STATUS` dice si está encendida (`Up`) o apagada (`Exited`), y `NETWORKS` la red.

### Cada contenedor tiene dos nombres

| Nombre de servicio | Nombre de contenedor | Lo usa |
|---|---|---|
| `web` | `lab11-web-sano` | `docker compose stop web` / `docker stop lab11-web-sano` |
| `fw` | `lab11-web-bloqueado` | `docker compose stop fw` / `docker stop lab11-web-bloqueado` |

`docker compose` lee el `compose.yaml` y usa el nombre de servicio. `docker` usa el nombre de contenedor.

## Mi predicción

Pregunta: si apago `web` y ejecuto `docker ps`, ¿cuántas filas salen?
Mi predicción: 3, porque `docker ps` solo muestra las encendidas. **Acerté.**

```
$ docker compose stop web
$ docker ps --filter "label=academia.lab=1.1" --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"
NAMES                    STATUS             NETWORKS
lab11-web-bloqueado      Up About an hour   lab11-red
lab11-cliente-pruebas    Up About an hour   lab11-red
lab11-api-solo-local     Up About an hour   lab11-red

$ docker ps -a --filter "label=academia.lab=1.1" --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"
NAMES                    STATUS                        NETWORKS
lab11-web-bloqueado      Up About an hour              lab11-red
lab11-cliente-pruebas    Up About an hour              lab11-red
lab11-api-solo-local     Up About an hour              lab11-red
lab11-web-sano           Exited (137) 36 minutes ago   lab11-red

$ docker compose start web
 ✔ Container lab11-web-sano Started
```

Con `-a` aparece también la apagada. Sigue en `lab11-red`: conserva su sitio en la red aunque esté apagada.

## Caso que resolví solo

Apagar y encender la API con `docker` (sin Compose), usando el nombre de contenedor:

```
$ docker stop lab11-api-solo-local
lab11-api-solo-local

$ docker ps -a
... Exited (137) 18 seconds ago   lab11-api-solo-local

$ docker start lab11-api-solo-local
lab11-api-solo-local

$ docker ps
... Up 59 seconds                 lab11-api-solo-local
```

Mientras la API estaba apagada quedaban 3 máquinas encendidas en `lab11-red`.

## Resumen en una frase

Una red es el medio por el que diferentes dispositivos (nodos) se comunican y se envían información. Para que un mensaje llegue, cada uno necesita una ubicación.

## Lo que me costó

- No sabía de dónde salía `--filter "label=academia.lab=1.1"`. Lo entendí al ver la sección `labels` del `compose.yaml`.
- No entendía por qué se escribe `web` y no `lab11-web-sano`. Cada contenedor tiene nombre de servicio y nombre de contenedor.
- En mi primera frase dije que la red permite saber el estado de las máquinas. Eso lo muestra Docker, no la red.
