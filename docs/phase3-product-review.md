# Revisión de producto de Fase 3 — 2026-09-10

Los cuatro recorridos manuales iniciales fueron completados por el usuario. Esta entrega revisa el producto después de esos recorridos; no constituye una nueva evaluación física ni aprobación mecánica.

Paquete piloto 0.3.1, **development**, en `mobile/assets/knowledge/pilot`. Cuatro procedimientos, sin ampliación de catálogo ni promoción. Los fixtures de `development/` siguen separados. Maestro técnico 0.1.0 intacto; ErgoMax→C260 permanece pendiente.

## Inspección previa y decisión

`RepairChoice.next` referencia nodos del mismo procedimiento y `RepairSession.choose` puede seguir una respuesta negativa hacia otra comprobación o acción. El validador exige referencias existentes, accesibilidad y un grafo acíclico. Esto soporta siguiente causa y reintentos acotados sin hacks ni cambios en la navegación del motor.

No soporta referencias a otro procedimiento: `reference(c.next, nodes, n.id)` las rechaza, la sesión tiene un único `final RepairProcedure`, y sus hechos, historial y seguridad no tienen contrato de transferencia entre procedimientos. No se incorporó esa arquitectura. Los siguientes diagnósticos de esta entrega viven dentro de cada uno de los cuatro grafos; no hay ciclos ni repeticiones ilimitadas.

`unresolved` se conserva únicamente como defensa interna del motor y no tiene representación visible. Los pilotos no terminan en ese estado. Un fallo no crítico abre primero otra comprobación; un peligro o una condición crítica que no puede comprobarse termina en stop. Las cuatro banderas críticas conservan prioridad irreversible y no admiten avance ni retroceso.

## Cambios por procedimiento

| Piloto | Cambio |
| --- | --- |
| Cadena | Identifica plato y brazo con dos rueditas en lenguaje cotidiano. Si vuelve a salir, inspección inmóvil de daño/atrapamiento y comprobación de colocación; permite una recolocación acotada si estaba fuera de los dientes. Repetición persistente requiere otro diagnóstico y restringe circulación. No se ajustan límites ni se presume compatibilidad con dientes alternos. |
| Cambios | Sustituye «indexado» en el título. Separa rueda firme, cable/funda, unión al cuadro (patilla) y topes previamente comprobados. Fallo del tensor abre inspección de funda fuera de su apoyo; solo se asienta sin forzar. No afloja cable ni toca H/L/B. |
| Cámara | Enseña vaciado, paso del borde rígido al canal del rin, uso de desmontable, extracción, inspección y montaje por tramos sin pellizcar. Una cámara atrapada permite desinflar y recolocar antes de inflar. Montaje del eje, medida/válvula y presión siguen requiriendo información aplicable al componente. |
| Disco | Distingue roce continuo de roce en parte de la vuelta. Solo admite un segundo centrado si rueda, freno, montaje y torque siguen confirmados. Fuga, pérdida de frenado, deformación o fijación insegura detienen. El roce restante pide diagnóstico, sin inventar enderezado, purga o torque. |

Cada identificación desconocida abre ayuda antes de terminar; la válvula por sí sola no demuestra que exista cámara. La ayuda de alcance permite buscar etiquetas/documentación y volver a comprobar condiciones antes de un stop. Un perfil conocido omite la identificación, pero nunca las comprobaciones de estado.

Las instrucciones usan un único botón «Paso hecho · continuar» en el piloto: se elimina la casilla más botón redundante, conservando `completeStep(checked: true)` internamente. Las preguntas se mantienen cuando su respuesta modifica la rama o acredita seguridad. `worked` permanece como ID interno, con comprobación mecánica específica en lugar de «¿Funcionó?». Las pruebas finales mantienen su función de comprobar la bicicleta antes de complete.

## Ayudas originales offline

`RepairNode.visualIds` es una lista opcional de cero o más IDs; admite referencias en pasos, identificaciones y demás nodos. El parser rechaza IDs desconocidos, duplicados y URLs. Los nodos sin imágenes mantienen el contrato anterior.

Tres recursos vectoriales originales están implementados mediante `CustomPainter` en `repair_visual.dart`: `tube_bead`, `chain_arm` y `disc_gap`. Se dibujan localmente, sin red, dependencias nuevas ni imágenes copiadas. Incluyen texto equivalente, semántica accesible y panel expandible; el flujo textual no depende de abrirlos. Son esquemas sin escala, sin dimensiones ni identificación de tornillos específicos. Las fuentes externas existentes sirven como contexto mecánico; ningún recurso gráfico fue descargado ni trazado.

Las referencias mecánicas revisadas incluyen [cámara y cubierta](https://www.parktool.com/en-us/blog/repair-help/tire-and-tube-removal-and-installation), [cambio trasero](https://www.parktool.com/en-us/blog/repair-help/rear-derailleur-adjustment) y [centrado hidráulico](https://www.parktool.com/en-us/blog/repair-help/hydraulic-disc-brake-alignment). El mapa editorial anterior sigue en `phase3-pilot.md`; esta revisión prevalece sobre su descripción de resultados y limitaciones iniciales.

## Límites antes de retomar evaluación física

- No hay transferencia entre procedimientos ni diagnóstico exhaustivo de desgaste, geometría o compatibilidad. Los reintentos tienen límite explícito.
- Un dato específico no se valida automáticamente: manual exacto y herramientas siguen siendo necesarios para torque, secuencia, eje y presión aplicable. No se añadieron cifras ni especificaciones.
- Los diagramas explican ubicación relativa o movimiento, no certifican identificación exacta, alineación de patilla o tornillos de una pinza real. El registro de tres IDs está compilado: añadir otro recurso requiere código y revisión; no se creó una biblioteca ni un formato de SVG arbitrario.
- Las ayudas visuales requieren evaluar comprensión sobre bicicletas reales y pantallas de teléfono, especialmente identificar la jaula, el talón y el contacto disco/pastillas. Las pruebas de software no sustituyen esa evaluación.
- Se recibió confirmación de los recorridos manuales, pero no fichas con observaciones individuales; no se inventaron resultados físicos.

## Verificación

Resultado final: **213 pruebas aprobadas** en la suite completa; `flutter analyze --no-pub` sin incidencias y `git diff --check` sin errores de espacios.

La regresión recorre todas las aristas elegibles en invitado/activo y ruta/taller, incluidos ayuda, fallo, siguiente causa y reintentos. Inyecta cada hard stop en todos los estados alcanzables y comprueba su irreversibilidad. Una prueba específica demuestra cadena fallida → siguiente causa → recolocación → prueba final → complete, y hard stop posterior irreversible.

Tres pruebas de interfaz renderizan ayudas originales, comprueban texto y comparan capturas. Las capturas de `mobile/test/goldens/` se revisaron visualmente con Roboto del SDK. Los ocho recorridos UI completos se adaptaron al botón único. Registro de regresión: `mobile/build/product-review-tests.log`.

SHA-256 del maestro XLSX verificado: `e3b4510f378b70c6e2758b24b1301124b49806b3299ad70612758fbdce706b1d`. La prueba compara además los componentes piloto con el JSON técnico generado. No se generó APK ni se retomó evaluación física.
