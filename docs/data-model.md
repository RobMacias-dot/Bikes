# Modelo local y migraciones

SQLite `bicifirme.sqlite`, esquema 2. Esquema 1 representa la tabla inicial de bicicletas utilizada como fixture de migración; no existió una versión pública con datos persistentes antes de esta migración.

| Tabla | Responsabilidad | Estado |
| --- | --- | --- |
| bikes | id, nombre, tipo y perfil JSON de campos textuales | Repositorio y UI implementados |
| preferences | Clave/valor; activeBike y defaultBike | Implementado |
| components | Descripción manual, catálogo opcional, detalles y bicicleta | Tabla preparada |
| kit | Nombre y cantidad no negativa | Tabla preparada |
| history | Bicicleta opcional, fecha, guía, resultado, notas y resuelto | Tabla preparada |
| maintenance | Bicicleta, tarea, fechas y notas | Tabla preparada |

El perfil almacena frenos, neumático, transmisión, marca/modelo, año, rueda, familias, uso y notas sin inventar información. «No sé» no se traduce a una especificación técnica. El mapa inmutable permite preservar campos progresivos al editar.

La primera bicicleta se vuelve activa y predeterminada. Cambiar la activa no cambia la predeterminada. La selección activa persiste entre aperturas; la predeterminada será referencia para flujos futuros cuando no haya elección explícita. Un identificador vacío representa invitado. La creación y selección inicial son transaccionales. La edición usa UPSERT, no REPLACE, para conservar relaciones.

Claves foráneas habilitadas. El borrado de bicicleta elimina componentes/mantenimiento y deja el historial con referencia nula. No se expone todavía borrado en UI. Los IDs de selección se reparan transaccionalmente al borrar por repositorio.

Para la próxima migración: aumentar schemaVersion, añadir ruta explícita sin borrar tablas existentes y probar desde cada esquema admitido. Se rechaza una versión futura en vez de sobrescribirla.

## Backup pendiente

Exportar una representación JSON versionada, no copiar SQLite abierto. Validar tamaño, versión, tipos, IDs únicos, referencias, fechas y resultados antes de alterar datos. Mostrar contenido y pedir confirmación de reemplazo; aplicar importación completa en una transacción, con rollback en cualquier fallo. Incluir todas las tablas de usuario y preferencias; no incluir credenciales. La importación debe volver a programar notificaciones solo tras el consentimiento local. Este contrato es un diseño, todavía no una función disponible.
