> Actualización 2026-09-10: ver [revisión de producto 0.3.1](phase3-product-review.md). Prevalece sobre las descripciones anteriores de stop/unresolved, confirmaciones, ayuda visual y límites del piloto.

# Piloto mecánico de Fase 3

Paquete `mobile/assets/knowledge/pilot`: reparaciones 0.3.0, estado **development**, dependencia técnica 0.1.0. El botón de laboratorio debug lo carga; approved sigue vacío y release conserva su bloqueo. Los cuatro fixtures sintéticos anteriores quedan separados para regresión. No se hizo promoción editorial ni cambios de historial, mantenimiento o diseño final.

## Procedimientos y alcance

| ID (prefijo dev.pilot.) | Intervención | Tiempo editorial provisional | Fuera de alcance |
| --- | --- | --- | --- |
| chain | Recolocar cadena entera salida del plato | 5–15 min | Motor, cadena atrapada/rota, salidas repetidas, guías, dientes alternos |
| tube | Sustituir cámara y comprobar montaje | 20–45 min | Tubeless/tubular, cubierta/rin dañados, medida/válvula/presión o montaje de rueda desconocidos |
| index | Un intento de corrección del tensor en cambio mecánico convencional | 10–25 min | Electrónico/inverso, límites sin verificar, daño, salto bajo carga, cambio de componentes |
| disc | Centrado inicial de pinza hidráulica | 15–30 min | Mecánico, fugas, pérdida de frenado, rotor doblado, holguras, torque o montaje desconocidos |

Riesgo moderado en los cuatro casos: clasificación editorial provisional, no certificación. Las estimaciones incluyen preparación y prueba, no son tiempos publicados por los fabricantes.

Todos incluyen entrada de seguridad, identificación con No sé, comprobación del alcance aun con perfil conocido, contexto ruta/taller, recursos, acciones confirmadas, bifurcaciones, ¿funcionó? y prueba final. Una reparación lograda dentro del alcance y con prueba final aprobada conduce a complete en ambos contextos. Fallos, incertidumbre y recursos ausentes conducen a stop. El contexto modifica la preparación del lugar, no el significado del resultado. Estos cuatro pilotos no incluyen una reparación mecánicamente provisional: se eliminaron sus ramas temporary. El motor conserva complete/temporary/stop como únicos resultados visibles; no se exige que cada procedimiento use los tres.

Las cuatro banderas críticas del motor son irreversibles dentro de la sesión, incluso si se reportan tras un resultado. La identificación leída de una bicicleta no certifica su estado actual; scope siempre exige revisión. No se guardan respuestas development en el perfil.

## Fuentes verificadas el 2026-09-07

