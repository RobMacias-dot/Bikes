# Android: publicación pendiente

Identidad: BiciFirme, `com.robmac.bicifirme`. Nombre previsto de tienda: BiciFirme – Repara tu bici. Versión actual 0.1.0+1 de desarrollo. El icono todavía es provisional.

La configuración no asigna la firma debug a release. Para firmar, el propietario debe crear una clave de carga y guardar fuera del repositorio la clave y sus contraseñas. `mobile/android/key.properties` está ignorado por git y admite storeFile (ruta absoluta con barras /), storePassword, keyAlias y keyPassword. No pegar valores reales en documentación ni historial de comandos.

Con credenciales locales configuradas:

```powershell
cd mobile
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Guardar los símbolos en un archivo privado asociado a la versión. El bundle estará en `build/app/outputs/bundle/release/app-release.aab`. Sin key.properties la configuración queda sin firma de producción; no distribuir el resultado. R8 y reducción de recursos están activados para release, pendientes de prueba con AAB firmado.

compileSdk y targetSdk siguen los valores del SDK Flutter instalado. Confirmar las exigencias vigentes de Google Play y los valores efectivos en el AAB justo antes de publicar; esta fase no certifica su cumplimiento.

Pendientes: icono original/adaptativo, QA en teléfonos, firma real, verificación del bundle, ficha/capturas, privacidad publicada, formularios de seguridad de datos y clasificación, pruebas internas de Play y auditoría de permisos/dependencias. No subir a Play ni generar claves sin coordinar con el propietario.

## Comprobación de conocimiento antes de release

Ejecutar `dart run tool/validate_knowledge.dart assets/knowledge/approved` desde mobile, sin habilitar fixtures. La edición aprobada actualmente está vacía: permite comprobar la compilación, pero no constituye un producto publicable. Nunca promover development cambiando únicamente status; los parsers rechazan sus IDs de fixture.

El laboratorio solo se habilita con kDebugMode. Profile/release rechazan la carga de development y el motor requiere autorización de desarrollo para iniciar una sesión con fixtures. Los archivos de prueba pueden seguir empaquetados como assets; este control impide ofrecerlos como guías aprobadas, no intenta ocultar el contenido del APK.
