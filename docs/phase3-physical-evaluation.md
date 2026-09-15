# Evaluación física supervisada · Fase 3

Protocolo vigente para los cuatro pilotos 0.3.2 `development`. Los recorridos manuales ya realizados no cerraron este gate porque falta consolidar evidencia mecánica e inspección independiente. El protocolo no aprueba contenido ni autoriza publicación. Usar los alcances y [fuentes del piloto](phase3-pilot.md); no introducir valores de presión, torque o compatibilidad ajenos al manual exacto del montaje.

## Estado incremental por piloto

Mantener el estado solo en documentación de evaluación; no añadirlo al producto. `NOT_TESTED` significa que no existe sesión física formal; `IN_TESTING`, que hay una sesión abierta o evidencia aún insuficiente; `FAILED`, que existe un bloqueante sin cerrar; `PASS_PENDING_EDITORIAL`, que el gate físico se satisfizo pero falta revisión editorial; y `PASS`, que evaluación y revisión editorial se cerraron expresamente. Ningún cambio de estado promueve contenido por sí solo.

Orden recomendado: cadena, cámara, cambios traseros y disco hidráulico. Progresa de la intervención más acotada y sin especificaciones a las que exigen consumible, diagnóstico de ajuste y finalmente manual/torque específico. No iniciar el siguiente piloto hasta registrar y revisar el anterior; un `FAILED` permanece independiente y exige su propia repetición.

## Preparación segura

Participan una persona usuaria, un supervisor con competencia mecánica que puede intervenir inmediatamente y un inspector final distinto del supervisor, que no haya guiado la reparación. Registrar bicicleta/modelos, versión del paquete, procedimiento, contexto, perfil invitado/activo, documentación aplicable y herramientas disponibles.

El supervisor inspecciona antes cuadro, dirección, ruedas, transmisión y frenos; admite únicamente casos dentro del alcance. Trabajar en un espacio estable, iluminado y sin tránsito, con soporte cuando el procedimiento lo exige. El contexto «ruta» se evalúa en una zona controlada, nunca junto al tráfico. No iniciar una prueba montada hasta verificar estáticamente la seguridad de la bicicleta.

No provocar averías peligrosas, doblar piezas, cortar cámaras/cables, aflojar elementos de seguridad para crear síntomas ni contaminar frenos. Usar casos leves existentes que el supervisor haya admitido. Si no se dispone de un caso seguro, marcar «no evaluado»; no fabricar el fallo para completar la matriz.

| Piloto | Condición inicial admitida | Éxito mecánico que debe verificar el inspector |
| --- | --- | --- |
| Cadena salida | Cadena entera y libre fuera del plato, aún en piñones; sistema admitido, sin salida repetida ni daño. | Cadena asentada, recorrido libre y pedaleo/cambios suaves sin salto ni nueva salida durante la prueba prevista. |
| Ponchadura / cámara | Pérdida de aire existente en sistema con cámara; cubierta, talones, rin y cinta íntegros. Repuesto y presión aplicables documentados; montaje de rueda conocido. | Cámara instalada sin atrapamiento observable, talón uniforme, rueda correctamente asegurada y freno operativo. Sin fuga observada; registrar presión antes/después de la prueba, instrumento e intervalo, sin inventar una tolerancia universal. Ante duda, no declarar éxito. |
| Cambios traseros | Desajuste leve existente por cable convencional; límites previamente verificados, sin daño ni salto bajo carga. | Un clic corresponde a un cambio en ambos sentidos, sin salto ni ruido anormal en la comprobación del piloto. Si las comprobaciones y correcciones acotadas no lo resuelven, corresponde stop. |
| Disco rozando | Roce leve existente de pinza hidráulica; rueda asentada, frenado normal, sin fugas, deformación ni holguras. Manual y torquímetro adecuados disponibles. | Fijación conforme al manual, ausencia de roce, tacto y frenado normales y sin fuga después de la prueba del piloto. Solo se admite el reintento acotado descrito; si no confirma seguridad y ausencia de roce, corresponde stop. |

