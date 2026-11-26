#!/usr/bin/env bash
# Revision de seguridad antes de publicar en el repositorio.
#
# Uso, desde cualquier carpeta del repositorio:
#   ./scripts/revisar-antes-de-publicar.sh
#
# Sale con codigo 1 si encuentra algo BLOQUEANTE (secretos, archivos prohibidos,
# datos personales, correo real en los commits). Los AVISOS exigen revision manual.
#
# Datos personales propios: crea el archivo ~/.config/learn-review/palabras.txt
# FUERA del repositorio, con una palabra por linea (tu usuario del sistema, el
# nombre de tu equipo, nombres de tus otros proyectos). Cualquier coincidencia
# bloquea la publicacion. Ese archivo nunca debe estar dentro del repositorio.
#
# Este script es una ayuda, no una garantia. La revision de "git diff --staged"
# linea por linea sigue siendo obligatoria.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

SELF="scripts/revisar-antes-de-publicar.sh"
WORDS_FILE="${LEARN_REVIEW_WORDS:-$HOME/.config/learn-review/palabras.txt}"

BLOCK=0
WARN=0

block() { echo "[BLOQUEO] $*"; BLOCK=$((BLOCK + 1)); }
warn()  { echo "[AVISO]   $*"; WARN=$((WARN + 1)); }

# ------------------------------------------------------------ lista de archivos
FILES=()
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  IN_GIT=1
  while IFS= read -r -d '' f; do FILES+=("$f"); done \
    < <(git ls-files -z --cached --others --exclude-standard)
else
  IN_GIT=0
  while IFS= read -r -d '' f; do FILES+=("${f#./}"); done \
    < <(find . -type f -not -path './.git/*' -print0)
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No hay archivos que revisar."
  exit 0
fi

CONTENT=()
for f in "${FILES[@]}"; do
  [ "$f" = "$SELF" ] && continue
  [ -f "$f" ] && CONTENT+=("$f")
done

echo "Revisando ${#FILES[@]} archivos en $ROOT"
echo

