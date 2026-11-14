# Progreso de la traducción española

## Estado actual

- Fase 1 — análisis del APK: completada. APK v0.1.25 decodificada correctamente con apktool.
- Fase 2 — inventario inicial: extracción completada. Se analizaron 43 archivos JSON y se recogieron 1.691.933 valores de tipo cadena.
- El inventario completo se conserva como artefacto de GitHub Actions [43623959118](https://github.com/JuanjoJCA/exvius-offline/actions/runs/43623959118), no dentro de Git, porque el JSON generado supera el límite de 100 MB por archivo.
- Se ha confirmado en el código y la documentación del cliente v9.0.0 que el cliente solicita el idioma `LANGUAGE_ENGLISH` y que las tablas localizadas CPK usan ocho columnas: EN, ZH, KO, FR, DE, ES, TH e ID.
- Se ha añadido un inyector seguro que coloca el texto español revisado en la primera columna que el cliente realmente lee, preservando las otras siete columnas y los comandos del juego.
- Catálogo inicial: 35 diálogos del prólogo y la primera aparición de Ifrit, con fuentes inglesas verificadas contra el catálogo de recuperación existente.
- Validación automática: sintaxis, estructura del catálogo, hashes de origen, etiquetas de control y conservación de columnas. La ejecución [43624975703](https://github.com/JuanjoJCA/exvius-offline/actions/runs/43624975703) terminó correctamente.
- Cobertura actual: 82 entradas revisadas; incluye el prólogo, la primera aparición de Ifrit y los arcos de Ramuh oscuro, Asura oscuro y Bahamut oscuro (escenas 700010304–700010306 y 700010501–700010503). No se declara una traducción completa ni un porcentaje global.
- Últimos lotes: 11 cadenas para completar 700010304, 7 para 700010305–700010306 y 29 para 700010501–700010503. Se conservan los comandos y la estructura original.
- El inventario del APK comunitario cubre JSON; quedan por clasificar y revisar otros formatos y recursos.

## Siguientes fases

- Ampliar el catálogo de diálogos por escenas y revisar nombres de personajes y terminología.
- Traducir habilidades, interfaz, misiones, objetos y textos de sistema mediante sus fuentes correspondientes.
- Integrar el catálogo en la generación de paquetes de datos y comprobarlo con el cliente objetivo.
- Resolver y verificar la cadena de construcción APK para la versión exacta que se vaya a distribuir.

## Criterios

- Trabajar exclusivamente en la rama `traduccion-es`; no modificar `main`.
- No sustituir ni alterar el APK original.
- No traducir identificadores ni modificar etiquetas, variables o estructura de tablas.
- Validar las fuentes, hashes y comandos antes de aceptar cada lote.
- No publicar claves, firmas ni binarios propietarios.
