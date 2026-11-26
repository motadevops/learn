# 2. La dirección IP

- **Fecha:** 2026-11-26
- **La idea en una línea:** cada máquina tiene un número, su dirección IP, para que los mensajes la encuentren.

## Situación real

En una empresa con cientos de servidores, cuando alguien dice "la base de datos no responde", lo primero que se pregunta es en qué dirección está. Sin dirección no hay forma de llegar.

## Palabras nuevas

| Palabra | Qué es | Se parece a | En el laboratorio |
|---|---|---|---|
| Dirección IP | El número que identifica a una máquina dentro de una red | La dirección de una casa | `172.21.0.10` es la web sana |
| Interfaz de red | La puerta por la que una máquina se conecta a una red; cada una tiene su IP | La puerta que da a la calle | `eth0` |
| Loopback (`lo`) | Puerta que no sale a la red: lleva de la máquina a sí misma. IP `127.0.0.1`, también llamada localhost | Hablar contigo mismo frente al espejo | Todas las máquinas la tienen |

## Dibujo

```
 [cliente]      [web sano]     [api]          [web bloqueado]
 172.21.0.5     172.21.0.10    172.21.0.20    172.21.0.30
    | eth0         | eth0         | eth0         | eth0
 ========================= lab11-red ==========================

 Y en cada máquina: lo = 127.0.0.1 (no sale a la red, es "yo mismo")
```

## Ejemplo resuelto

```
docker compose exec web ip -4 -br addr
```

- `docker compose exec web`: ejecuta un comando dentro de la máquina `web`.
- `ip`: herramienta de Linux para ver la configuración de red.
- `-4`: solo direcciones IP versión 4.
- `-br`: formato breve, una línea por interfaz.
- `addr`: pide las direcciones.

Salida (ejemplo):

```
lo               UNKNOWN        127.0.0.1/8
eth0@if23        UP             172.21.0.10/24
```

Columnas: nombre de la interfaz, estado (`UP` = abierta) y dirección IP. El `/8` y `/24` (tamaño de la red) se ven en otra micro-lección.

## Mi predicción

Pregunta: ¿qué dirección saldrá en la línea `lo` del cliente?
Mi predicción: `127.0.0.1`, igual que en la web. **Acerté.**

```
$ docker compose exec client ip -4 -br addr
lo               UNKNOWN        127.0.0.1/8
eth0@if54        UP             172.21.0.5/24
```

| Máquina | `lo` | `eth0` |
|---|---|---|
| Web sana | 127.0.0.1 | 172.21.0.10 |
| Cliente | 127.0.0.1 | 172.21.0.5 |

`127.0.0.1` se repite en todas las máquinas, así que no identifica a ninguna. La dirección que distingue a cada máquina en la red es la de `eth0`.

## Caso que resolví solo

Averiguar la IP de `lab11-web-bloqueado`. Usé `docker exec` con el nombre de contenedor (también vale `docker compose exec fw`):

```
$ docker exec lab11-web-bloqueado ip -4 -br addr
eth0@if52        UP             172.21.0.30/24
```

Si desde el cliente se mandara un mensaje a `127.0.0.1`, le llegaría al propio cliente.

## Resumen en una frase

La dirección IP es la dirección que identifica a un nodo en la red. Se diferencia de `127.0.0.1`, que es la IP local de la misma máquina, conocida como localhost.

## Lo que me costó

- Escribí `exex` en lugar de `exec`. La terminal es literal: hay que revisar cada letra.
- Al copiar la salida me salté la línea `lo`. Hay que pegar la salida completa.
