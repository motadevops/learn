#!/usr/bin/env bash
# Verificacion automatica del laboratorio 1.1.
# Ejecutalo desde la carpeta del laboratorio, con el entorno levantado:
#
#   bash verify.sh            estado inicial (la api falla a proposito)
#   bash verify.sh --fixed    despues de arreglar la api
#
# Cada prueba lanza un comando desde el contenedor "client" y comprueba que el
# resultado contenga lo esperado.
#
# Para distinguir "refused", "timed out" y "no route" se usa nc (netcat), porque
# imprime el mensaje exacto del sistema operativo. El texto de errores de curl
# cambia segun su version, asi que curl solo se usa donde su salida es estable
# (codigos HTTP y resolucion de nombres).

set -u

MODE="${1:-initial}"
OK=0
FAIL=0

check() {
  # check "nombre" "patron esperado" comando...
  local name="$1" pattern="$2"
  shift 2
  local out
  out="$("$@" 2>&1 || true)"
  if printf '%s' "$out" | grep -Eqi -- "$pattern"; then
    echo "[OK]    $name"
    OK=$((OK + 1))
  else
    echo "[FALLO] $name"
    echo "        esperado (patron): $pattern"
    echo "        obtenido: $(printf '%s' "$out" | head -n 3 | tr '\n' ' ')"
    FAIL=$((FAIL + 1))
  fi
}

cl() { docker compose exec -T client "$@"; }

echo "== Modo: $MODE =="
echo

check "Escalon 1 ok: el nombre 'web' se resuelve y la web responde 200" \
  '^200$' \
  cl curl -sS -m 5 -o /dev/null -w '%{http_code}' http://web/

check "Escalon 1 falla: un nombre inexistente no se resuelve" \
  'Could not resolve host' \
  cl curl -sS -m 5 http://inexistente.lab/

check "Escalon 2 falla: la IP 172.21.0.99 no tiene camino (nadie responde al ARP)" \
  'No route to host|Host is unreachable' \
  cl nc -vz -w 10 172.21.0.99 80

check "Escalon 4 falla en silencio: fw descarta paquetes (timeout)" \
  'timed out' \
  cl nc -vz -w 4 172.21.0.30 9090

if [ "$MODE" = "--fixed" ]; then
  check "Escalon 4 ok: la api acepta conexiones en el puerto 8080" \
    'succeeded' \
    cl nc -vz -w 4 172.21.0.20 8080
  check "Escalon 5 ok: la api responde 200" \
    '^200$' \
    cl curl -sS -m 5 -o /dev/null -w '%{http_code}' http://172.21.0.20:8080/
  check "La api ya escucha en todas las interfaces (0.0.0.0:8080)" \
    '0\.0\.0\.0:8080|\*:8080' \
    docker compose exec -T api ss -ltn
else
  check "Escalon 4 falla con rechazo: la api responde 'refused'" \
    'refused' \
    cl nc -vz -w 4 172.21.0.20 8080
  check "La api escucha solo en 127.0.0.1:8080" \
    '127\.0\.0\.1:8080' \
    docker compose exec -T api ss -ltn
fi

check "Escalon 5: la aplicacion contesta 404 a una ruta que no existe" \
  '^404$' \
  cl curl -sS -m 5 -o /dev/null -w '%{http_code}' http://web/noexiste

echo
echo "Resultado: $OK correctas, $FAIL con fallo."
[ "$FAIL" -eq 0 ]
