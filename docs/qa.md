# QA interno RobMac

No existe certificación externa. Este documento registra controles internos y pendientes; una casilla pendiente nunca equivale a aprobada.

| Control | Método | Estado de esta fase |
| --- | --- | --- |
| Persistencia tras cerrar SQLite | Archivo real, cerrar y reabrir | Test automatizado |
| Migración 1 a 2 | Fixture de esquema anterior | Test automatizado |
| Integridad referencial | Referencia inexistente rechazada | Test automatizado |
| Hard stops | Cada bandera desde inicio, paso, completo, temporal y no resuelto; retroceso y mutación bloqueados | Test automatizado |
| Catálogos offline | Versiones, IDs, fuentes, referencias y rechazo de fixtures por defecto | Test automatizado |
| Registro desde Inicio | Widget test con SQLite | Test automatizado |
| Reparaciones, ramas y temporales | Grafos acíclicos, prueba final, restricciones y contexto | Test automatizado con fixtures |
| Compatibilidad e intercambio editorial | Par y alcance exactos, desconocido, referencias y transformador | Test automatizado sobre el maestro real development |
| Kit, historial, mantenimiento y backup | Flujos futuros | Pendiente |
| Notificaciones denegadas/reinicio | Dispositivo Android | Pendiente |
| Accesibilidad, lector y texto grande | Dispositivo Android | Pendiente |
| Funcionamiento en modo avión | Dispositivo Android | Pendiente |
| Release firmado/AAB | Clave del propietario | Pendiente |

Ejecutar `flutter analyze --no-pub`, `flutter test --no-pub` y `flutter build apk --debug --no-pub` desde mobile. La compilación no aprueba seguridad mecánica.

## Validación física pendiente

Realizar las pruebas con bicicleta inmóvil y entorno controlado. No provocar grietas, roturas de freno, daño estructural ni fallos de dirección. Escenarios sugeridos: cadena salida sin daño, cámara previamente pinchada desmontada, localización de pérdida de aire, inspección de roce existente, cambio desajustado en soporte y revisión de un accesorio no crítico flojo. Frenos/dirección requieren supervisión competente; no circular para reproducir un fallo peligroso.

| Fecha / responsable | Escenario / guía y versión | Bicicleta / componentes | Pasos | Esperado | Real | Aprobado / rechazado | Observaciones |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Pendiente | | | | | | | |

Antes de publicar: cerrar defectos críticos, verificar fuentes de datos críticos, completar cobertura funcional por categoría y registrar pruebas finales de las guías principales.

## Registro de Fase 1 — 2026-09-05

Flutter 3.47.2 / Dart 3.13.2. Análisis estático sin incidencias y 10 pruebas automatizadas aprobadas. Se generó APK debug de desarrollo. No se ejecutaron pruebas físicas, validación en teléfono ni AAB firmado. La inspección de diff no reportó errores de espacios.


## Registro de Fase 2 / base de Fase 3 — 2026-09-05

Análisis estático sin incidencias y **93 pruebas aprobadas**. Incluyen validación estricta de los dos esquemas, referencias, ciclos y rutas, tipos de resultado, prueba final, hard stops desde todos los estados de resultado, ramas ruta/taller, filtros de bicicleta/contexto, búsqueda por sinónimos, actualización progresiva sin perder otros datos e interacción de invitado desde búsqueda hasta bloqueo rojo.

Se verificaron las herramientas CLI sobre el catálogo aprobado vacío, los fixtures con habilitación explícita y el transformador desde el ejemplo de hojas normalizadas. El transformador generó un archivo de revisión en build; no alteró los assets.

Los fixtures son datos de desarrollo y no prueban reparaciones reales. Continúan pendientes las pruebas físicas, el catálogo técnico real, la revisión editorial, pruebas en un teléfono y un AAB de publicación firmado.

Compilación de esta entrega: APK debug y APK release generados correctamente. Release emitió advertencias no bloqueantes sobre fuente Cupertino no incluida y opciones Java 8 en dependencias; MaterialIcons se empaquetó. No se verificó un AAB firmado ni se ejecutó la app en un teléfono. Estas compilaciones no habilitan contenido de desarrollo fuera de debug y no equivalen a aprobación de publicación.

## Endurecimiento del maestro — 2026-09-06

Contrato runtime 2, maestro editorial 1 / contenido 0.1.0 development. **148 pruebas Flutter/Dart y 8 pruebas Python aprobadas**. El test de integración lee el XLSX real, verifica SHA-256 y conteos (59/11/21/61/52/409/20/11, más 8 relaciones de consumibles) y compara exactamente el JSON generado versionado. Se prueban duplicados en todas las colecciones, referencias, endpoints ambiguos/de tipo incorrecto, versiones, columnas, critical, unidades, nulos y promoción prohibida a approved. El lector rechaza fórmulas y errores de Excel sobre copias temporales.

Las pruebas de motor comprueban vocabulario nuevo de identify con persistencia y reutilización, invitado, riesgo/tiempo, ausencia de transitividad y de expansión por familia, tres resultados visibles y rechazo de degradación de cada bandera roja a complete/temporary/unresolved incluso sin safetyFocus. Permanecen las pruebas de irreversibilidad desde resultados anteriores y de prueba final obligatoria.

El maestro se conserva intacto fuera de assets. Todas las columnas tienen representación; la restricción Comp ErgoMax/C260 permanece como nota editorial hasta contar con una fila explícita en COMPATIBILITIES. No se crearon proxies ni se completaron especificaciones vacías.

Verificación final: `flutter analyze --no-pub` sin incidencias, validadores de ambos paquetes correctos y APK debug/release generados con el código final. Inspección del APK release: no contiene XLSX, Python ni directorios master/generated; el catálogo approved sigue vacío. Release conserva el aviso no bloqueante de fuente Cupertino ausente observado anteriormente. No se realizaron pruebas físicas ni se generó AAB de publicación. `git diff --check` sin errores; no se realizó commit ni push.
