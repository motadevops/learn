# learn

Mi formación en DevOps, contada paso a paso. Aquí está lo que aprendo, los laboratorios que ejecuto en mi máquina y mi evidencia.

El historial de commits es parte del registro: cada micro-lección terminada es un commit, en el orden en que la aprendí.

## Cómo leer este repositorio

| Si quieres ver... | Abre |
|---|---|
| En qué voy y qué me falta | [PROGRESO.md](PROGRESO.md) |
| Qué pasó en cada sesión, incluidas las dudas | [BITACORA.md](BITACORA.md) |
| Cómo estudio | [docs/metodologia.md](docs/metodologia.md) |
| Por qué tomé ciertas decisiones | [docs/decisiones/](docs/decisiones/) |
| Los apuntes de cada micro-lección | `modulo-XX-tema/NN-nombre/` |
| Los entornos de práctica | [laboratorios/](laboratorios/) |
| Cómo se nombran contenedores, redes y volúmenes | [docs/convenciones-laboratorios.md](docs/convenciones-laboratorios.md) |
| Las reglas para no publicar datos sensibles | [docs/seguridad.md](docs/seguridad.md) |

## Cómo estudio, en corto

- Empiezo desde cero y aprendo una idea por micro-lección, de 20 a 30 minutos.
- Primero veo un ejemplo resuelto, luego predigo, luego practico con ayuda y al final resuelvo solo.
- Cada micro-lección se practica en un laboratorio real con Docker.
- Una micro-lección cuenta como terminada cuando resuelvo solo el caso final y escribo mi resumen.

Estudio con un tutor de inteligencia artificial (Claude, de Anthropic) que explica y prepara los laboratorios. Lo declaro abiertamente. Los comandos los ejecuto yo, y la evidencia son mis salidas reales y mis explicaciones.

## Entorno

WSL2 con Debian, Docker Engine con Docker Compose, Visual Studio Code y GitHub.

## Plan general

| Módulo | Tema | Estado |
|---|---|---|
| 1 | Redes | En curso |
| 2 | Linux por dentro | Pendiente |
| 3 | Git y control de versiones | Pendiente |
| 4 | Automatización con Python y Bash | Pendiente |
| 5 | Docker y contenedores a fondo | Pendiente |
| 6 | Integración y despliegue continuo (CI/CD) | Pendiente |
| 7 | Infraestructura como código | Pendiente |
| 8 | Kubernetes | Pendiente |
| 9 | Nube | Pendiente |
| 10 | Observabilidad y monitoreo | Pendiente |
| 11 | Seguridad (DevSecOps) | Pendiente |
| 12 | Confiabilidad (SRE) | Pendiente |

## Estructura

```
learn/
├── README.md              esta página
├── PROGRESO.md            estado de cada micro-lección
├── BITACORA.md            diario de sesiones
├── docs/
│   ├── metodologia.md
│   ├── convenciones-laboratorios.md
│   ├── plantilla-microleccion.md
│   ├── seguridad.md
│   └── decisiones/        por qué se tomó cada decisión importante
├── laboratorios/
│   └── lab-1-1/           entorno Docker del Módulo 1
├── modulo-01-redes/
│   └── 01-que-es-una-red/ se crea al terminar cada micro-lección
└── scripts/
    └── revisar-antes-de-publicar.sh
```