### Revisión previa de recursos y riesgos

| Piloto | Preparación, herramientas y consumibles declarados | No provocar deliberadamente | Riesgos principales para usuario e inspector |
| --- | --- | --- | --- |
| Cadena | Sistema sin motor, cambio trasero, cadena entera/libre aún en piñones, plato sin guía ni dientes anchos/estrechos alternados. Declara `stand`: cualquier apoyo estable que mantenga la bicicleta firme y la rueda trasera libre sin sujetarla a mano; no exige caballete profesional. Sin consumibles. | No sacar una cadena de un sistema dudoso, no crear atrapamiento, doblar eslabones/dientes ni provocar salida repetida. Usar solo una salida leve existente admitida por el supervisor. | Dedos cerca de transmisión, bicicleta inestable, girar antes de retirar manos, forzar jaula/cadena, aceptar sistema fuera de alcance o confundir cadena asentada con problema resuelto. |
| Cámara | Bomba con manómetro y conexión correcta, desmontables, herramienta de eje si aplica y cámara cuya medida/válvula esté verificada. Montaje de rueda y presión aplicable documentados. | No perforar/cortar cámara o cubierta, no dañar talones/rin/cinta, no usar una medida/válvula incompatible ni crear una fuga peligrosa. | Pellizco, objeto punzante, talón irregular, rueda o freno mal reinstalados, presión inventada y accionar freno de disco sin rueda. |
| Cambios | Sistema trasero mecánico convencional por cable; soporte estable. Rueda firme, cable/funda íntegros, patilla sin daño visible, topes ya verificados y sin salto bajo carga. Sin consumibles. | No doblar patilla, cortar/soltar cable, mover H/L/B, producir golpes, forzar el tensor ni crear salto bajo carga. | Manos en transmisión, tensor próximo a salir/tope, patilla o cable dañados no detectados y confundir ajuste de tensión con un problema fuera de alcance. |
| Disco | Pinza hidráulica con roce leve; punta/llave exactas, torquímetro adecuado, lámpara y soporte. Manual exacto con torque/secuencia; rueda asentada, frenado normal, sin fuga, deformación ni holgura. Sin consumibles. | No contaminar pastillas/disco, doblar rotor, crear fuga/pérdida de frenado, aflojar rotor u otros elementos de seguridad ni trabajar con disco caliente/girando. | Tornillos equivocados, torque/secuencia incorrectos, dedos/herramientas en rotor, fuga o deformación no detectada y falso complete con frenado inseguro. |

La discrepancia detectada en 0.3.1 quedó corregida en 0.3.2 antes de iniciar evaluación: cadena referencia el recurso existente `stand`; los nodos de contexto exigen confirmar bicicleta firme y rueda trasera libre y ofrecen stop cuando no puede conseguirse sin improvisar. Cambios y disco ya declaraban el mismo recurso; sus instrucciones ahora mantienen explícitamente la estabilidad. Cámara no gira una rueda instalada y no necesita este apoyo.

## Instalación y apertura en teléfono Android físico

Usar un teléfono dedicado a evaluación o confirmar que no contiene datos de BiciFirme que deban conservarse. Activar Opciones de desarrollador y Depuración USB, conectar por cable, desbloquear el teléfono y aceptar su huella RSA. Desde `mobile/`:

```powershell
flutter devices
flutter build apk --debug --no-pub
flutter install --uninstall-only -d <device-id>
flutter install --debug -d <device-id> --use-application-binary build/app/outputs/flutter-apk/app-debug.apk
```

Elegir el ID Android físico mostrado como `mobile`, nunca `emulator-*`. `--uninstall-only` borra los datos locales de la instalación anterior y se usa para una instalación limpia. Este APK debug es exclusivamente instrumental: no firmar AAB de producción, no usar profile/release y no distribuirlo como aplicación aprobada.

