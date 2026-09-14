# BiciFirme: diagnóstico y plan de migración

Inspección inicial: 5 de septiembre de 2026. Repositorio sin cambios de trabajo al iniciar. No se realiza commit ni push sin instrucción del propietario.

## Diagnóstico previo a cambios

La aplicación en `mobile/` usa Flutter, Riverpod y GoRouter. Tiene tres rutas (inicio, garaje y diagnóstico), un reporte y un catálogo embebido. El prototipo Python es independiente y no participa en la compilación. `knowledge/` y `tools/` no contienen una canalización editorial implementada.

Reutilizable: estructura Flutter/Android, inyección Riverpod, navegación, localización Material en español, temas claro/oscuro y principio de prioridad absoluta de banderas rojas. Compartir mediante Android puede reutilizarse para respaldos.

Deuda observada:

- Garaje solamente en memoria; `LocalDatabase` es una interfaz vacía. Drift está instalado pero no se utiliza.
- Perfil limitado a nombre/tipo en la UI; no hay bicicleta activa, componentes ni edición.
- Catálogo de recomendaciones breves, sin pasos, ramas, pruebas finales ni referencias verificadas. Tiene IDs repetidos entre sistemas (`fuga`, `ruido`). Su contenido no constituye guías publicables.
- El manifiesto no se valida al cargar. Valores desconocidos se convierten silenciosamente en sistema eléctrico o riesgo medio.
- Flujo obliga a seleccionar sistema/síntoma y marca; no hay búsqueda ni acceso directo por problema.
- Reporte expone Bayes, Mamdani y trazas. Sus estimaciones carecen de calibración demostrada y no ayudan a reparar.
- Incluye e-bikes fuera del alcance nuevo. No hay historial, kit, mantenimiento, recordatorios ni backup.
- Tests limitados: la prueba de bandera roja parte de un escenario ya crítico, por lo que no demuestra elevación desde riesgo bajo.
- Android usa `com.example.bike_expert`, etiqueta provisional y firma debug para release.
- Documentación describe capacidades de persistencia todavía inexistentes y una posible sincronización remota ajena al nuevo producto.

## Decisiones

Conservar Flutter y Riverpod. Separar dominio, persistencia, catálogo técnico, procedimientos y presentación. Retirar gradualmente el motor académico al sustituir sus consumidores, sin migrar fórmulas ni tratar su catálogo como fuente técnica. No ejecutar ni depender del prototipo Python.

SQLite tendrá migraciones transaccionales, claves foráneas y repositorios comprobables sin widgets. Los procedimientos y componentes tendrán esquemas separados, versiones independientes y validación estricta. El maestro recibido se conserva como development; no se inventan compatibilidades, torques ni fuentes.

## Fases y condiciones de salida

1. **Fundamentos:** identidad BiciFirme, persistencia/migraciones, perfiles progresivos, bicicleta activa/predeterminada y pruebas de reinicio. Release nunca se firma con debug.
2. **Conocimiento:** esquemas independientes, validación de IDs/referencias/ramas y proceso editorial desde el maestro; búsqueda con sinónimos y filtros que conservan opciones cuando el dato se desconoce.
3. **Resolver un problema:** entrada directa o diagnóstico breve, invitado, contexto ruta/taller, pasos y bifurcaciones, banderas rojas inmutables y resultados ligados a pruebas finales.
4. **Vida útil:** kit, historial, mantenimiento por fecha/uso, notificaciones opcionales y backup validado/restauración transaccional.
5. **Producto:** diseño accesible en vertical, diagramas originales offline, identificación, correo voluntario editable, apoyo configurable sin enlace ficticio y privacidad.
6. **Validación y distribución:** cobertura funcional por categoría, tests de regresión, QA físico registrado, fuentes auditadas, iconos y AAB firmado por el propietario. Compilar no equivale a aprobar V1.

## Bloqueos de publicación, no de desarrollo

Faltan aprobación del conocimiento técnico para producción, clave de firma de producción, enlace de apoyo (opcional), validación física de procedimientos y revisión de requisitos Play vigentes al publicar. No se afirmará que estos puntos están resueltos ni que existe certificación externa. El trabajo de ingeniería puede avanzar sin ellos.

## Avance de la primera entrega

Implementados fundamentos de identidad y garaje SQLite, perfiles editables, selección activa/predeterminada, acceso como invitado, limpieza académica de la app y configuración de firma de release independiente de debug. Se conserva temporalmente el prototipo Python fuera de la aplicación; no es una dependencia ni una fuente aprobada. El catálogo heredado permanece como diagnóstico provisional hasta la fase de procedimientos. Las fases 2–6 continúan pendientes; no se declara V1 terminada.

## Avance de Fase 2 y base de Fase 3

Implementados esquemas separados y versionados, validación de referencias/grafos/estados, rechazo de fixtures por defecto, transformador de hojas normalizadas, herramientas CLI, búsqueda offline y nuevo flujo de reparación. El catálogo heredado y sus consumidores se retiraron de la app. La interfaz aprobada no muestra guías mientras no haya contenido validado editorialmente.

El laboratorio debug ejercita problemas, comprobaciones, pasos con check, bifurcaciones, siguiente causa, prueba final y tres resultados visibles (complete/temporary/stop), con unresolved interno. El contexto ruta/taller selecciona ramas del mismo grafo. La bicicleta activa reduce preguntas solo con datos reconocidos; el invitado conserva acceso. Guardar hechos está preparado para contenido aprobado y prohibido en fixtures.

Fase 2 queda implementada como infraestructura. El lector XLSX y su transformador ya importan el maestro real 0.1.0 con sus conteos verificados, sin promoverlo de development. Fase 3 tiene motor y UI funcionales de prueba; la cobertura mecánica y las fuentes siguen pendientes por instrucción explícita de no inventar contenido técnico. Fases 4–6 no se iniciaron en esta entrega.
