# Arquitectura

La aplicación se organiza por capas: `domain` contiene entidades y el motor determinista; `data/knowledge` carga el catálogo JSON local; `features` contiene flujos de interfaz; `data/database` es el límite de persistencia local. Riverpod provee estado e inyección y GoRouter controla la navegación.

El motor aplica primero el triaje. Una bandera roja fija el riesgo en crítico y ninguna fase posterior puede reducirlo. Después activa una regla de escenario y conserva una traza. Bayes y Mamdani son resultados auxiliares: no autorizan uso ni sustituyen inspección.

`LocalDatabase` define el borde para Drift/SQLite y los futuros repositorios remotos. No hay dependencia con Supabase: se podrá añadir un repositorio sincronizado sin cambiar el dominio. La siguiente iteración debe concretar las tablas Drift de garaje, componentes, sesiones, reportes, preferencias y versión de conocimiento, y ejecutar `build_runner`.
