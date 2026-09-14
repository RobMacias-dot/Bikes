# Conocimiento de BiciFirme

Los esquemas separados y su validación están implementados. El catálogo heredado, su cargador y el diagnóstico/reporte antiguos fueron retirados de la aplicación. No existe fallback hacia recomendaciones heredadas cuando falla la validación.

Consultar [contratos de conocimiento](knowledge-schemas.md), [canalización editorial](component-pipeline.md) y [reglas del motor](repair-engine.md).

La edición `approved` está vacía porque aún no hay contenido mecánico aprobado. La UI lo comunica y conserva el acceso al garaje. El laboratorio carga ahora `assets/knowledge/pilot`, un paquete separado de cuatro procedimientos mecánicos con estado `development`. Los fixtures didácticos de `assets/knowledge/development` se conservan para regresión del contrato y ya no son la entrada del laboratorio. Véase [piloto de Fase 3](phase3-pilot.md).

Solo un botón de laboratorio en debug carga development. No se habilita en profile/release ni mediante parámetros de navegación o dart-define. El cargador, parser y motor tienen controles adicionales. Los assets de fixtures pueden estar físicamente dentro del APK, pero nunca se ofrecen como conocimiento aprobado; no se pretende mantener secretos en el APK.

Los fixtures muestran una advertencia de simulación; el piloto muestra una advertencia editorial específica. Ambos usan IDs dev. y títulos [PRUEBA], y no guardan respuestas en bicicletas. Los tests usan datos sintéticos de especificaciones exclusivamente dentro de `test/`.

La validación estructural no sustituye revisión de fuentes ni validación física de una reparación real. La app todavía no es una V1 publicable.
