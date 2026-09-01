# Bike Expert

Primera entrega offline-first del sistema experto de bicicletas. El prototipo Python se conserva intacto en `Ex_sys_bike_FINAL.py`; la app Flutter vive en `mobile/` y convierte su conocimiento en datos JSON versionados.

## Estado

Incluye Material 3 claro/oscuro, garaje, flujo de diagnóstico, triaje crítico, reglas auditables, cálculo Bayes orientativo, facilidad Mamdani, cadena hacia atrás, reporte, PDF, portapapeles y Sharesheet nativo. No hay autenticación, backend, permisos de contactos/SMS ni secretos.

El identificador provisional es `com.bikeexpert.app` y el nombre visible es `Bike Expert`. Ambos deben confirmarse antes de publicar en Play Store.

## Ejecutar

```powershell
cd mobile
flutter pub get
flutter run
flutter test
flutter analyze
flutter build apk --debug
```

La instalación y generación de plataforma requieren que Flutter pueda iniciar correctamente. La app no requiere conexión para diagnosticar.

## Seguridad

Una bandera roja fuerza `NO UTILIZAR`. El resultado es orientación educativa y nunca confirma seguridad física, compatibilidad ni una reparación. Las compatibilidades requieren modelo, serie, velocidades, estándar o código cuando aplique.
