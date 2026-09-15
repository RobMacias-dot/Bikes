# QA de BiciFirme

Controles vigentes para desarrollo. No existe certificación externa y una prueba automatizada no acredita seguridad mecánica.

## Estado actual

| Área | Evidencia | Estado |
| --- | --- | --- |
| Persistencia y migración SQLite | Archivo real, cierre/reapertura y migración 1→2 | Automatizado |
| Integridad de conocimiento | Versiones, IDs, referencias, estados, ramas, ciclos y fuentes | Automatizado |
| Maestro 0.1.0 | SHA-256, conteos, transformación y comparación con JSON generado | Automatizado; contenido development |
| Sesión de reparación | Prueba final, continuidad no crítica, contexto y hard stops irreversibles | Automatizado |
| Resultados visibles | Solo complete, temporary y stop; unresolved interno sin representación | Automatizado |
| Pilotos 0.3.2 | Todos los recorridos invitado/activo × ruta/taller | Automatizado; contenido development |
| Ayudas visuales | Renderizado y capturas de tres diagramas offline | Automatizado y revisión visual de capturas |
| Evaluación física/mecánica | Protocolo por piloto e inspección independiente | No cerrada |
| Texto 150%, pantalla 720×1280 y modo oscuro | Emulador Pixel 7, scroll hasta todas las acciones | Verificado; falta lector y dispositivos reales |
| Funcionamiento sin red | Release en emulador con Wi-Fi y datos desactivados | Arranque, garaje, diagnóstico y reapertura verificados; falta dispositivo real |
| Kit, historial, mantenimiento, notificaciones y backup | Flujos de producto | No implementados |
| AAB release | Build R8 sin firma, manifest y tamaño inspeccionados | Compila; firma de producción y Play pendientes |

La regresión completa del 14 de septiembre de 2026 aprobó **218 pruebas**. `flutter analyze --no-pub` terminó sin incidencias. Los cuatro pilotos no contienen nodos/aristas unresolved ni resultados temporary. Las pruebas de política fuerzan que el repositorio rechace development y que la pantalla aprobada no ofrezca laboratorio, fixtures ni marcas `[PRUEBA]`. Dos pruebas adicionales verifican que todo piloto que gira una rueda libre declare `stand` y que cadena comunique, antes de actuar, el apoyo no profesional, la estabilidad y la salida segura.

Se instaló limpiamente en un emulador Pixel 7 un APK compilado en modo release y firmado solo con la clave debug estándar para QA local. Con Wi-Fi y datos desactivados arrancó en frío, abrió garaje y diagnóstico, no mostró laboratorio y conservó una bicicleta tras `force-stop` y reapertura. También se comprobó modo oscuro, texto 150% y 720×1280 sin overflow; el inicio conservó desplazamiento hasta todas las acciones. Esta prueba no convierte la firma debug de QA en firma distribuible ni sustituye la matriz de dispositivos físicos, TalkBack o evaluación mecánica.

## Comandos de desarrollo

Desde `mobile/`:

```powershell
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
dart run tool/validate_knowledge.dart assets/knowledge/approved
dart run tool/validate_knowledge.dart assets/knowledge/development --development
dart run tool/validate_knowledge.dart assets/knowledge/pilot --development
```

Desde la raíz, para el lector del maestro:

```powershell
python -m unittest discover -s tools -p test_xlsx_master.py -v
```

Definir `BICIFIRME_PYTHON` para las pruebas Flutter del importador si Python no está en PATH. La compilación debug/release verifica integración del binario, pero no aprueba contenido, mecánica ni distribución.

## Criterios que deben permanecer cubiertos

- La edición approved no acepta IDs o contenido development ni hace fallback a fixtures.
- Complete solo es alcanzable después de una prueba final aprobada.
- Temporary requiere una solución provisional real y restricciones; no sustituye «no resuelto».
- Un fallo no crítico puede abrir otra causa segura dentro del mismo procedimiento.
- Cada hard stop domina resultados anteriores y bloquea avance y retroceso.
- Ruta y taller con las mismas respuestas mecánicas producen el mismo resultado.
- Ausencia de compatibilidad devuelve unknown; no existe transitividad ni expansión por familia.
- El importador no modifica el maestro, no inventa unidades, alcances o valores y rechaza promoción silenciosa.
- Los diagramas son offline, originales, opcionales y mantienen alternativa textual.

## Validación física

Usar el [protocolo de Fase 3](phase3-physical-evaluation.md) y una [plantilla por sesión](phase3-physical-results-template.md). Mantener separados el resultado mostrado, el resultado mecánico del inspector y la ayuda recibida. No cerrar Fase 3 mientras algún piloto carezca de evidencia suficiente o tenga bloqueantes abiertos.

La instalación para este gate debe ser un APK **debug** limpio en un teléfono Android físico, mediante el procedimiento exacto del protocolo. El laboratorio no se abre en release y no se debilita `kDebugMode`. Un emulador puede apoyar regresión de software, pero nunca cuenta como evidencia mecánica ni como ejecución autónoma física.

El estado de gates y deudas se mantiene en [project-review.md](project-review.md).
