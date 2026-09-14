# Aplicación BiciFirme

Flutter Android. Ejecutar los comandos desde esta carpeta; consultar el README de la raíz para el estado completo.

El nombre del paquete Dart `bike_expert` se conserva temporalmente para no mezclar la migración funcional con cambios de importaciones. No es el identificador Android ni aparece como marca al usuario. La aplicación Android usa `com.robmac.bicifirme`.

La versión 0.1.0 es de desarrollo. No publicar como producto terminado.

Para las pruebas del importador real se requiere Python 3 en PATH o definir `BICIFIRME_PYTHON` con su ruta. Desde la raíz, ejecutar además `python -m unittest discover -s tools -p test_xlsx_master.py -v`. El teléfono no usa Python ni XLSX. Ver [pipeline editorial](../docs/component-pipeline.md).