# ------------------------------------------------- 1. nombres de archivo prohibidos
for f in "${FILES[@]}"; do
  case "$f" in
    .env|.env.*|*/.env|*/.env.*) block "Archivo de entorno: $f" ;;
    *.pem|*.key|*.p12|*.pfx|*.kdbx) block "Archivo de claves o credenciales: $f" ;;
    id_rsa|id_ed25519|id_ecdsa|id_dsa|*/id_rsa|*/id_ed25519|*/id_ecdsa|*/id_dsa) block "Clave privada SSH: $f" ;;
    .git-credentials|*/.git-credentials|.netrc|*/.netrc) block "Credenciales de Git: $f" ;;
    *.tfstate|*.tfstate.*|*.tfvars|*.tfvars.json) block "Estado o variables de Terraform: $f" ;;
    *kubeconfig*) block "Configuracion de Kubernetes: $f" ;;
    .docker/config.json|*/.docker/config.json|.aws/*|*/.aws/*) block "Credenciales de Docker o AWS: $f" ;;
    *.pcap|*.pcapng) warn "Captura de red (puede contener datos personales): $f" ;;
    *.log) warn "Archivo de registro (revisar su contenido): $f" ;;
  esac
done

# ------------------------------------------------------------ 2. secretos en contenido
scan() {
  # scan NIVEL "descripcion" regex [-i]
  local level="$1" desc="$2" regex="$3" flag="${4:-}"
  local out
  if [ "${#CONTENT[@]}" -eq 0 ]; then return; fi
  out="$(printf '%s\0' "${CONTENT[@]}" | xargs -0 grep -HnIE $flag -e "$regex" -- 2>/dev/null | head -n 20)"
  if [ -n "$out" ]; then
    if [ "$level" = "block" ]; then block "$desc"; else warn "$desc"; fi
    printf '%s\n' "$out" | sed 's/^/            /' | cut -c1-200
  fi
}

scan block "Clave privada en el contenido" '-----BEGIN [A-Z ]*PRIVATE KEY-----'
scan block "Clave de acceso de AWS" '(AKIA|ASIA)[0-9A-Z]{16}'
scan block "Token de GitHub" '(gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,})'
scan block "Token de Slack" 'xox[baprs]-[A-Za-z0-9-]{10,}'
scan block "Clave de API de Google" 'AIza[0-9A-Za-z_-]{35}'
scan block "Clave de Stripe" '(sk|rk)_live_[0-9A-Za-z]{16,}'
scan block "Token JWT" 'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
scan block "Token de bot de Telegram" '[0-9]{8,10}:[A-Za-z0-9_-]{35}'
scan block "Cadena de conexion con usuario y contrasena" '(postgres(ql)?|mysql|mongodb(\+srv)?|redis|amqp)://[^ :/@"]+:[^ @"]+@'
scan warn  "Posible asignacion de secreto (revisar que no sea un valor real)" \
  "(password|passwd|pwd|secret|token|api[_-]?key|apikey|access[_-]?key|private[_-]?key)[\"']?[[:space:]]*[:=][[:space:]]*[\"']?[A-Za-z0-9/+_.@!#\$%^&*-]{8,}" -i

# ------------------------------------------------------------ 3. datos personales
# Rutas personales. Se ignoran los marcadores de ejemplo.
personal_paths() {
  [ "${#CONTENT[@]}" -eq 0 ] && return
  local out
  out="$(printf '%s\0' "${CONTENT[@]}" | xargs -0 grep -HnIE -e '/mnt/[a-z]/Users/[A-Za-z0-9._ -]+|/home/[a-z_][a-z0-9_-]+|/Users/[A-Za-z0-9._-]+|[A-Za-z]:\\Users\\[A-Za-z0-9._-]+' -- 2>/dev/null \
    | grep -vE 'TU_USUARIO|<usuario>|<user>|\$USER|/home/claude' | head -n 20)"
  if [ -n "$out" ]; then
    block "Ruta personal (usuario del sistema)"
    printf '%s\n' "$out" | sed 's/^/            /' | cut -c1-200
  fi
}
personal_paths

# Palabras propias del estudiante (archivo fuera del repositorio)
if [ -f "$WORDS_FILE" ]; then
  while IFS= read -r word || [ -n "$word" ]; do
    [ -z "$word" ] && continue
    case "$word" in \#*) continue ;; esac
    out="$(printf '%s\0' "${CONTENT[@]}" | xargs -0 grep -HnIiF -e "$word" -- 2>/dev/null | head -n 5)"
    if [ -n "$out" ]; then
      block "Contiene una palabra de tu lista personal ('$word')"
      printf '%s\n' "$out" | sed 's/^/            /' | cut -c1-200
    fi
  done < "$WORDS_FILE"
else
  warn "No existe $WORDS_FILE. Crealo (fuera del repositorio) con tu usuario, el nombre de tu equipo y los nombres de tus otros proyectos."
fi

# Correos (se aceptan el noreply de GitHub, los de ejemplo y la URL SSH de GitHub)
mails="$(printf '%s\0' "${CONTENT[@]}" | xargs -0 grep -HnIoiE -e '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' -- 2>/dev/null \
  | grep -viE '@users\.noreply\.github\.com|@example\.(com|org|net)|:git@github\.com$' | head -n 20)"
if [ -n "$mails" ]; then
  warn "Direcciones de correo (revisar que no sean personales)"
  printf '%s\n' "$mails" | sed 's/^/            /'
fi

# IP publicas
ips="$(printf '%s\0' "${CONTENT[@]}" | xargs -0 grep -HnIoE -e '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' -- 2>/dev/null \
  | grep -vE ':(0\.|10\.|127\.|169\.254\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|192\.0\.2\.|198\.51\.100\.|203\.0\.113\.|22[4-9]\.|23[0-9]\.|24[0-9]\.|25[0-5]\.)[0-9.]*$' \
  | grep -vE ':(8\.8\.8\.8|8\.8\.4\.4|1\.1\.1\.1|1\.0\.0\.1|9\.9\.9\.9)$' | head -n 20)"
if [ -n "$ips" ]; then
  warn "Direcciones IP que podrian ser publicas (revisar)"
  printf '%s\n' "$ips" | sed 's/^/            /'
fi

# MAC reales
macs="$(printf '%s\0' "${CONTENT[@]}" | xargs -0 grep -HnIoiE -e '\b([0-9a-f]{2}:){5}[0-9a-f]{2}\b' -- 2>/dev/null \
  | grep -viE ':(aa:aa:aa|bb:bb:bb|cc:cc:cc|ff:ff:ff|00:00:00|02:42:)' | head -n 20)"
if [ -n "$macs" ]; then
  warn "Direcciones MAC que no son de ejemplo ni de Docker (revisar)"
  printf '%s\n' "$macs" | sed 's/^/            /'
fi

# ------------------------------------------------------------ 4. tamano
for f in "${CONTENT[@]}"; do
  size=$(wc -c < "$f" 2>/dev/null || echo 0)
  if [ "$size" -gt 2000000 ]; then
    warn "Archivo grande (mas de 2 MB): $f"
  fi
done

# ------------------------------------------------------------ 5. identidad de Git
if [ "$IN_GIT" -eq 1 ]; then
  email="$(git config user.email 2>/dev/null || true)"
  name="$(git config user.name 2>/dev/null || true)"
  if [ -z "$email" ]; then
    warn "git config user.email no esta definido en este repositorio."
  else
    case "$email" in
      *@users.noreply.github.com) : ;;
      *) block "El correo de Git ($email) no es el noreply de GitHub. Cada commit lo guardaria para siempre." ;;
    esac
  fi
  [ -z "$name" ] && warn "git config user.name no esta definido en este repositorio."
fi

# ------------------------------------------------------------ resumen
echo
echo "Resultado: $BLOCK bloqueo(s), $WARN aviso(s)."
if [ "$BLOCK" -gt 0 ]; then
  echo "NO publiques todavia. Corrige los bloqueos y vuelve a ejecutar el script."
  exit 1
fi
if [ "$WARN" -gt 0 ]; then
  echo "Sin bloqueos. Revisa cada aviso a mano antes de publicar."
else
  echo "Sin bloqueos ni avisos. Aun asi, revisa 'git diff --staged' linea por linea."
fi
exit 0
