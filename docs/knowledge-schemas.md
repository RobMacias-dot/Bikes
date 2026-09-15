# Esquemas de conocimiento, versión 2

Los contratos ejecutables están en `mobile/lib/domain/knowledge/`. Catálogo técnico y reparaciones son independientes. Se rechazan campos desconocidos, tipos incorrectos, duplicados y referencias rotas, sin completar datos ausentes por inferencia.

## Versiones y estado

`schemaVersion` debe ser el entero 2, también en el manifiesto. `contentVersion` usa tres segmentos semánticos numéricos, sin ceros iniciales: permite 0.1.0. Las versiones de ambos catálogos deben coincidir exactamente con las del manifiesto; `repairs.technicalVersion` fija su dependencia técnica. Las ediciones approved y development no se mezclan. El maestro XLSX mantiene su propio schema_version 1; el adaptador realiza el mapeo explícito.

Los IDs aceptan `[a-z][a-z0-9_.-]{0,95}` y son únicos por colección. Nodos: ámbito de procedimiento. Respuestas: ámbito de nodo. Un mismo ID de familia y componente es válido porque el tipo determina su espacio de nombres.

## Catálogo técnico

Raíz: kind=components, schemaVersion, contentVersion, status, sources, manufacturers, families, components, standards, specifications, compatibilities, consumables y componentConsumables. `editorial` opcional conserva sourceFile, sha256 y metadata del maestro; cuando está presente exige estado development y versiones coherentes. Los fixtures sintéticos usan dev.*; approved rechaza esos IDs. Los IDs reales de un maestro development permanecen intactos.

| Colección | Contrato |
| --- | --- |
| sources | id, publisher, document, revision, url HTTPS, section, reviewedAt ISO; sourceType y notes opcionales |
| manufacturers | id, name; website y notes opcionales |
| families | id, manufacturerId, name; componentCategory y notes opcionales |
| components | id, familyId, name, identification; manufacturerId, category, subcategory, model, variant, bikeUse, standardPrimaryId, sourceId, notes opcionales |
| standards | id, category, name, designation, description, dimension1, dimension1Unit, dimension2, dimension2Unit, thread, sourceId, notes |
| specifications | id, componentId, property, value, unit, scope, sourceId; standardId, critical booleano y notes opcionales |
| compatibilities | id, from, to, result, scope, sourceId; notes opcional |
| consumables | id, manufacturerId, category, name, variant, specification, unit, standardId, sourceId, notes |
| componentConsumables | id, componentId, consumableId, relationType, scope, sourceId, notes |

Los campos opcionales permiten fixtures mínimos. El adaptador del maestro exige todas las columnas de sus hojas y las conserva. Referencias no vacías deben existir; se permite fabricante desconocido en consumibles, sin inventarlo. Fabricante explícito del componente debe coincidir con su familia. Dimensión y unidad de estándar deben estar ambas presentes o ambas vacías. Una especificación requiere value no vacío; unit y scope pueden ser textos vacíos. No admite unidades ficticias `none`, `n/a`, `not-applicable`.

Los endpoints de compatibilidad son objetos `{type: component|standard|family, id}`. result admite compatible/incompatible. Pares iguales o invertidos en el mismo scope se rechazan como duplicados/conflictos. Se exige endpoint existente del tipo exacto y fuente existente. La consulta requiere par **y alcance exactos**; ausencias o cualquier otro alcance devuelven unknown. No expande familias ni hace transitividad. `componentConsumables.relationType` admite service/replacement/compatible; sus relaciones no alteran esta consulta.

## Reparaciones

Raíz: kind=repairs, schemaVersion, contentVersion, status, technicalVersion, locale=es-MX, sources, synonyms, identifications y procedures. Fuentes independientes del catálogo técnico.

Procedimiento: id, title, problem, category, terms, bikeTypes, contexts, tools, difficulty, risk, estimatedMinutes, safetyFocus, sourceIds, specificationIds, entry y nodes. risk: low/moderate/high. estimatedMinutes: `{min,max}`, enteros positivos, min≤max≤10080. Solo development permite null para no inventar una duración de simulación; approved requiere estimación editorial. safetyFocus lista banderas relevantes para ordenar la UI; nunca elimina controles.

Extensión aditiva de Fase 3: raíz `repairs.tools` y `repairs.consumables`, colecciones opcionales `{id,name}`. Cada procedimiento puede referenciarlas con `toolIds` y `consumableIds`; IDs inexistentes, repetidos o de otro tipo se rechazan. Estos consumibles son recursos requeridos por la intervención, no relaciones técnicas `componentConsumables`, ni una declaración de compatibilidad de un producto. `tools` libre permanece para fixtures anteriores; no se mezcla con `toolIds`. El piloto `dev.pilot.*` exige ambos campos explícitos (listas vacías cuando no aplican), fuentes y tiempo editorial. La UI resuelve los nombres y muestra herramientas y consumibles por separado. No se modificó el maestro técnico.

`identifications` declara `{key, storageKey, values}`. `values` es un mapa de IDs de respuesta a etiquetas, incluye unknown y no admite etiquetas ambiguas. Nuevos storageKey usan knowledge.*; tires/brakes son alias de perfiles existentes. Claves y storageKey no se repiten. El motor no enumera categorías identificables: cada identify referencia una definición y solo admite sus valores. Perfiles reconocidos evitan repetir la pregunta; ausencia o unknown preservan la pregunta.

| Nodo | Campos específicos | Regla |
| --- | --- | --- |
| safetyCheck | choices | Todas las banderas obligatorias más una rama sin bandera |
| identify | profileKey, choices | Vocabulario declarado, respuestas únicas y unknown |
| contextBranch | routes | route y workshop obligatorias |
| check | choices | Dos o más ramas |
| step | next | Confirmación explícita |
| finalCheck | choices | Exactamente pass y fail |
| outcome | result, restrictions | complete, temporary, stop; unresolved se conserva solo como estado interno del motor |

Todos tienen id, kind y text; `details` y `visualIds` son opcionales. `visualIds` contiene cero o más IDs del registro offline admitido; se rechazan duplicados, IDs desconocidos y URLs. Choices: id, label, next; hardStop/profileValue/verdict solo cuando corresponden al tipo. El grafo no tiene ciclos ni nodos inalcanzables. Entrada obligatoria safetyCheck.

Banderas irreversibles: structural_damage, braking_loss, steering_damage, critical_part_broken. Cada rama roja conduce a stop. La sesión acumula banderas y bloquea retroceso/avance incluso después de un resultado anterior. safetyFocus y riesgo nunca las rebajan. complete requiere aprobación inmediata de finalCheck; temporal necesita restricciones y fuentes editoriales en approved.

La UI solo usa VisibleRepairOutcome: complete verde, temporary amarillo y stop rojo. unresolved permanece interno y no se convierte automáticamente en stop ni temporary. Fixtures: prefijo dev.*, título [PRUEBA], laboratorio debug y sin escritura de respuestas al perfil. No constituyen instrucciones mecánicas.
