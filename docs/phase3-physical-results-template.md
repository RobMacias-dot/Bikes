# Resultados de evaluación física · plantilla por sesión

Copiar esta plantilla para cada sesión según el [protocolo](phase3-physical-evaluation.md). Conservar también fallos, ayudas e interrupciones. Usar IDs anónimos para personas y bicicleta; no incluir nombres, contactos, números de serie ni otros datos identificables. Dejar «no evaluado» o «no verificable» donde corresponda; no completar por inferencia. Todo permanece en `development`.

## Identificación y condiciones

| Campo | Registro |
| --- | --- |
| ID de sesión y fecha | |
| ID anonimizado del tester | |
| Experiencia aproximada | Principiante / básica / intermedia / avanzada; breve experiencia relevante: |
| Procedimiento | dev.pilot.chain / dev.pilot.tube / dev.pilot.index / dev.pilot.disc |
| Estado del piloto al iniciar | NOT_TESTED / IN_TESTING / FAILED / PASS_PENDING_EDITORIAL / PASS |
| Estado del piloto al cerrar esta sesión | IN_TESTING / FAILED / PASS_PENDING_EDITORIAL / PASS; justificación y revisor: |
| Bicicleta | ID anónimo, tipo y modelos de componentes relevantes: |
| Contexto | Ruta controlada / casa o taller |
| Modo | Invitado / bicicleta activa; datos de perfil reutilizados: |
| Versión del paquete | Versión de reparaciones y dependencia técnica; estado development: |
| Commit/build evaluado | SHA del commit, cambios locales si existen, ID del build y dispositivo/plataforma: |
| Entrada | Directa por problema / síntomas; búsqueda o síntoma elegido: |
| Supervisor / inspector independiente | IDs anónimos; confirmar personas distintas y que el inspector no guio la reparación: |
| Sesión anterior relacionada | ID del intento anterior o no aplica: |
| Tipo de sesión | Reparación física / escenario de hard stop sin avería provocada |
| Condición inicial y síntoma reproducibles | Condición preexistente, cómo se verificó antes de actuar y evidencia; no fabricar una avería: |
| Admisión segura y dentro del alcance | Sí / no; comprobaciones del supervisor: |
| Manuales y recursos disponibles | Documento/modelo/revisión aplicable, herramientas y consumibles: |

## Recorrido, comprensión y ayuda

| Nodo / momento | Duda, error o intento de omisión observado | Comprensión expresada por el usuario | Ayuda: ninguna / verbal / demostración / física | ¿Ayuda mecánica o de interfaz? Detalle y quién ayudó | Tiempo / evidencia |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

Registrar explícitamente «ninguna» si no hubo dudas, errores o ayuda. La explicación de una decisión mecánica cuenta como ayuda mecánica aunque sea solo verbal.

| Campo | Registro |
| --- | --- |
| Inicio / fin y tiempo total | |
| Tiempo de acciones, pausas y ayuda | |
| Comprende alcance, No sé y cuándo detenerse | Sí / no / no evaluado; evidencia: |
| Distingue acción, comprobación y prueba final | Sí / no / no evaluado; evidencia: |
| Comprende el resultado sin atribuirlo al contexto | Sí / no / no evaluado; explicación del tester: |
| Ayuda mecánica requerida | Ninguna / verbal / demostración / física; nodos: |
| Ayuda de interfaz requerida | Ninguna / detalle: |
| Interrupción del supervisor | No / sí; motivo y momento: |

## Hallazgos de contenido, seguridad, ayudas y UX

Registrar «ninguno» cuando se haya observado expresamente el aspecto. No agrupar aquí un resultado mecánico fallido: conservarlo también en la inspección independiente.

| Aspecto | Hallazgo, nodo/momento y evidencia |
| --- | --- |
| Error de identificación | |
| Instrucción que no corresponde a la bicicleta o componente | |
| Paso confuso o intento de omisión | |
| Instrucción potencialmente insegura | |
| Falso complete | |
| Stop incorrecto o evitable | |
| Problema de ayuda visual o ausencia de apoyo necesario | |
| Observación UX o de accesibilidad | |

