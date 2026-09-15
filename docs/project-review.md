# Estado del proyecto BiciFirme

Documento canónico y vivo de seguimiento. Describe el estado vigente del producto; Git conserva el historial. Ante cada cambio relevante se actualizan únicamente las secciones afectadas.

## Estado actual del producto

BiciFirme es una aplicación Flutter offline para identificar problemas y guiar reparaciones de bicicletas. Usa Riverpod, GoRouter y SQLite local; no tiene backend, cuentas, IA, sincronización, analítica ni telemetría. La versión de la aplicación es `0.1.0+1`. La preparación técnica Android avanzó, pero el producto todavía no es publicable ni candidato a release.

La edición `approved` no contiene procedimientos mecánicos. El laboratorio disponible solo en debug carga cuatro pilotos en `development`. Los fixtures sintéticos permanecen separados para probar contratos y nunca se ofrecen como contenido aprobado ni guardan identificaciones en el perfil de una bicicleta.

## Auditoría de cierre V1 · 14 de septiembre de 2026

**Veredicto actual: `NOT_READY_FOR_RC`.** La aplicación release compila y sus funciones de inicio/garaje funcionan, pero la propuesta principal no es funcional de extremo a extremo en producción: el catálogo approved tiene cero procedimientos. Buscar, elegir síntoma o contexto termina en un estado vacío verdadero; los cuatro pilotos no pueden promoverse sin evaluación física y revisión editorial.

| Clasificación | Hallazgo y evidencia | Estado |
| --- | --- | --- |
| Bloqueante de producto | `assets/knowledge/approved/repairs.json` contiene cero procedimientos; búsqueda, identificación dentro de reparación y diagnóstico no resuelven ningún problema en release. | Abierto |
| Bloqueante de seguridad | Ningún procedimiento mecánico tiene todavía aprobación editorial/física. Publicar los pilotos como guía violaría los gates y no puede resolverse con tests de software. | Abierto |
| Bloqueante Android release | Falta clave de carga del propietario y AAB firmado. El AAB sin firma compila; un APK release firmado solo con debug se usó exclusivamente en emulador. | Abierto |
| Requisito Google Play | target/compile 36, nombre, iconos y AAB están preparados. Faltan Play App Signing, ficha, capturas finales, URL de privacidad, Data Safety, clasificación y pruebas internas/cerradas. | Parcial |
| Validación física pendiente | Cadena, cámara, cambios y disco requieren por separado éxito independiente, ejecución autónoma y cero bloqueantes según el protocolo vigente. | Abierto; no simulado |
| QA release pendiente | Emulador release cubrió clean install, offline, reapertura, 720×1280, texto 150% y oscuro. Faltan teléfonos reales, versiones Android representativas, TalkBack y verificación del AAB firmado desde Play. | Parcial |
| Deuda post-V1 | Kit, historial, mantenimiento, notificaciones, backup y continuidad entre procedimientos continúan fuera del alcance V1 vigente. | Posponible |
| Mejora opcional | ARB propios, biblioteca visual ampliada y cobertura adicional después de cerrar los cuatro pilotos. | Posponible |

### Preparación Android y privacidad

- Identidad: `com.robmac.bicifirme`, sin cambio. Nombre visible: **BiciFirme – Repara tu bici**. Versión: 0.1.0+1.
- Toolchain verificado: Flutter 3.47.2 / Dart 3.13.2, AGP 9.3.0, Gradle 9.5.0, JVM 17. SDK finales: compile 36, target 36, min 24.
- Release usa R8 y shrink resources. Firma debug no se asigna a release; `key.properties` está ignorado y ahora falla si existe incompleto.
- El icono Flutter fue reemplazado por un activo original en densidades legacy/round y adaptive, con splash Android propio claro/oscuro.
- Se retiraron `share_plus`, `pdf` y `printing`, sin usos en código, junto con 23 transitivas. Runtime Android queda limitado a persistencia/ruta local: Drift, SQLite, path_provider y sus puentes JNI/AndroidX, además de Riverpod/GoRouter.
- El manifest release fusionado no solicita Internet, ubicación, cámara, micrófono, almacenamiento, contactos, identificadores publicitarios, Bluetooth ni notificaciones. Solo usa un permiso interno `signature` de AndroidX. Debug/profile conservan Internet para tooling Flutter.
- Los fixtures sintéticos `development` ya no se empaquetan. El paquete piloto sigue disponible para debug, pero la política combina habilitación inyectable con `kDebugMode`; release no puede activarla por ruta o parámetro. Dos pruebas cubren repositorio y UI.
- El AAB de comprobación se generó sin firma de producción. Tamaño/hashing vigentes se registran en [android-release.md](android-release.md); reconstruir después de cualquier cambio invalida esa huella.

