# Metodología

Versión 2, desde el 2026-11-26. El porqué del cambio está en [decisiones/0001-metodologia-v2.md](decisiones/0001-metodologia-v2.md).

## Punto de partida

Empiezo desde cero en todo. Nada se da por sabido, aunque lo haya usado antes en proyectos propios.

## La micro-lección

Cada micro-lección enseña una sola idea, dura de 20 a 30 minutos y sigue siempre el mismo orden.

**Para entender**

1. **Situación real.** Un problema del trabajo que esta idea resuelve.
2. **Palabras nuevas.** Como máximo tres. Cada una con su definición, una comparación con la vida diaria y un ejemplo del laboratorio.
3. **Dibujo.** Un diagrama o una simulación con pocos elementos.

**Para practicar**

4. **Yo hago.** El tutor muestra un caso completo resuelto: el comando, la salida y qué significa cada línea.
5. **Tú predices.** Antes de ejecutar un caso parecido, elijo entre opciones qué va a salir. Luego lo ejecuto y comparo.
6. **Hacemos.** El mismo tipo de caso, con huecos que completo yo.
7. **Tú haces.** Un caso nuevo, sin ayuda.

**Para cerrar**

8. **Resumen en una frase**, con mis palabras.

La ayuda se va retirando poco a poco: primero miro un caso resuelto, luego completo huecos y al final resuelvo solo.

## Las preguntas

- Una sola cosa por pregunta, siempre en afirmativo.
- Con opciones A, B o C cuando se puede.
- Dicen qué tipo de respuesta se espera: una letra, una IP, una frase.

## Repaso

Cada sesión empieza con tres preguntas cortas de micro-lecciones anteriores, contestadas sin mirar los apuntes. Lo que fallo vuelve a salir en la sesión siguiente.

## Laboratorios

Son entornos reales con Docker Compose. Cada micro-lección usa un trozo pequeño del laboratorio. El incidente con una falla escondida, que se resuelve sin ejemplo previo, llega al final de cada bloque.

## Cuándo una micro-lección está terminada

Cuando resolví solo el caso del paso 7, escribí mi resumen y subí los apuntes con su evidencia en un commit.

## Base

- **Efecto del ejemplo resuelto** (teoría de la carga cognitiva, John Sweller): quien empieza aprende más estudiando casos resueltos que resolviendo problemas desde cero. La ayuda se retira a medida que se gana experiencia.
- **Predecir, observar, explicar:** predecir antes de ver hace observar con más atención.
- **Seis estrategias de aprendizaje con evidencia** (The Learning Scientists): práctica espaciada, intercalar temas, recordar sin mirar, explicar el porqué, ejemplos concretos y combinar palabras con imágenes.
