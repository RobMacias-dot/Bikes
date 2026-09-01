# Bike Expert — aplicación móvil

Aplicación Flutter offline-first para orientar el diagnóstico inicial de problemas de bicicletas. La fuente de verdad es un motor determinista local; la app no requiere cuenta, conexión a internet ni servicios externos.

## Funcionalidad actual

- Flujo de diagnóstico en español con Material 3 y temas claro/oscuro.
- Triaje de banderas rojas que fuerza `NO UTILIZAR` cuando corresponde.
- Reglas auditables, estimaciones Bayes orientativas, facilidad Mamdani y encadenamiento hacia atrás limitado.
- Garaje local para bicicletas.
- Catálogo de conocimiento versionado en `assets/knowledge/v1/catalog.json`.
- Resumen, portapapeles, PDF, guardado local y compartir mediante el selector nativo del sistema.

La aplicación nunca confirma la seguridad física de una bicicleta, autoriza reparaciones peligrosas ni infiere compatibilidad solamente a partir de una marca.

## Requisitos

- Flutter estable 3.41.9 o posterior compatible.
- Dart 3.11.5.
- Android SDK configurado para compilar Android.

## Ejecutar y verificar

```powershell
flutter pub get
dart format lib test
flutter analyze --no-pub
flutter test --no-pub
flutter run
flutter build apk --debug --no-pub
```

El APK debug se genera en `build/app/outputs/flutter-apk/app-debug.apk`.

## Configuración de publicación

El nombre visible provisional es `Bike Expert` y el identificador Android debe confirmarse antes de publicar en Play Store. No agregues secretos, credenciales ni tokens al repositorio.

## Documentación relacionada

- `../docs/architecture.md`: capas y límites de la arquitectura.
- `../docs/knowledge-base.md`: versión, contenido y reglas de validación de la base de conocimiento.
- `../Ex_sys_bike_FINAL.py`: prototipo Python de referencia, conservado sin ejecutar dentro de la app.