## Fase vigente

- Fase 1, fundamentos: infraestructura implementada — identidad BiciFirme, garaje SQLite, perfiles progresivos, bicicleta activa/predeterminada, invitado y firma release separada de debug.
- Fase 2, conocimiento: infraestructura implementada — esquemas versionados, validación estricta, importación editorial, búsqueda offline y aislamiento approved/development.
- Fase 3, resolver un problema: infraestructura y cuatro pilotos 0.3.2 implementados. La validación física/mecánica no está cerrada y la fase no se considera terminada.
- Fases posteriores: kit, historial, mantenimiento, notificaciones, backup, diseño visual final, cobertura amplia y distribución no están implementados o cerrados.

## Arquitectura vigente

El dominio en `mobile/lib/domain/` no depende de Flutter ni SQLite. Los catálogos técnicos y de reparaciones tienen versiones y fuentes independientes; un manifiesto fija las versiones compatibles. Los parsers rechazan campos desconocidos, referencias rotas, IDs duplicados, ciclos y mezclas de estado editorial.

`RepairSession` ejecuta un solo procedimiento validado y conserva hechos, historial de navegación y banderas críticas. La continuidad diagnóstica ocurre dentro del grafo del procedimiento mediante ramas acotadas. No existen enlaces entre procedimientos ni ciclos.

`RepairKnowledgeRepository` carga paquetes JSON locales. El teléfono no interpreta XLSX ni ejecuta Python. El maestro editorial se transforma fuera del runtime y no se copia automáticamente a assets aprobados.

Los datos de usuario viven en SQLite. El repositorio actual implementa bicicletas y preferencias; las tablas de componentes, kit, historial y mantenimiento están preparadas, pero sus flujos de producto no están implementados.

## Reglas de producto y UX vigentes

- Los únicos resultados terminales visibles son `complete` (reparación completa), `temporary` (solución provisional real) y `stop` (no continuar cuando no sea seguro circular o intervenir).
- `unresolved` es exclusivamente interno y se proyecta a `null`; no se muestra ni se convierte automáticamente en `stop` o `temporary`. Ningún nodo o arista de los pilotos termina en unresolved.
- `temporary` solo se usa cuando existe una solución provisional real con restricciones. Ninguno de los cuatro pilotos actuales lo usa.
- `complete` exige una prueba final aprobada. El contexto ruta/taller no altera el significado del resultado.
- Las banderas `structural_damage`, `braking_loss`, `steering_damage` y `critical_part_broken` producen hard stops irreversibles. Tras registrarlas no se permite avanzar ni retroceder, aunque hubiera un resultado previo.
- Un fallo técnico no crítico abre otra causa o comprobación segura cuando existe dentro del alcance. Agotar una intervención no se presenta como una categoría inventada.
- Las preguntas visibles se reservan para decisiones que cambian el árbol o la seguridad. Los pasos de los pilotos usan una sola confirmación de continuación.
- «No sé / no puedo comprobarlo» ofrece ayuda segura de identificación o comprobación antes de terminar cuando es posible.
- BiciFirme enseña operaciones generales. Manual o fabricante se exige únicamente para datos o montajes específicos que no pueden universalizarse.
- No se inventan torque, presión, compatibilidad, medidas, tolerancias, secuencias ni especificaciones. Ausencia de relación técnica significa desconocido.
- Las ayudas visuales son originales, opcionales, offline y complementarias; el texto debe seguir siendo suficiente.

## Pilotos 0.3.2

Los cuatro procedimientos tienen estado `development`, riesgo editorial moderado y dependencia técnica 0.1.0.

