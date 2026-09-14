> Actualización 2026-09-10: ver [revisión de producto 0.3.1](phase3-product-review.md). Prevalece sobre las descripciones anteriores de stop/unresolved, confirmaciones, ayuda visual y límites del piloto.

# Motor de reparaciones

`RepairSession` recorre un procedimiento ya validado sin depender de Flutter, SQLite ni un catálogo técnico global. La UI presenta un nodo a la vez. El modelo conserva el estado editorial para evitar que un consumidor trate un fixture como procedimiento normal.

Inicio: búsqueda offline o selección breve de síntoma, selección de ruta/taller y entrada directa al procedimiento. No hay formulario obligatorio ni diagnóstico duplicado de emergencia. El mismo grafo puede ramificarse mediante contextBranch para ruta y taller.

Las comprobaciones usan choices. Los pasos requieren confirmación explícita. «¿Funcionó?» puede conducir a prueba final o siguiente causa. Una prueba final aprobada permite complete; una fallida conduce a una salida no completa. Los únicos resultados visibles son complete, temporary y stop. `unresolved` permanece como defensa interna del motor y no se proyecta a ningún resultado visible.

Las banderas rojas son acumulativas dentro de la sesión. Se pueden declarar en la entrada o durante cualquier paso. `reportHardStop` también domina resultados previos completos/temporales en el dominio. Después de una bandera no se admite retroceso ni otro avance. El conjunto expuesto es inmutable; no existe método para rebajarlo. No se introdujo lógica difusa.

## Bicicleta y modo invitado

La búsqueda utiliza el tipo de bicicleta cuando existe. La sesión toma una instantánea de los datos conocidos; los vocabularios `identifications` de la edición declaran claves, etiquetas y almacenamiento. Nuevas categorías usan `knowledge.*`; frenos y neumáticos conservan alias de perfiles existentes. Un 1x12 no infiere otra dimensión ni configuración.

Un nodo identify se omite únicamente si el perfil tiene un valor reconocido que corresponde exactamente a una respuesta. No sé, valores no reconocidos o invitado mantienen la pregunta. La opción de ayuda sigue una rama del grafo. Los fixtures contienen ayuda simulada; falta la ayuda mecánica revisada y sus diagramas.

En contenido aprobado, la persona puede elegir guardar un dato identificado. `saveIdentification` actualiza únicamente ese campo sobre el perfil más reciente dentro de una transacción; no sobreescribe otros cambios. En fixtures no se escribe al perfil. La sesión conserva respuestas en memoria; al cerrar el flujo no se guarda historial todavía (Fase 4).

## Búsqueda

Normaliza mayúsculas, acentos y puntuación, amplía términos con el diccionario de sinónimos editorial y ordena por coincidencia textual con desempate por ID. Filtra categoría, contexto y tipo conocido. Un invitado no pierde resultados por falta de perfil. La búsqueda es determinista, local y no usa IA.

Pendientes antes de guías reales avanzadas: contenido auditado, identificación exacta de modelo aplicable a especificaciones, revisión de compatibilidad contextual, diagramas, pruebas físicas y cobertura por categoría. No presentar los fixtures como evidencia de seguridad mecánica.
