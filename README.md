# BiciFirme

Asistente Android de bicicletas offline, gratuito y sin anuncios. Una app de RobMac.

## Estado

Fundamentos y arquitectura de conocimiento implementados; flujo interactivo disponible para pruebas. **Todavía no es una V1 publicable y no contiene reparaciones mecánicas aprobadas.**

- Identidad BiciFirme / Android `com.robmac.bicifirme`.
- Garaje SQLite persistente, perfiles editables y bicicleta activa/predeterminada.
- Esquemas independientes de componentes y procedimientos, con versiones, referencias y validación estricta.
- Motor de pasos, comprobaciones, ramas, contexto ruta/taller y resultados ligados a prueba final.
- Banderas rojas acumulativas que no se pueden rebajar.
- Búsqueda offline con sinónimos, entrada directa, selección breve por síntoma y modo invitado.
- Reutilización de datos conocidos y actualización opcional de un campo del perfil.
- Importador editorial XLSX → JSON offline con estándares, consumibles, endpoints tipados y trazabilidad del maestro development.

El catálogo y diagnóstico heredados fueron retirados de la aplicación. La edición aprobada está vacía. En debug puedes entrar a **Resolver un problema → Abrir laboratorio de desarrollo** para evaluar los cuatro procedimientos mecánicos del [piloto de Fase 3](docs/phase3-pilot.md), todavía editorialmente `development`. No guardan respuestas en bicicletas y no se habilitan en profile/release. Los fixtures sintéticos anteriores se conservan separados para regresión.

Maestro development importado y validado en `knowledge/generated/development/0.1.0/`; fuente intacta en `knowledge/master/`. Pendientes: contenido aprobado y fuentes revisadas para producción, identificación exacta para procedimientos específicos, diagramas, kit, historial, mantenimiento, notificaciones, respaldos y validación física. Las tablas de la Fase 4 están preparadas; no se presentan como funciones terminadas.

## Desarrollo

Desde `mobile/`, con Flutter 3.47.2 / Dart 3.13.2 usados en estas fases:

```powershell
flutter pub get
flutter analyze --no-pub
flutter test --no-pub # Requiere Python 3 en PATH o BICIFIRME_PYTHON para el test del maestro
flutter build apk --debug --no-pub
dart run tool/validate_knowledge.dart assets/knowledge/approved
dart run tool/validate_knowledge.dart assets/knowledge/development --development
```

No requiere backend, cuentas ni red para funcionar. El manifiesto principal no solicita Internet.

## Documentación

- [Diagnóstico y migración](docs/migration-plan.md)
- [Arquitectura](docs/architecture.md)
- [Modelo local y backup pendiente](docs/data-model.md)
- [Esquemas de conocimiento](docs/knowledge-schemas.md)
- [Canalización desde el maestro](docs/component-pipeline.md)
- [Motor y búsqueda](docs/repair-engine.md)
- [QA interno](docs/qa.md)
- [Publicación Android](docs/android-release.md)
- [Privacidad provisional](docs/privacy.md)

No realizar commit ni push hasta que el propietario lo indique.