## Resultado mostrado y hard stops

| Campo | Registro |
| --- | --- |
| Resultado mostrado | complete / temporary / stop / sin resultado por interrupción |
| Texto visible y nodo terminal | Transcripción o evidencia anonimizada: |
| Respuesta a la comprobación mecánica previa y a la prueba final | |
| Coincide entre contextos con las mismas respuestas | Sí / no / no evaluado; referencia a comprobación sin repetir avería física: |

Los cuatro pilotos actuales no ofrecen `temporary`; si aparece, registrar discrepancia, no normalizarla.

| Hard stop encontrado o representado | Real / escenario | Nodo y momento, incluso tras resultado | Resultado visible | ¿Bloqueó retroceso y continuación? Intento y respuesta | Actuación del usuario y supervisor |
| --- | --- | --- | --- | --- | --- |
| Ninguno / structural_damage / braking_loss / steering_damage / critical_part_broken | | | | | |

## Resultado mecánico independiente

Completar por el inspector sin usar el resultado de la app como prueba. Separar cualquier reparación posterior del resultado de este intento.

| Campo | Registro |
| --- | --- |
| Inspector y fecha/momento de inspección | ID anónimo: |
| Criterios del piloto comprobados | |
| Evidencia y mediciones aplicables | Manual, instrumento, valores e intervalo cuando corresponda; sin tolerancias inventadas: |
| Resultado mecánico independiente | Éxito verificado / no resuelto / no verificable / no aplica (escenario o parada sin reparación pretendida) |
| Relación con resultado mostrado | Coincide / no coincide / no verificable; motivo: |
| Inspección final de funciones y fijaciones afectadas | |
| Intervenciones posteriores | Ninguna / detalle y sesión de reevaluación: |
| Clasificación del intento | Resolución autónoma verificada / éxito asistido verificado / parada correcta / fallo / no evaluado |
| Observaciones | |

## Aporte al gate del piloto

- Éxito mecánico independiente acreditado por esta sesión: sí / no.
- Ejecución sin ayuda mecánica: sí / no. Resolución autónoma verificada con comprensión: sí / no.
- Éxito asistido: sí / no. Se conserva como evidencia; no cuenta como resolución autónoma.
- Bloqueantes observados: ninguno / falso complete / instrucción insegura / hard stop eludible / reparación no verificada. Descripción, evidencia e ID del hallazgo:
- Seguimiento del bloqueante: pendiente / corrección y reevaluación documentadas; referencias (sin borrar el resultado original):

### Corrección y repetición, si la sesión falló

| Clasificación principal | Defecto y alcance mínimo de la corrección | Regresión de software ejecutada | Repetición física exigida y sesión nueva | Estado del hallazgo |
| --- | --- | --- | --- | --- |
| Mecánico/contenido / UX / arquitectura / ayuda visual / prueba mal planteada | | | | Abierto / cerrado con evidencia |

### Consolidación por piloto (completar al revisar el conjunto de sesiones)

| Piloto | Sesión(es) de éxito mecánico independiente | Sesión(es) de resolución autónoma verificada sin ayuda mecánica | Éxitos asistidos conservados | Bloqueantes y cierre documentado | Dictamen |
| --- | --- | --- | --- | --- | --- |
| dev.pilot.chain | | | | | NOT_TESTED |
| dev.pilot.tube | | | | | NOT_TESTED |
| dev.pilot.index | | | | | NOT_TESTED |
| dev.pilot.disc | | | | | NOT_TESTED |

Estado: `NOT_TESTED` / `IN_TESTING` / `FAILED` / `PASS_PENDING_EDITORIAL` / `PASS`. Exigir ambos mínimos por piloto y ausencia de bloqueantes pendientes conforme al protocolo. No compensar fallos con éxitos de otros pilotos. Registrar responsable de revisión (ID anónimo), fecha y justificación. Este registro no modifica `development`, no promueve contenido y no aprueba una publicación.
