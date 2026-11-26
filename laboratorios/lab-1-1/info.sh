#!/usr/bin/env bash
# Muestra en una tabla todo lo que hay en el laboratorio 1.1:
# contenedores, para que sirve cada uno, su IP, su puerto, su red y sus volumenes.
# Solo lee informacion de Docker. No cambia nada.
#
#   bash info.sh

set -u

LAB="1.1"

echo "== Laboratorio $LAB: contenedores =="
echo

fmt="%-24s %-12s %-14s %-9s %-10s %-9s %s\n"
printf "$fmt" "CONTENEDOR" "ESTADO" "IP" "PUERTO" "RED" "VOLUMENES" "ROL"
printf "$fmt" "----------" "------" "--" "------" "---" "---------" "---"

ids=$(docker ps -a -q --filter "label=academia.lab=$LAB")
if [ -z "$ids" ]; then
  echo "(no hay contenedores; levanta el laboratorio con: docker compose up -d --build)"
else
  for id in $ids; do
    docker inspect --format \
'{{.Name}}|{{.State.Status}}|{{range $red, $cfg := .NetworkSettings.Networks}}{{$cfg.IPAddress}}|{{$red}}{{end}}|{{index .Config.Labels "academia.puerto"}}|{{len .Mounts}}|{{index .Config.Labels "academia.rol"}}' "$id" |
    while IFS='|' read -r nombre estado ip red puerto vol rol; do
      [ "$vol" = "0" ] && vol="ninguno"
      printf "$fmt" "${nombre#/}" "$estado" "$ip" "$puerto" "$red" "$vol" "$rol"
    done
  done | sort
fi

echo
echo "== Que hace cada contenedor =="
echo
for id in $ids; do
  docker inspect --format \
'{{.Name}}|{{index .Config.Labels "academia.estado-esperado"}}|{{index .Config.Labels "academia.descripcion"}}' "$id" |
  while IFS='|' read -r nombre esperado desc; do
    echo "${nombre#/} ($esperado)"
    echo "    $desc"
  done
done

echo
echo "== Red =="
echo
docker network inspect lab11-red --format \
'Nombre: {{.Name}}
Tipo:   {{.Driver}}
Subred: {{range .IPAM.Config}}{{.Subnet}}{{end}}
Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}
Que es: {{index .Labels "academia.descripcion"}}' 2>/dev/null \
  || echo "(la red lab11-red no existe todavia)"
