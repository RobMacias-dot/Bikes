# Pilotos mecánicos de Fase 3

Especificación editorial vigente del paquete `mobile/assets/knowledge/pilot`: reparaciones **0.3.2**, estado **development**, dependencia técnica **0.1.0**. El laboratorio debug carga estos cuatro procedimientos; la edición approved permanece vacía.

## Alcance

| ID (prefijo `dev.pilot.`) | Intervención | Tiempo editorial | Fuera de alcance |
| --- | --- | ---: | --- |
| chain | Recolocar cadena entera y libre salida del plato | 5–15 min | Motor, cadena atrapada/rota, salida repetida sin resolver, guías y dientes alternos no identificados |
| tube | Sustituir una cámara en cubierta convencional | 20–45 min | Tubeless/tubular, cubierta/rin dañados, medida/válvula/presión o montaje de rueda desconocidos |
| index | Ajuste menor de tensión en cambio trasero mecánico por cable | 10–25 min | Electrónico/inverso, topes sin verificar, daño, salto bajo carga, cambio de componentes o ajuste H/L/B |
| disc | Centrado acotado de pinza hidráulica | 15–30 min | Freno mecánico, fugas, pérdida de frenado, disco deformado, holguras, torque o montaje desconocidos |

Los cuatro tienen riesgo editorial moderado. Incluyen entrada de seguridad, identificación y ayuda, comprobación de alcance, contexto ruta/taller, recursos, acciones, comprobaciones observables, siguiente causa cuando es segura y prueba final.

Los únicos resultados visibles admitidos son complete, temporary y stop. Ningún piloto termina en unresolved y ninguno usa temporary porque no implementa una solución provisional real. Complete exige prueba final aprobada. Una técnica fallida puede abrir otra comprobación dentro del mismo procedimiento; los grafos no enlazan procedimientos, no tienen ciclos y limitan los reintentos.

Las cuatro banderas críticas son irreversibles. El perfil puede evitar una pregunta de identificación si contiene un valor reconocido, pero nunca sustituye comprobar el estado actual. Las respuestas development no se guardan en la bicicleta.

## Operaciones y límites vigentes

- Cadena: declara el apoyo estable compartido por ID, sin exigir caballete profesional; antes de intervenir confirma que la bicicleta esté firme y la rueda trasera pueda girar libremente, con salida a stop si no puede conseguirse sin improvisar. Explica plato y brazo con dos rueditas, obtiene holgura sin forzar y recoloca con las manos fuera antes de girar. Si la primera comprobación falla, revisa daño/atrapamiento y posición, y admite una recolocación adicional acotada. Salto o salida repetida termina en stop.
- Cámara: enseña desinflado, paso del borde rígido de la cubierta al canal central, extracción, inspección, montaje por tramos y corrección de una cámara atrapada. Medida, válvula, presión y montaje de rueda deben corresponder al componente real.
- Cambios: separa rueda firme, cable/funda íntegros, unión al cuadro sin daño visible, topes ya verificados y apoyo de funda. Declara el mismo apoyo estable y no indica sostener la bicicleta a mano mientras se pedalea. Solo ajusta el tensor y, si corresponde, asienta una funda fuera de su apoyo; no toca fijación de cable ni H/L/B.
- Disco: comprueba rueda, freno, fugas, deformación, holguras y montaje; declara el apoyo estable antes de girar la rueda y exige detenerse si pierde estabilidad. Centra únicamente con torque y secuencia aplicables. Distingue roce continuo de posible disco deformado y admite un segundo centrado acotado cuando todas las condiciones siguen confirmadas.

Los datos específicos no se universalizan. Nunca se asignan torque, presión, medida, compatibilidad, tolerancia o secuencia por apariencia o analogía.

## Fuentes editoriales

| Fuente | Uso vigente |
| --- | --- |
| [iFixit: cadena salida](https://www.ifixit.com/Guide/How+to+Fix+a+Slipped+Bicycle+Chain/37682) | Holgura, recolocación y giro manual. Se excluyen ajuste en marcha, acortamiento y unión de cadena. |
| [Park Tool: cámara y cubierta](https://www.parktool.com/en-us/blog/repair-help/tire-and-tube-removal-and-installation) | Desmontaje, inspección, prevención de pellizco, asiento e inflado. |
| [Park Tool: rueda](https://www.parktool.com/en-us/blog/repair-help/wheel-removal-and-installation) | Retirada/reinstalación específica, reconexión y comprobación; no accionar freno hidráulico sin disco. |
| [Park Tool: medidas y cámaras](https://www.parktool.com/en-us/blog/repair-help/tire-wheel-and-inner-tube-fit-standards) | Verificar medida y válvula; no inferir compatibilidad por apariencia. |
| [Schwalbe: presión](https://www.schwalbe.com/en/technology-faq/tire-pressure/) | Usar información aplicable y manómetro; no asignar presión universal. |
| [Schwalbe: rin y llanta](https://www.schwalbetires.com/technology-faq/tire-dimensions/) | Respetar información aplicable del rin y la cubierta. |
| [Park Tool: cambio trasero](https://www.parktool.com/en-us/blog/repair-help/rear-derailleur-adjustment) | Comprobaciones previas, dirección del tensor y ajuste acotado; no tocar H/L/B ni fijación de cable. |
| [Park Tool: disco hidráulico](https://www.parktool.com/en-us/blog/repair-help/hydraulic-disc-brake-alignment) | Descartar causas ajenas al centrado y alinear pinza; no adoptar torque genérico ni ajustar junto a una rueda girando. |

Las fuentes externas sustentan el contenido mecánico; no aportan imágenes a la aplicación. Los diagramas BiciFirme son originales y se usan para explicar el canal del rin/cámara, el brazo del cambio/cadena y la separación disco/pastillas.

## Gate editorial y físico

Los recorridos manuales realizados no cierran la evaluación mecánica. Las pruebas de software demuestran contrato y navegación, no éxito sobre una bicicleta real. Antes de considerar aprobación, aplicar el [protocolo de evaluación física](phase3-physical-evaluation.md), registrar las sesiones con la [plantilla](phase3-physical-results-template.md), resolver bloqueantes y completar revisión editorial. El estado general se mantiene en [project-review.md](project-review.md).
