# Reglas de seguridad para publicar

Este repositorio es público. Todo lo que se sube queda visible y puede haber sido copiado antes de que se corrija. Por eso se previene, no se repara.

## Nunca entra al repositorio

- Contraseñas, claves de API, tokens, archivos `.env` y claves privadas (`.pem`, `id_rsa`, `id_ed25519`).
- `~/.docker/config.json`, `.git-credentials` y credenciales de nubes (`~/.aws`).
- Más adelante: `terraform.tfstate`, `*.tfvars`, kubeconfig y secretos de pipelines.
- Capturas de red (`.pcap`) y registros (`.log`) sin revisar.
- Cualquier dato de otros proyectos personales o de terceros.

Estos patrones están bloqueados en `.gitignore` desde el inicio.

## Se limpia en cada evidencia

- Nombre de usuario del sistema y nombre del equipo.
- Rutas personales, como `/home/<usuario>` o `/mnt/c/Users/<usuario>`.
- IP públicas y direcciones MAC de mi red real. Las de los laboratorios (redes de Docker, ejemplos) no son un problema.
- Nombres de contenedores, carpetas o proyectos que no pertenezcan a este repositorio.

## Identidad en los commits

Cada commit guarda para siempre el nombre y el correo configurados. En este repositorio se usa el correo `noreply` de GitHub, y en GitHub se activa "Block command line pushes that expose my email". La configuración es local al repositorio (`git config` sin `--global`), para no alterar otros proyectos.

## Antes de cada publicación

1. Ejecutar `./scripts/revisar-antes-de-publicar.sh`. Si bloquea, se corrige antes de seguir.
2. Revisar los avisos del script uno por uno.
3. Ejecutar `git status` y `git diff --staged` y leer los cambios completos.
4. Hacer un commit por micro-lección. Desde el Módulo 3 (Git), cada micro-lección irá en una rama con su pull request.

## Si se sube un secreto por error

1. Revocar o rotar la credencial de inmediato. Es lo primero y lo más importante.
2. Después limpiar el historial. Borrar el archivo en un commit nuevo no basta.
3. Documentar el incidente como aprendizaje.

## Configuración en GitHub

- Verificación en dos pasos en la cuenta.
- Secret scanning y push protection activados en el repositorio.
- Autenticación por clave SSH (con frase de paso) o `gh auth login`. Nunca tokens en archivos del repositorio ni en el historial del terminal.
