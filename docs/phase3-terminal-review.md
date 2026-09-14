# Corrección terminal del piloto 0.3.1

Revisión limitada a los resultados terminales, sin promoción ni evaluación física. Los cuatro pilotos permanecen en **development**. No se modificaron maestro, ErgoMax, diagramas, mantenimiento, historial ni diseño visual.

`VisibleRepairOutcome` vuelve a contener únicamente `complete`, `temporary` y `stop`. `RepairOutcome.unresolved` permanece como defensa interna y produce `null` en la proyección visible: no se convierte en stop o temporary. Ningún nodo ni arista de los cuatro pilotos usa unresolved. Los pilotos tampoco usan temporary, porque ninguna ruta implementa una solución provisional real.

## Rutas que terminaban en unresolved

| Piloto | Rutas anteriores | Destino corregido |
| --- | --- | --- |
| Cadena | `identify/other`; `identify_help/no` | `stop`: no se identificó un sistema compatible y no es seguro intervenir con este procedimiento. |
| Cadena | `chain_position/no` | Nueva comprobación `chain_manual_check`: dos vueltas lentas a mano. Si se mantiene, pasa a prueba final; si salta o se sale, `stop`. |
| Cadena | `retry_check/no` | `stop`: salida o salto repetido; no es seguro circular ni seguir recolocando sin diagnosticar la causa. |
| Cámara | `identify/other`; `identify_help/no` | `stop`: no se confirmó cubierta con cámara, medida/válvula y montaje aplicables; no es seguro desmontar ni circular con pérdida de aire. |
| Cambios | `identify/other`; `identify_help/no` | `stop`: sistema o respuesta al cable sin identificar; no es seguro ajustar. |
| Cambios | `cable_check/no`; `limits_check/no` | `stop`: cable/funda no íntegros o topes críticos no comprobados. |
| Cambios | `next_cause/no`; `housing_check/no` | `stop`: el intento seguro se agotó y el cambio sigue sin responder; puede saltar bajo carga y no se tocan cable, topes ni patilla. |
| Disco | `identify/other`; `identify_help/no` | `stop`: pinza o fijación sin identificar; no es seguro aflojarla. |
| Disco | `rub_pattern/other` | `stop`: roce parcial o patrón incierto puede indicar disco deformado; no se endereza ni se continúa ajustando. |
| Disco | `retry_check/no` | `stop`: tras el único reintento no se confirmó separación y tacto normal en un sistema de freno. |

## Pruebas

La suite verifica que solo existen tres resultados visibles, que unresolved interno no se muestra, que ningún piloto termina o enlaza a unresolved, que temporary no se usa como sustituto, que un fallo no crítico de cadena abre la siguiente causa y que todos los hard stops siguen siendo irreversibles desde cada estado alcanzable.

Resultado: **214 pruebas aprobadas**; `flutter analyze --no-pub` sin incidencias y `git diff --check` sin errores de espacios. Registro: `mobile/build/terminal-review-tests.log`.