| Piloto | Alcance actual | Continuidad y límite |
| --- | --- | --- |
| Cadena | Recolocar una cadena entera y libre salida del plato en un sistema admitido | Si falla, comprueba daño/atrapamiento, posición sobre dientes y permite una recolocación acotada. Salto o salida repetida termina en stop. |
| Cámara | Sustituir cámara en cubierta convencional y comprobar extracción, inspección, montaje, asiento, rueda y frenos | Una cámara atrapada puede desinflarse y recolocarse. Medida, válvula, presión y montaje específico deben estar documentados. |
| Cambios | Corregir tensión de cable de cambio trasero mecánico convencional | Descompone rueda, cable/funda, unión al cuadro, topes y apoyo de funda. No toca H/L/B, fijación de cable ni piezas dañadas. |
| Disco | Centrar una pinza hidráulica con montaje y torque aplicables conocidos | Distingue roce continuo de posible deformación y admite un reintento acotado. No purga, endereza discos ni inventa torque. |

Cada procedimiento mantiene entrada de seguridad, identificación, alcance, contexto, recursos, acciones, comprobaciones y prueba final. El título y el texto usan términos cotidianos primero y explican los técnicos cuando hacen falta.

Hay tres ayudas visuales vectoriales originales generadas localmente: canal del rin/cámara (`tube_bead`), brazo del cambio/cadena (`chain_arm`) y separación disco/pastillas (`disc_gap`). El registro actual está compilado en la aplicación y no constituye una biblioteca gráfica completa.

Existe evidencia de un recorrido manual de cada piloto, pero no cumple por sí sola el protocolo de evaluación física supervisada ni constituye aprobación mecánica.

### Estado del gate físico por piloto

| Piloto | Estado | Próxima acción física |
| --- | --- | --- |
| dev.pilot.chain | `NOT_TESTED` | Ejecutar primero una sesión segura de cadena salida del plato y someter el resultado a inspección independiente. |
| dev.pilot.tube | `NOT_TESTED` | No iniciar hasta cerrar y revisar el intento de cadena. |
| dev.pilot.index | `NOT_TESTED` | No iniciar hasta cerrar y revisar el piloto anterior. |
| dev.pilot.disc | `NOT_TESTED` | No iniciar hasta cerrar y revisar el piloto anterior; exige además manual y torque exactos. |

Los estados viven únicamente en documentación. En la preparación del 14 de septiembre de 2026 no había un teléfono Android físico conectado a `flutter devices`; el único Android disponible era un emulador y no puede aportar evidencia mecánica.

Antes de la primera sesión, la revisión 0.3.2 corrigió la discrepancia de recursos de cadena: ahora referencia el `stand` ya existente y lo presenta como cualquier apoyo estable que mantenga la bicicleta firme y la rueda trasera libre, sin exigir caballete profesional. Los nodos de contexto permiten detenerse antes de actuar si no puede conseguirse una posición estable. La redacción equivalente de cambios y disco también deja explícito que no debe continuarse sobre un apoyo inestable. No se alteró la lógica mecánica, el maestro ni el estado del gate; los cuatro pilotos siguen `NOT_TESTED`.

## Infraestructura implementada y contenido editorial

La infraestructura implementada incluye garaje y persistencia, contratos de conocimiento, importadores, validador, búsqueda, motor de sesión, interfaz de reparaciones, controles development/approved, recursos por ID y ayudas visuales offline.

El contenido editorial vigente comprende el maestro técnico 0.1.0 en `development`, cuatro pilotos 0.3.2 y sus fuentes. La edición aprobada continúa vacía. Validar estructura o ejecutar pruebas de software no acredita exactitud, seguridad ni comprensión mecánica.

## Limitaciones actuales

- Un procedimiento no transfiere sesión, hechos ni seguridad a otro procedimiento.
- Los grafos son acíclicos y los reintentos están expresamente limitados.
- El motor no captura ni verifica automáticamente manuales, torque aplicado, presión medida o montaje exacto.
- La identificación visual ayuda a reconocer relaciones básicas, pero no certifica modelo, compatibilidad, alineación o tornillos específicos.
- La búsqueda cubre los cuatro problemas piloto; no es un diagnóstico exhaustivo ni ofrece cobertura por categoría.
- No existe historial de reparaciones, mantenimiento, kit, backup, recordatorios ni notificaciones en la experiencia de producto.
- No se ha verificado la aplicación en la matriz final de teléfonos, TalkBack ni distribución firmada desde Play. Modo sin red, reapertura, pantalla reducida, texto 150% y oscuro sí se comprobaron en emulador release.

## Deuda técnica

