# Canalización editorial del maestro

La fuente editorial es `knowledge/master/BiciFirme_Componentes_Master.xlsx`, fuera de los assets runtime. Se conserva intacta, con estado **development** y versión **0.1.0**; la auditoría estructural no constituye aprobación mecánica ni habilita su publicación.

El artefacto reproducible está en `knowledge/generated/development/0.1.0/components.json`. Su `editorial` conserva el nombre del archivo, SHA-256 y todas las claves/notas de README. SHA-256 del maestro auditado:

`e3b4510f378b70c6e2758b24b1301124b49806b3299ad70612758fbdce706b1d`

## Ejecución

Desde `mobile/`, con Python 3 en PATH (o una ruta al ejecutable):

```powershell
dart run tool/import_xlsx.dart python ../knowledge/master/BiciFirme_Componentes_Master.xlsx build/editorial-review/components.json
```

La salida debe ser nueva. El lector `tools/xlsx_master.py` utiliza únicamente ZIP/XML de la biblioteca estándar de Python. Rechaza fórmulas, errores de celdas, columnas/filas duplicadas y referencias OOXML inválidas. No guarda el Excel, no evalúa fórmulas y no descarga datos.

`XlsxComponentImport` exige las diez hojas y sus columnas, convierte fechas editoriales Excel a ISO y `critical` 0/1 a booleano. Conserva EAV `value` como texto, unidades originales, opciones separadas por `|`, alcances vacíos, notas e IDs. No crea productos cartesianos ni convierte unidades. El esquema del maestro es 1; el formato normalizado y el catálogo runtime son 2. Versiones no compatibles se rechazan, sin migración silenciosa.

`ComponentImport` ordena registros por ID y claves de forma determinista y usa el mismo validador técnico que el runtime. Solo se escribe después de validar el catálogo completo. El CLI XLSX admite exclusivamente maestros development; cambiar status a approved se rechaza. El importador JSON existente continúa rechazando development por defecto; la habilitación es explícita para el adaptador editorial. Ninguna herramienta copia automáticamente contenido a assets.

## Resultado verificado

| Colección | Registros |
| --- | ---: |
| sources | 59 |
| manufacturers | 11 |
| families | 21 |
| components | 61 |
| standards | 52 |
| specifications | 409 |
| compatibilities | 20 |
| consumables | 11 |
| componentConsumables | 8 |

Los conteos declarados por README se comprueban y las pruebas fijan los conteos completos y la huella de este maestro. Al revisar una edición nueva, actualizar deliberadamente la prueba de integridad y generar otro directorio versionado; no sobreescribir la fuente auditada ni el artefacto previo.

## Representación y límites editoriales

- Las 244 unidades de especificación vacías permanecen vacías; no se introducen `none`, `n/a` ni unidades ficticias. Los 399 alcances vacíos de especificación tampoco se rellenan. Compatibilidad sí requiere alcance explícito.
- Los IDs son únicos **por colección/tipo**. El maestro contiene `trp.spyre` tanto como familia como componente; se conserva sin renombrar porque sus referencias son tipadas. Duplicar el ID dentro de cualquier colección se rechaza.
- Compatibilidades usan endpoints `{type, id}` de component, standard o family. Las columnas opcionales `from_family_id` y `to_family_id` ya están admitidas. Cada lado exige exactamente un endpoint con referencia existente. No se crean proxies.
- La familia `ritchey.c260` existe. La incompatibilidad de Comp ErgoMax con C260 solo está en una nota editorial del maestro, no en las 20 filas de COMPATIBILITIES. El esquema ya puede representarla limpiamente, pero falta una fila editorial explícita con alcance/fuente; el importador no interpreta prosa como regla ni modifica el Excel.
- `COMPONENT_CONSUMABLES.relation_type` admite service, replacement y compatible, siempre con alcance y fuente. No se convierte en un procedimiento ni propaga compatibilidades.
- Las listas de opciones `|` se conservan textualmente; el maestro advierte que no acreditan todas sus combinaciones. Tampoco hay inferencias por familia, marca, velocidades, medidas o transitividad. Ausencia de relación = unknown.
- No se detectaron columnas actuales sin representación. Las notas y vacíos deliberados se conservan; no se convierten en especificaciones o instrucciones nuevas.

## Integración offline

El catálogo generado es consumible por `TechnicalCatalog.parse(..., allowDevelopment: true)`; hay prueba de integración con el contrato de reparaciones fijando `technicalVersion: 0.1.0`. La app solo carga JSON. El XLSX, Python y el maestro generado de revisión no se empaquetan como assets.

El laboratorio runtime sigue usando su edición sintética independiente 1.0.0. La edición approved permanece vacía. Una incorporación posterior de catálogo y procedimientos deberá actualizar JSON, dependencia técnica y manifiesto como un paquete coherente; nunca interpretar el artefacto development como aprobado.

## Pruebas

```powershell
# Desde la raíz
python -m unittest discover -s tools -p test_xlsx_master.py -v
# Desde mobile; definir BICIFIRME_PYTHON solo si python no está en PATH
$env:BICIFIRME_PYTHON = 'ruta/al/python.exe'
flutter test --no-pub
flutter analyze --no-pub
dart run tool/validate_knowledge.dart assets/knowledge/approved
dart run tool/validate_knowledge.dart assets/knowledge/development --development
```

Las pruebas leen el maestro real, comparan el catálogo generado y modifican copias en memoria/temporales para comprobar rechazos. No requieren red ni alteran la fuente editorial.