| Fuente | Afirmaciones utilizadas / nodos |
| --- | --- |
| [iFixit: cadena salida](https://www.ifixit.com/Guide/How+to+Fix+a+Slipped+Bicycle+Chain/37682) | Solo pasos 2–3 y conclusión: holgura, recolocación y giro manual; chain.action0–2. Se excluyen expresamente el ajuste en marcha, acortamiento y reensamblaje del artículo. |
| [Park Tool: cámara y cubierta](https://www.parktool.com/en-us/blog/repair-help/tire-and-tube-removal-and-installation) | tube.action0–2, inspect, seated, final: desmontaje, inspección, prevención de pellizco, asiento e inflado. |
| [Park Tool: rueda](https://www.parktool.com/en-us/blog/repair-help/wheel-removal-and-installation) | tube.scope/action0/action2/final: montaje específico, reconexión y comprobación; no accionar freno hidráulico sin disco. |
| [Park Tool: medidas y cámaras](https://www.parktool.com/en-us/blog/repair-help/tire-wheel-and-inner-tube-fit-standards) | tube.scope y recurso tube: verificar medida y válvula; no inferir compatibilidad por apariencia. |
| [Schwalbe: presión](https://www.schwalbe.com/en/technology-faq/tire-pressure/) | tube.scope/action2/final: usar información aplicable y manómetro; no asignar una presión universal. |
| [Schwalbe: rin y llanta](https://www.schwalbetires.com/technology-faq/tire-dimensions/) | tube.scope/action2: respetar información del fabricante del rin además de la cubierta. |
| [Park Tool: indexado](https://www.parktool.com/en-us/blog/repair-help/rear-derailleur-adjustment) | index.scope/direction/action0–2/final: patilla, un clic, sentido y vuelta del tensor. Se limita a un intento; no se tocan H/L/B ni fijación del cable. |
| [Park Tool: disco hidráulico](https://www.parktool.com/en-us/blog/repair-help/hydraulic-disc-brake-alignment) | disc.scope/action0–2/secured/final: descartar causas ajenas a alineación y centrar pinza. No se adopta el torque genérico de la página ni su ajuste con rueda girando. |

Cada procedimiento incluye los IDs de sus fuentes y la ficha muestra documento, sección y URL seleccionable. Las comprobaciones finales en zona despejada y límites del piloto son controles editoriales conservadores; no cifras ni requisitos universales atribuidos a esas fuentes. No hay datos nuevos de desgaste, fluidos ni compatibilidad comercial.

## Maestro preservado

No se editan XLSX, JSON generado 0.1.0 ni sus compatibilidades. `pilot/components.json` es una copia semánticamente idéntica al generado. SHA-256 del XLSX: `e3b4510f378b70c6e2758b24b1301124b49806b3299ad70612758fbdce706b1d`. ErgoMax→C260 permanece deuda editorial para otra versión; el esquema ya puede expresarla.

## Limitaciones reveladas por contenido real

- Faltaban referencias de recursos: se añadieron solo catálogos locales de nombres e IDs de herramientas/consumibles en reparaciones. No se deduce compatibilidad ni se relacionan automáticamente con consumibles del maestro. Cantidades y disponibilidad condicional se expresan en texto y comprobaciones.
- El motor no captura ni verifica manuales específicos, presión medida o torque aplicado. Para este piloto se exige que el evaluador tenga y confirme esa documentación; si no, stop. No se incorporaron valores inventados. Esto limita la autonomía de personas sin experiencia, especialmente rueda y frenos.
- No hay bucles en el grafo: indexado y centrado tienen un intento acotado; si falla, stop. No se amplió el motor para ajustes repetidos.
- Fuentes a nivel procedimiento, con mapa de nodos en este documento. No se añadió una infraestructura de afirmaciones ni revisión editorial.
- No sé detiene ante identificación insuficiente: todavía no hay identificación visual asistida. La ruta de síntomas ofrece acceso a los cuatro problemas, no un diagnóstico exhaustivo.
- Las pruebas de software no demuestran todavía éxito de una persona sobre una bicicleta real. Falta ejecutar el [protocolo de evaluación física supervisada](phase3-physical-evaluation.md) y revisión mecánica antes de aprobar contenido.

## Archivos de esta entrega

- `mobile/lib/domain/knowledge/repair_catalog.dart`: contrato y resolución de recursos, exigencias del piloto.
- `mobile/lib/data/knowledge/repair_knowledge_repository.dart`: carga del piloto debug.
- `mobile/lib/features/repairs/{problems_page,repair_page}.dart`: síntomas, aviso editorial, consumibles y fuentes.
- `mobile/pubspec.yaml`: assets piloto.
- `mobile/assets/knowledge/pilot/{manifest,components,repairs}.json`: paquete separado.
- `tools/build_phase3_pilot.py`: generación reproducible, sin tocar maestro.
- `mobile/test/phase3_pilot_test.dart`: contrato, integración del cargador, todos los caminos y banderas críticas.
- `mobile/test/phase3_pilot_widget_test.dart`: ocho recorridos UI completos, acceso directo invitado/ruta y síntomas/bicicleta activa/taller para cada procedimiento.
- `docs/{phase3-pilot,knowledge-base,knowledge-schemas}.md`: alcance, fuentes y contrato.
- `README.md`: entrada actual del laboratorio y enlace a este informe.

La regresión de motor recorre cada arista elegible en los cuatro cruces invitado/activo × ruta/taller por procedimiento; verifica tanto ramas del indexado como respuestas negativas, fallos finales y No sé. Inyecta cada hard stop desde cada estado alcanzable, incluidos resultados, e intenta retroceder y avanzar. Esto es cobertura explícita de grafo, no un porcentaje de cobertura de líneas.

Validación tras corregir la semántica de resultados: `flutter analyze --no-pub` sin incidencias; `flutter test --no-pub --reporter expanded` con **208 tests aprobados**, incluidos **52 tests del piloto de contrato/motor y 8 de interfaz**. Las cuatro regresiones adicionales comparan todos los recorridos con idénticas respuestas entre ruta y taller: mismo resultado mecánico y visible, incluido complete. Los recorridos UI esperan reparación completa en ambos contextos. Se mantienen las pruebas de hard stops irreversibles desde todos los estados alcanzables. Registro local: `mobile/build/phase3-tests.log`. `git diff --check` sin errores de espacios. Se utilizó el runtime Python configurado para la regresión del importador XLSX. No se generaron APK/AAB ni se ejecutó una reparación física.
