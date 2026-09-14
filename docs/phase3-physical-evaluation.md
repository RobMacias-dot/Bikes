# Evaluación física supervisada · Fase 3

Protocolo pendiente de ejecución para los cuatro pilotos `development`. No aprueba contenido ni autoriza publicación. Usar los alcances y [fuentes del piloto](phase3-pilot.md); no introducir valores de presión, torque o compatibilidad ajenos al manual exacto del montaje.

## Preparación segura

Participan una persona usuaria, un supervisor con competencia mecánica que puede intervenir inmediatamente y un inspector final distinto del supervisor, que no haya guiado la reparación. Registrar bicicleta/modelos, versión del paquete, procedimiento, contexto, perfil invitado/activo, documentación aplicable y herramientas disponibles.

El supervisor inspecciona antes cuadro, dirección, ruedas, transmisión y frenos; admite únicamente casos dentro del alcance. Trabajar en un espacio estable, iluminado y sin tránsito, con soporte cuando el procedimiento lo exige. El contexto «ruta» se evalúa en una zona controlada, nunca junto al tráfico. No iniciar una prueba montada hasta verificar estáticamente la seguridad de la bicicleta.

No provocar averías peligrosas, doblar piezas, cortar cámaras/cables, aflojar elementos de seguridad para crear síntomas ni contaminar frenos. Usar casos leves existentes que el supervisor haya admitido. Si no se dispone de un caso seguro, marcar «no evaluado»; no fabricar el fallo para completar la matriz.

| Piloto | Condición inicial admitida | Éxito mecánico que debe verificar el inspector |
| --- | --- | --- |
| Cadena salida | Cadena entera y libre fuera del plato, aún en piñones; sistema admitido, sin salida repetida ni daño. | Cadena asentada, recorrido libre y pedaleo/cambios suaves sin salto ni nueva salida durante la prueba prevista. |
| Ponchadura / cámara | Pérdida de aire existente en sistema con cámara; cubierta, talones, rin y cinta íntegros. Repuesto y presión aplicables documentados; montaje de rueda conocido. | Cámara instalada sin atrapamiento observable, talón uniforme, rueda correctamente asegurada y freno operativo. Sin fuga observada; registrar presión antes/después de la prueba, instrumento e intervalo, sin inventar una tolerancia universal. Ante duda, no declarar éxito. |
| Indexado trasero | Desajuste leve existente por cable convencional; límites previamente verificados, sin daño ni salto bajo carga. | Un clic corresponde a un cambio en ambos sentidos, sin salto ni ruido anormal en la comprobación del piloto. Si el intento acotado falla, corresponde stop. |
| Disco rozando | Roce leve existente de pinza hidráulica; rueda asentada, frenado normal, sin fugas, deformación ni holguras. Manual y torquímetro adecuados disponibles. | Fijación conforme al manual, ausencia de roce, tacto y frenado normales y sin fuga después de la prueba del piloto. Si el centrado inicial falla, corresponde stop. |

## Sesión y comprensión

1. La persona entra por problema o «No sé qué tiene», elige contexto y utiliza invitado o bicicleta activa. Distribuir ambos modos y accesos entre sesiones; no repetir averías físicas para cubrir opciones de interfaz.
2. Antes de actuar, pedir que explique con sus palabras el alcance, los recursos, qué haría si no identifica el sistema y cuándo debe detenerse. Durante el flujo, observar si distingue acción, comprobación, «¿funcionó?» y prueba final. No sugerir respuestas afirmativas.
3. Registrar por nodo: duda/error, tiempo, intento de omitir comprobación y ayuda requerida: ninguna, explicación verbal, demostración o intervención física. El supervisor interrumpe inmediatamente cualquier acción insegura; nunca retiene ayuda para medir autonomía.
4. Ejecutar solo las acciones y prueba final del piloto. La prueba montada será suave y en zona despejada, tras revisión estática del supervisor. Si faltan condiciones, documentación o recursos, terminar en stop sin improvisar.
5. Pedir que explique el resultado: complete significa reparación lograda dentro del alcance y prueba aprobada, también en ruta; no garantiza resolver problemas ajenos ni descarta recurrencia futura. Estos pilotos no ofrecen temporary. Comprobar además, sin intervención física, que el mismo relato y respuestas en ruta/taller producen el mismo resultado.

