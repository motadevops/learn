# Imagen única del laboratorio 1.1.
# Se usa Debian porque es el sistema que ya conoces. Todos los servicios usan
# esta misma imagen; lo que cambia es el comando con el que arrancan.
FROM debian:bookworm-slim

LABEL academia.lab="1.1" \
      academia.descripcion="Imagen comun del laboratorio 1.1: Debian con herramientas de diagnostico de red."

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3 \
      curl \
      iproute2 \
      iputils-ping \
      tcpdump \
      dnsutils \
      netcat-openbsd \
      iptables \
      procps \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Contenido mínimo que sirven los servidores web del laboratorio.
RUN mkdir -p /srv \
 && echo "<h1>Laboratorio 1.1</h1><p>Si ves esto, llegaste hasta la aplicacion.</p>" > /srv/index.html

COPY entrypoint-fw.sh /usr/local/bin/entrypoint-fw.sh
RUN chmod +x /usr/local/bin/entrypoint-fw.sh

WORKDIR /srv