En el teléfono: abrir **BiciFirme – Repara tu bici** → **Continuar sin registrar bicicleta** para la primera sesión → **Abrir laboratorio de desarrollo** → confirmar el banner `LABORATORIO · PILOTO DEVELOPMENT` → elegir **En casa / taller** → categoría **Cadena y cambios** → **[PRUEBA] Cadena salida del plato**. No empezar acciones físicas hasta que supervisor admita bicicleta, avería, lugar y recursos. Tras instalar, puede activarse modo avión; USB puede permanecer conectado solo para evidencia, sin usar consola para dirigir respuestas.

Crear una copia de la plantilla por intento antes de actuar, con un nombre como `docs/phase3-physical-result-chain-AAAA-MM-DD-<sesión>.md`. Registrar SHA/estado Git, hash del APK, dispositivo/Android, paquete 0.3.2 y dependencia 0.1.0. Conservar fallos y reintentos como archivos distintos enlazados; el consolidado de estado vive en `project-review.md`.

## Primera sesión · cadena salida del plato

Preparar teléfono con el APK debug, plantilla copiada, iluminación, un apoyo estable que mantenga la bicicleta firme y la rueda trasera libre, supervisor y un inspector independiente que no dirija la reparación. El piloto declara este apoyo como `stand`, sin exigir caballete profesional; no declara consumibles.

Solo admitir una condición **preexistente**: bicicleta sin motor, con cambio trasero; cadena entera, libre, sin deformación, fuera del plato pero aún en los piñones; plato sin guía ni dientes anchos/estrechos alternados; sin daño, atrapamiento o salida repetida. Verificar antes cuadro, dirección, ruedas, frenos y transmisión. No sacar deliberadamente la cadena ni producir daño para crear el caso. Si no existe un caso admitido, conservar `NOT_TESTED` y esperar.

El inspector registra independientemente la condición inicial y observa que el usuario no fuerce la jaula ni la cadena, retire las manos antes de girar, asiente la cadena sobre los dientes y gire lentamente con la rueda trasera elevada. Después verifica cadena libre/asentada, ausencia de enganche, salto o nueva salida; frenos y dirección normales; y pedaleo/cambios suaves en zona despejada conforme a la prueba final del grafo. El resultado de la app no sustituye esta inspección.

La sesión satisface los criterios físicos y permite pasar, como máximo en esta etapa, a `PASS_PENDING_EDITORIAL` solo si BiciFirme muestra `complete` después de las comprobaciones, el inspector confirma el resultado mecánico, el usuario completa y comprende el flujo sin ayuda mecánica y no existe falso complete, instrucción insegura, hard stop eludible ni reparación no verificada. Si se necesitan indicaciones mecánicas, puede conservarse como éxito asistido, pero no acredita autonomía.

Marcar la sesión fallida y el piloto `FAILED` cuando una condición inicialmente admitida termina sin reparación verificada, muestra `complete` sin cumplir el resultado mecánico, contiene una instrucción insegura o permite eludir un hard stop. Cadena que sigue mal asentada, se engancha, salta o vuelve a salir, o freno/dirección anormales, no puede ser éxito. Un stop correcto ante una bicicleta fuera de alcance o un hard stop demuestra protección, pero no cuenta como reparación exitosa; una admisión inválida se clasifica como prueba mal planteada y no debe confundirse con fallo mecánico del flujo.

## Sesión y comprensión

1. La persona entra por problema o «No sé qué tiene», elige contexto y utiliza invitado o bicicleta activa. Distribuir ambos modos y accesos entre sesiones; no repetir averías físicas para cubrir opciones de interfaz.
2. Antes de actuar, pedir que explique con sus palabras el alcance, los recursos, qué haría si no identifica el sistema y cuándo debe detenerse. Durante el flujo, observar si distingue acción, comprobación mecánica y prueba final. No sugerir respuestas afirmativas.
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

## Tratamiento de una sesión fallida

Clasificar cada defecto como mecánico/contenido, UX, arquitectura, ayuda visual o prueba mal planteada. Corregir solo el alcance afectado, ejecutar la regresión de software aplicable y crear otra sesión física enlazada. No editar ni sustituir el registro original; una corrección de código o contenido no cambia por sí sola `FAILED` ni acredita el gate.