## Hard stops

Evaluar las cuatro señales (daño estructural, pérdida efectiva de frenado, dirección dañada y pieza crítica rota) mediante tarjetas de escenario o relato, con bicicleta inmóvil y sin producir daño real. En sesiones de prueba separadas, reportarlas al inicio, durante el flujo y después de un resultado; intentar volver o continuar. Debe mostrarse stop y mantenerse bloqueada esa sesión. Registrar si la persona deja de intervenir y entiende que no debe circular. No abrir otra sesión para eludir una señal real.

Si aparece una señal real, el supervisor suspende toda prueba, inmoviliza la bicicleta para evaluación profesional y registra el incidente. Una parada correcta cuenta como acierto de seguridad, no como reparación completada.

## Inspección independiente y registro

El inspector final revisa los criterios de la tabla y las fijaciones/funciones afectadas conforme a los manuales, sin basarse en el color o resultado de la app. Registrar su dictamen separado del resultado mostrado: coincide / no coincide / no verificable, evidencia, ayuda recibida y cualquier intervención posterior. Si detecta un problema, no devolver la bicicleta al uso hasta resolverlo y verificarla; no reescribir retrospectivamente el intento como exitoso.

Una sesión demuestra resolución autónoma solo si el éxito mecánico se confirma independientemente, la persona comprende las decisiones y no necesitó ayuda mecánica. Un éxito con ayuda se registra como asistido. Cualquier complete sin reparación verificada, omisión de seguridad o bloqueo eludible impide dar por satisfactoria esa sesión y requiere corregir/repetir el caso. Consolidar hallazgos de los cuatro pilotos antes de decidir otra revisión editorial; mantener `development` durante toda esta evaluación.

Usar una copia de la [plantilla de resultados](phase3-physical-results-template.md) por sesión, incluidas sesiones asistidas, interrumpidas y escenarios de hard stops. No reemplazar resultados fallidos por los de un reintento; vincular ambas sesiones.

## Gate de evaluación por piloto

Aplicar por separado a cadena, cámara, indexado y disco; la evidencia de uno no sustituye la de otro. Para superar el gate, cada piloto requiere:

- Al menos un éxito mecánico verificado por el inspector independiente, con evidencia y sesión identificadas.
- Al menos una ejecución sin ayuda mecánica. Para contar como resolución autónoma, esa ejecución debe además resolver el problema, pasar la verificación independiente y demostrar comprensión del usuario. Una ejecución fallida o una parada sin ayuda no acredita resolución autónoma. La misma sesión puede satisfacer ambos mínimos.
- Ausencia de bloqueantes: cualquier falso `complete`, instrucción insegura, hard stop eludible o reparación no verificada impide aprobar ese piloto. Un éxito posterior no borra el hallazgo: requiere corrección, nueva evaluación y cierre documentado del bloqueante antes de reconsiderar el gate. Una parada correcta sin reparación pretendida no es una reparación no verificada.

La ayuda mecánica incluye explicación verbal que indique qué decisión o acción mecánica realizar, demostración e intervención física. Registrar aparte la ayuda para manejar la interfaz. La supervisión y la inspección independiente por sí solas no son ayuda mecánica; cualquier corrección durante ellas sí debe registrarse. Nunca omitir ayuda necesaria por intentar cumplir el gate.

Los éxitos asistidos se conservan como evidencia de resultado mecánico, pero no cuentan como resolución autónoma. Registrar por piloto las sesiones que sustentan cada mínimo, los bloqueantes y el dictamen: pendiente / bloqueado / gate de evaluación satisfecho. Superar este gate no cambia el estado `development` ni constituye promoción a `approved`.
