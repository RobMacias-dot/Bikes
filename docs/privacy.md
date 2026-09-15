# Privacidad — borrador para revisión antes de publicación

BiciFirme funciona sin cuentas, backend, anuncios, analítica ni telemetría. Las bicicletas y sus datos se guardan localmente en el dispositivo. No se envían al desarrollador.

La versión actual no ofrece flujos de compartir, respaldo ni correo de comentarios. No escribas información personal o confidencial en las notas si no deseas conservarla en el dispositivo.

Si se implementan, los respaldos serán archivos controlados por el usuario y cualquier acción de compartir o abrir correo requerirá una acción explícita con contenido revisable antes del envío. Estas funciones siguen pendientes.

Contacto previsto: robmacsoftware@gmail.com. Este texto debe actualizarse para describir exactamente la versión que se publique, incluyendo el comportamiento efectivo del respaldo Android y las funciones añadidas.

## Hechos técnicos para Data Safety

Auditoría del build release del 14 de septiembre de 2026:

| Área | Comportamiento demostrado |
| --- | --- |
| Datos introducidos | Nombre libre de la bicicleta; tipo; frenos; neumático; transmisión; marca/modelo/año; rueda; familias; uso y notas opcionales. La persona puede evitar el perfil y usar modo invitado. |
| Almacenamiento | SQLite privado de la aplicación (`bicifirme.sqlite`) en el directorio de soporte de la app. No existe almacenamiento compartido, backup/exportación ni sincronización. `android:allowBackup="false"`. |
| Transmisión | No hay cliente HTTP, socket, backend, analítica, telemetría, crash reporting, publicidad ni SDK de atribución. El manifest release no solicita `INTERNET`. |
| Compartir | No existe flujo de compartir ni selector de documentos/correo. Se retiraron `share_plus`, `pdf` y `printing` por no tener uso en V1. |
| Permisos sensibles | Ninguno: sin ubicación, cámara, micrófono, contactos, calendario, SMS/teléfono, almacenamiento, Bluetooth, actividad física o notificaciones. |
| Identificadores/dispositivo | El código no lee identificador publicitario, Android ID, IMEI, número de serie, IP ni información de hardware. |
| Dependencias runtime relevantes | Drift y `sqlite3_flutter_libs` persisten localmente; `path_provider` obtiene el directorio privado; Riverpod y GoRouter gestionan estado/navegación. JNI/AndroidX son transitivas de esas funciones locales. Ninguna dependencia runtime implementa envío de datos. |
| Manifest fusionado | Solo usa un permiso propio con protección `signature`, generado por AndroidX para receptores no exportados. No concede acceso a datos del dispositivo. `ACTION_PROCESS_TEXT` es una consulta de visibilidad, no un permiso ni un flujo de compartir implementado. |

Los manifests debug/profile declaran Internet exclusivamente para herramientas Flutter. Esta diferencia no debe trasladarse a la declaración del artefacto release. Estas observaciones sirven como evidencia técnica para completar los formularios; la respuesta final y la política publicada deben revisarse contra el AAB exacto que se suba y las preguntas vigentes de Play Console.
