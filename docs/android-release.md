# Android: preparación técnica verificada; publicación pendiente

Identidad permanente auditada: `com.robmac.bicifirme`. Nombre visible Android: **BiciFirme – Repara tu bici**. La versión 0.1.0+1 (`versionName` 0.1.0, `versionCode` 1) es coherente entre pubspec, Gradle y el manifest fusionado, pero continúa siendo una versión previa al release candidate. No cambiar el applicationId al crear la ficha de Play.

Configuración verificada el 14 de septiembre de 2026: Flutter 3.47.2, Dart 3.13.2, compileSdk 36, targetSdk 36, minSdk 24, AGP 9.3.0, Gradle 9.5.0 y Java/Kotlin JVM 17. R8 y reducción de recursos están habilitados. El icono Flutter fue sustituido por un activo original con variantes legacy, round y adaptive; Android 12+ y versiones anteriores tienen splash propio en claro y oscuro.

La configuración no asigna la firma debug a release. Para firmar, el propietario debe crear una **clave de carga** y guardar fuera del repositorio la clave y sus contraseñas. `mobile/android/key.properties` está ignorado por Git y admite `storeFile` (ruta absoluta con barras `/`), `storePassword`, `keyAlias` y `keyPassword`; si el archivo existe pero falta un valor, Gradle falla expresamente. No pegar valores reales en documentación ni historial de comandos. Esta separación es compatible con Play App Signing: Google administra la clave de firma de la app y cada AAB se firma localmente con la clave de carga.

Con credenciales locales configuradas:

```powershell
cd mobile
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Guardar los símbolos en un archivo privado asociado a la versión. El bundle estará en `build/app/outputs/bundle/release/app-release.aab`. Sin `key.properties` la configuración queda sin firma de producción; no distribuir el resultado.

El AAB de comprobación sin firma se construyó correctamente con R8 el 14 de septiembre de 2026: 58,662,895 bytes (55.95 MiB), SHA-256 `19dc14a642a6f3ba25c75d4cdc0963c3de0a76c503f44e0c13412a1f90bbfb44`. Este hash debe actualizarse después de cualquier reconstrucción. La verificación de entradas confirma que no contiene firma; es evidencia de compilación, no un artefacto distribuible ni un RC.

Flutter emite una advertencia de tree-shaking porque detecta la familia opcional `CupertinoIcons` sin su fuente. La app no importa ni usa `CupertinoIcons`, el delegado de localización Cupertino sí es necesario para `es`, y no se observaron iconos faltantes en release. Se clasifica como higiene de build no bloqueante; no añadir una dependencia sin uso solo para ocultarla.

El manifest release fusionado declara solo el permiso interno con protección `signature` `com.robmac.bicifirme.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. No solicita permisos Android de Internet, ubicación, cámara, micrófono, almacenamiento, contactos, calendario, Bluetooth, identificadores publicitarios ni notificaciones. La consulta `ACTION_PROCESS_TEXT` limita visibilidad de paquetes y no es un permiso. Debug y profile sí declaran Internet para las herramientas Flutter; release no lo hereda.

Pendientes Android/Play: clave de carga del propietario, AAB firmado, alta en Play App Signing, verificación del bundle firmado, QA en teléfonos Android físicos, prueba interna/cerrada, ficha y capturas, URL pública de privacidad, Data Safety, clasificación de contenido y demás declaraciones de Play Console. No subir a Play ni generar claves sin coordinar con el propietario.

## Comprobación de conocimiento antes de release

Ejecutar `dart run tool/validate_knowledge.dart assets/knowledge/approved` desde mobile, sin habilitar fixtures. La edición aprobada actualmente está vacía: permite comprobar la compilación, pero no constituye un producto publicable. Nunca promover development cambiando únicamente status; los parsers rechazan sus IDs de fixture.

El laboratorio solo se habilita con `kDebugMode`. Profile/release rechazan la carga de development y el motor requiere autorización de desarrollo para iniciar una sesión con fixtures. Los fixtures sintéticos de `assets/knowledge/development` ya no se empaquetan. El paquete piloto permanece como asset para el laboratorio debug, pero no tiene ruta de release y dos pruebas independientes verifican que la política de producción lo rechaza y que la UI no muestra laboratorio ni marcas `[PRUEBA]`.
