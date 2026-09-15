# Arquitectura de BiciFirme

Flutter presenta la aplicación; Riverpod inyecta repositorios y GoRouter mantiene Inicio, garaje y problemas. No hay backend, IA ni sincronización remota.

## Dominio puro

`domain/entities/bike.dart`: perfil inmutable. `domain/knowledge/`: lectores estrictos, catálogos técnicos, procedimientos, paquete versionado, búsqueda y sesión. Estos módulos no importan Flutter ni SQLite y también se usan en las herramientas editoriales.

Los componentes y reparaciones tienen versiones y fuentes independientes. La reparación referencia IDs de especificaciones y la versión técnica exacta; las especificaciones no incluyen pasos. Ver [contratos](knowledge-schemas.md).

`RepairSession` solo acepta procedimientos validados. Registra contexto, respuestas y banderas rojas; impide degradarlas o llegar a completo sin aprobar la prueba final. La estructura del grafo está limitada y validada antes de ejecutar. Los estados son privados y las colecciones expuestas inmutables.

## Datos

`data/providers.dart` crea una instancia SQLite por contenedor. Drift ejecuta SQL explícito en un isolate de fondo con `NativeDatabase.createInBackground`. `BikeRepository` usa consultas parametrizadas, transacciones y UPSERT. `saveProfileFact` lee el perfil más reciente y actualiza solo el campo admitido.

`RepairKnowledgeRepository` lee assets locales, valida el paquete completo y solo entonces entrega modelos a la UI. El catálogo aprobado vacío no hace fallback a fixtures ni al modelo heredado. El laboratorio está restringido a debug; el motor requiere autorización explícita adicional para una sesión de desarrollo.

`ComponentImport` transforma registros de hojas normalizadas a JSON técnico estable. `tools/xlsx_master.py` extrae el maestro fuera del runtime y `XlsxComponentImport` mapea/valida sus hojas antes de este límite. El teléfono solo consume JSON; no interpreta XLSX ni ejecuta Python.

## Presentación

Inicio muestra bicicleta activa y búsqueda. ProblemsPage permite invitado, búsqueda, categoría, contexto y síntoma; RepairPage muestra un nodo a la vez y deriva los avisos de desarrollo del procedimiento. La sesión recibe una instantánea de los hechos conocidos. Guardar un nuevo dato requiere elección explícita y nunca se hace con respuestas de fixtures.

El resultado usa texto y color. Las pantallas nuevas admiten desplazamiento; cambiar de nodo reinicia la posición para mostrar la nueva comprobación. No se añadieron animaciones que retrasen el flujo.

## Límites vigentes

La edición técnica approved y el catálogo de reparaciones approved están vacíos. El maestro técnico 0.1.0 y los cuatro pilotos 0.3.2 permanecen en development. Hay tres ayudas visuales piloto, pero no una biblioteca completa. Continúan pendientes extracción ARB propia, identificación exacta para especificaciones, flujos de vida útil y verificación física/publicación. Validar estructura no confirma exactitud mecánica.

Consultar el [estado canónico del proyecto](project-review.md) para gates y deuda actuales.
