#!/bin/sh
# Arranque del servicio "fw".
# Primero instala una regla de firewall que DESCARTA en silencio los paquetes TCP
# que llegan al puerto 9090, y despues arranca un servidor web en ese puerto.
# Resultado: el servicio esta vivo y escuchando, pero desde fuera nadie le llega.
# Es el origen de un "connection timed out".
set -e

PORT=9090

if iptables -A INPUT -p tcp --dport "$PORT" -j DROP 2>/dev/null; then
  echo "[fw] regla DROP instalada para el puerto $PORT (iptables)"
elif command -v iptables-legacy >/dev/null 2>&1 \
     && iptables-legacy -A INPUT -p tcp --dport "$PORT" -j DROP 2>/dev/null; then
  echo "[fw] regla DROP instalada para el puerto $PORT (iptables-legacy)"
else
  echo "[fw] ERROR: no se pudo instalar la regla de firewall." >&2
  echo "[fw] El kernel o los permisos del contenedor no lo permiten." >&2
  exit 1
fi

exec python3 -m http.server "$PORT" --bind 0.0.0.0 --directory /srv
