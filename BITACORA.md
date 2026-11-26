# Bitácora

Diario de sesiones, de la más antigua a la más reciente. Aquí también quedan las dudas y los tropiezos, porque son parte del aprendizaje.

## 2026-11-25: diagnóstico y primer intento

- Hice un diagnóstico inicial. En redes y en Linux por dentro respondí "no sé" a todo.
- Vi teoría de capas de red, TCP y UDP, rutas y ARP, con explicaciones y simulaciones.
- Preparé el entorno: GitHub con una cuenta de estudio separada y su propia clave SSH, y un laboratorio con Docker.
- Al levantar el laboratorio, su red chocaba con la de otro proyecto mío. La cambié a 172.21.0.0/24.
- Ejecuté el laboratorio y arreglé un servicio que solo escuchaba en 127.0.0.1.
- Me confundí mucho: se mezclaban demasiadas ideas a la vez y me pedían diagnosticar sin haber visto antes un caso resuelto.

## 2026-11-26: cambio de metodología y repositorio nuevo

- Decidí empezar de nuevo con otra forma de estudiar. Los motivos están en [docs/decisiones/0001-metodologia-v2.md](docs/decisiones/0001-metodologia-v2.md).
- Rehíce este repositorio desde cero para que el historial siga el orden real de aprendizaje.
- Pedí que los laboratorios se expliquen solos. Ahora cada contenedor tiene un nombre descriptivo (`lab11-<rol>-<qué-pasa>`), etiquetas con su descripción, una ficha en el README y un script `info.sh` que muestra rol, IP, puerto, red y volúmenes.

## 2026-11-26: micro-lección 1, qué es una red

- Primera micro-lección con el método nuevo: ejemplo resuelto, predicción, práctica con huecos y caso solo.
- Aprendí a listar los contenedores de un laboratorio con un filtro por etiqueta, y la diferencia entre `docker ps` y `docker ps -a`.
- Entendí que cada contenedor tiene nombre de servicio (`web`) y nombre de contenedor (`lab11-web-sano`).
- Acerté la predicción y resolví solo el caso de apagar y encender la API.

## 2026-11-26: micro-lección 2, la dirección IP

- Repaso de la micro-lección 1: tres de tres.
- Aprendí a ver las direcciones de una máquina con `ip -4 -br addr` y a distinguir `eth0` (la puerta a la red) de `lo` (127.0.0.1, la propia máquina).
- Acerté la predicción: `127.0.0.1` existe igual en todas las máquinas, por eso no sirve para identificar a ninguna.
- En el caso solo usé `docker exec` con el nombre de contenedor sin que me lo pidieran.
- Siguiente paso: micro-lección 3, "El puerto".
