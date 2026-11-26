# Laboratorio 1.1: el servicio que no responde

Una red Docker con cuatro máquinas. Algunas fallan a propósito, cada una de una forma distinta, para practicar cómo leer un error de conexión.

La guía paso a paso está en [guia-laboratorio.html](guia-laboratorio.html). Ábrela en el navegador. La redactó el tutor de IA.

## Vista general

```
                    red lab11-red (172.21.0.0/24)
   ┌─────────────────────────────────────────────────────────────┐
   │                                                             │
   │  lab11-cliente-pruebas  ──prueba──►  lab11-web-sano         │
   │  172.21.0.5                          172.21.0.10 :80   OK   │
   │                         ──prueba──►  lab11-api-solo-local   │
   │                                      172.21.0.20 :8080 FALLA│
   │                         ──prueba──►  lab11-web-bloqueado    │
   │                                      172.21.0.30 :9090 FALLA│
   │                         ──prueba──►  172.21.0.99  (nadie)   │
   │                                                             │
   │  gateway 172.21.0.1 (lo crea Docker)                        │
   └─────────────────────────────────────────────────────────────┘
```

## Cómo se leen los nombres

Todos los contenedores siguen el patrón `lab11-<rol>-<qué-pasa>`. Con solo ver `docker ps` sabes de qué laboratorio es, para qué sirve y cómo se comporta. Las reglas completas están en [docs/convenciones-laboratorios.md](../../docs/convenciones-laboratorios.md).

Cada contenedor tiene dos nombres:

| Nombre | Ejemplo | Dónde se usa |
|---|---|---|
| De servicio (corto) | `api` | `docker compose exec api ...` y como nombre DNS dentro de la red |
| De contenedor (largo) | `lab11-api-solo-local` | `docker ps`, `docker logs`, `docker inspect` |

## Ficha de cada contenedor

### lab11-cliente-pruebas

| | |
|---|---|
| Servicio | `client` |
| Para qué sirve | Es tu puesto de trabajo. Desde aquí haces todas las pruebas. |
| IP y puerto | 172.21.0.5, no ofrece ningún puerto |
| Comando | `sleep infinity`: solo se mantiene encendido |
| Estado esperado | Sano |
| Entrar | `docker compose exec client bash` |

### lab11-web-sano

| | |
|---|---|
| Servicio | `web` |
| Para qué sirve | Servidor web que funciona. Es la referencia de "todo bien". |
| IP y puerto | 172.21.0.10, puerto 80/tcp |
| Comando | Servidor web de Python escuchando en `0.0.0.0` (todas sus direcciones) |
| Estado esperado | Sano |
| Qué verás | `curl http://web/` devuelve la página |

### lab11-api-solo-local

| | |
|---|---|
| Servicio | `api` |
| Para qué sirve | Simula una API mal configurada. |
| IP y puerto | 172.21.0.20, puerto 8080/tcp |
| Comando | Servidor web de Python escuchando solo en `127.0.0.1` |
| Estado esperado | Falla a propósito |
| Qué verás | Desde el cliente: `Connection refused` |
| Por qué | `127.0.0.1` significa "yo mismo". Solo atiende llamadas de dentro de su propio contenedor. |

### lab11-web-bloqueado

| | |
|---|---|
| Servicio | `fw` |
| Para qué sirve | Simula un servidor detrás de un firewall que bloquea su puerto. |
| IP y puerto | 172.21.0.30, puerto 9090/tcp |
| Comando | `entrypoint-fw.sh`: crea una regla que descarta lo que llega al 9090 y luego arranca el servidor |
| Permiso extra | `NET_ADMIN`, solo para poder crear su propia regla de firewall |
| Estado esperado | Falla a propósito |
| Qué verás | Desde el cliente: `timed out` |
| Por qué | El firewall tira los paquetes sin contestar. Nadie responde, ni siquiera con un "no". |

### 172.21.0.99 (sin contenedor)

No existe ninguna máquina con esta dirección. Al intentar llegar verás `No route to host`.

## Red

| | |
|---|---|
| Nombre | `lab11-red` |
| Tipo | `bridge`: red privada dentro de tu máquina |
| Subred | 172.21.0.0/24 (de 172.21.0.1 a 172.21.0.254) |
| Gateway | 172.21.0.1 |
| Aislada de | Cualquier otra red Docker tuya |

## Volúmenes

Ninguno. Ningún contenedor guarda datos, así que se pueden borrar y volver a crear sin perder nada.

## Imagen

Una sola imagen para los cuatro: `lab11-herramientas:1`. Es Debian con las herramientas de diagnóstico (`curl`, `nc`, `ip`, `ss`, `dig`, `tcpdump`, `iptables`). Lo que cambia entre contenedores es el comando con el que arrancan.

## Archivos

| Archivo | Qué hace |
|---|---|
| `Dockerfile` | Construye la imagen común |
| `compose.yaml` | Define la red, los nombres, las etiquetas y los cuatro contenedores |
| `entrypoint-fw.sh` | Pone la regla de firewall de `lab11-web-bloqueado` y arranca su servidor |
| `info.sh` | Muestra en una tabla contenedores, rol, IP, puerto, red y volúmenes. Solo lee. |
| `verify.sh` | Comprueba que cada falla se comporta como se espera |

## Uso

Desde esta carpeta:

```bash
docker compose up -d --build     # construye la imagen y arranca los cuatro contenedores
bash info.sh                     # muestra quién es quién
bash verify.sh                   # comprueba el estado: deben salir 7 correctas
```

Para ver solo los contenedores de este laboratorio, en cualquier carpeta:

```bash
docker ps --filter "label=academia.lab=1.1" --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}"
```

Si la subred choca con otra red de tu máquina, cámbiala en `compose.yaml` y en `verify.sh`.

## Limpieza

```bash
docker compose down --rmi local --remove-orphans
```

Borra solo los cuatro contenedores, la red `lab11-red` y la imagen `lab11-herramientas:1`. No toca nada de otros proyectos.