- Extraer recursos de texto propios a ARB en lugar de depender parcialmente de delegados Flutter en español.
- Diseñar, implementar y probar backup JSON versionado con restauración transaccional.
- Implementar los flujos todavía preparados solo en base de datos: componentes de bicicleta, kit, historial y mantenimiento.
- Definir una infraestructura de ayudas visuales ampliable si la evaluación demuestra que el registro compilado de tres diagramas no basta.
- Determinar si una futura continuidad entre procedimientos necesita un contrato de transferencia; no añadirla sin diseñar seguridad, historial y hechos.
- Completar firma del propietario, entrega interna desde Play y QA en dispositivos físicos cuando el contenido approved exista.

## Deuda editorial

- El maestro 0.1.0 permanece intacto en `development`. Su SHA-256 es `e3b4510f378b70c6e2758b24b1301124b49806b3299ad70612758fbdce706b1d`.
- La incompatibilidad ErgoMax→C260 sigue únicamente como nota. Falta una fila editorial explícita, con alcance y fuente, antes de representarla como compatibilidad; no debe inferirse de la prosa.
- Falta revisión/aprobación editorial del catálogo técnico y de los cuatro pilotos.
- Falta vinculación más granular entre afirmaciones/nodos y fuentes si se decide exigir trazabilidad por afirmación.
- Falta identificación exacta de componente cuando una especificación o montaje dependa del modelo.
- Falta ampliar catálogo y cobertura únicamente después de cerrar los gates del piloto; no hay autorización implícita para hacerlo.

## Validación actual

La última regresión completa aprobó **218 pruebas** y `flutter analyze --no-pub` terminó sin incidencias. La cobertura incluye persistencia y migración, parsers, referencias y grafos, búsqueda, perfiles progresivos, importación del maestro, recorridos de los cuatro pilotos, correspondencia entre maniobras con rueda libre y declaración de apoyo estable, igualdad ruta/taller, resultados terminales, continuidad tras fallo no crítico, hard stops desde cada estado alcanzable, renderizado de las tres ayudas visuales y aislamiento production/development.

La regresión confirma que los pilotos no contienen nodos/aristas unresolved ni resultados temporary. El maestro y el JSON generado se comparan mediante huella y conteos. Estas son validaciones de software y estructura.

La validación física/mecánica permanece separada. El protocolo y la plantilla vigentes están en [evaluación física](phase3-physical-evaluation.md) y [plantilla de resultados](phase3-physical-results-template.md).

## Gates

| Gate | Estado |
| --- | --- |
| Fundamentos de aplicación y persistencia | Superado como infraestructura de desarrollo |
| Contratos, importación y aislamiento editorial | Superado como infraestructura de desarrollo |
| Cuatro pilotos ejecutables y regresión de software | Superado para 0.3.2 development |
| Evaluación física supervisada por piloto | No superado / no cerrado |
| Revisión editorial y contenido approved | No superado; approved vacío |
| Cobertura funcional amplia | No superado; limitada a cuatro pilotos |
| QA final en dispositivos, accesibilidad y modo avión | Parcial en emulador; no superado en dispositivos físicos/TalkBack |
| Build Android API 36 y AAB sin firma | Superado como comprobación técnica |
| Release Android firmado y requisitos de tienda | No superado |

La Fase 3 no se cierra por las pruebas de software ni por los recorridos manuales ya realizados.

## Decisiones que no deben reinterpretarse

- El maestro y sus vacíos se conservan; los importadores no completan, corrigen ni promueven contenido.
- El contenido `development` nunca se vuelve aprobado cambiando solo un estado o copiando archivos.
- Compatibilidad exige par, tipo y alcance exactos; no hay transitividad ni expansión automática por familia.
- Las especificaciones del fabricante prevalecen cuando la operación depende del componente; BiciFirme no crea valores universales.
- Los hard stops dominan cualquier resultado anterior y son irreversibles durante la sesión.
- `unresolved` no es una cuarta salida de producto. `temporary` no significa «no resuelto».
- Las ayudas visuales no sustituyen texto, manual ni identificación exacta y deben ser originales.
- La evidencia de software, editorial y física se registra por separado.

## Siguiente paso recomendado

Conectar un teléfono Android físico e iniciar únicamente `dev.pilot.chain` mediante el laboratorio debug, siguiendo la preparación y el registro por sesión del protocolo. Corregir y repetir físicamente cualquier ruta afectada antes de avanzar al piloto siguiente. Solo después de cerrar los cuatro gates y su revisión editorial podría plantearse una edición approved real. Hasta entonces, mantener pilotos y maestro en `development`, approved vacío y el catálogo sin ampliación; no crear release candidate.
