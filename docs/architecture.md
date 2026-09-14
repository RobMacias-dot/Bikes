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

## Retirado y pendiente

Se retiraron de la app DiagnosticScenario, DiagnosticEngine, el flujo/reporte heredados y su catálogo. El prototipo Python permanece fuera de la app como archivo histórico, sin dependencia de ejecución.

Pendientes: extracción ARB propia (se mantienen delegados Flutter es), contenido aprobado, identificación exacta para especificaciones, ilustraciones, Fase 4 y verificación física/publicación. El catálogo técnico está vacío; validar estructura no confirma exactitud mecánica.
