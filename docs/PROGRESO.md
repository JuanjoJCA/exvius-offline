# Progreso de la traducción española

## Estado actual

- Fase 1 — análisis del APK: completada. APK v0.1.25 decodificada correctamente con apktool.
- Fase 2 — inventario inicial: extracción completada. Se analizaron 43 archivos JSON y se recogieron 1.691.933 valores de tipo cadena.
- El inventario completo se conserva como artefacto de GitHub Actions [43623959118](https://github.com/JuanjoJCA/exvius-offline/actions/runs/43623959118), no dentro de Git, porque el JSON generado supera el límite de 100 MB por archivo.
- Se ha confirmado en el código y la documentación del cliente v9.0.0 que el cliente solicita el idioma `LANGUAGE_ENGLISH` y que las tablas localizadas CPK usan ocho columnas: EN, ZH, KO, FR, DE, ES, TH e ID.
- Se ha añadido un inyector seguro que coloca el texto español revisado en la primera columna que el cliente realmente lee, preservando las otras siete columnas y los comandos del juego.
- Catálogo inicial: 35 diálogos del prólogo y la primera aparición de Ifrit, con fuentes inglesas verificadas contra el catálogo de recuperación existente.
- Validación automática: sintaxis, estructura del catálogo, hashes de origen, etiquetas de control y conservación de columnas. La ejecución [43624975703](https://github.com/JuanjoJCA/exvius-offline/actions/runs/43624975703) terminó correctamente.
- Cobertura actual: 166 entradas revisadas; incluye el prólogo, la primera aparición de Ifrit, etiquetas de mapa/personajes y el arco oscuro completo hasta su desenlace (escenas 700010304–700010306 y 700010501–700010503, 700010601–700010603 y 700010701–700010703). No se declara una traducción completa ni un porcentaje global.
- Últimos lotes: 11 cadenas para completar 700010304, 7 para 700010305–700010306, 29 para 700010501–700010503, 32 para 700010601–700010603, 39 para 700010701–700010703 y 13 nombres/etiquetas de apoyo del prólogo y del mapa de Tetra Sylphid. Se conservan los comandos y la estructura original.
- El inventario del APK comunitario cubre JSON; quedan por clasificar y revisar otros formatos y recursos.


- Auditoría del siguiente bloque: el catálogo de recuperación contiene 143 registros para 700010401–700010408, distribuidos en 23, 12, 12, 17, 52, 5, 13 y 9 entradas por escena. Estos registros incluyen nombres y diálogos. El campo inglés se ha recuperado/traducido desde recursos japoneses preservados; no debe confundirse automáticamente con un guion oficial inglés. Revisar el sentido y la terminología antes de publicar cada lote.

## Siguientes fases

- Siguiente bloque de diálogos identificado en el catálogo fuente: escenas 700010401–700010408 (evento del 4.º aniversario), 143 cadenas en total. Traducir por subescenas y validar cada lote; después continuar con el resto de escenas y recursos pendientes.
- Traducir habilidades, interfaz, misiones, objetos y textos de sistema mediante sus fuentes correspondientes.
- Integrar el catálogo en la generación de paquetes de datos y comprobarlo con el cliente objetivo.
- Resolver y verificar la cadena de construcción APK para la versión exacta que se vaya a distribuir.

## Criterios

- Trabajar exclusivamente en la rama `traduccion-es`; no modificar `main`.
- No sustituir ni alterar el APK original.
- No traducir identificadores ni modificar etiquetas, variables o estructura de tablas.
- Validar las fuentes, hashes y comandos antes de aceptar cada lote.
- No publicar claves, firmas ni binarios propietarios.

## Plan de APK de prueba (14-11-2026)

- Se ha documentado la secuencia de validación, compilación, firma e instalación en [PLAN_APK_PRUEBA_ES.md](PLAN_APK_PRUEBA_ES.md).
- Se ha verificado que la localización se integra en `source/exvius/fill_content_from_memorial.py` durante la generación de paquetes CPK; no basta con editar un JSON aislado.
- El proceso de distribución existente está en `source/exvius/build_distribution.ps1` y requiere Windows, Java 11, Python 3.10, Node.js, Android SDK platform 33/build-tools 36.0.0, Gradle 7.6.4, apktool 3.0.3, Frida Gadget 17.24.3 arm64 y dependencias auxiliares.
- Bloqueo de compilación verificado: no están versionados en el repositorio `repository snapshots/FFBE-Global-v9.0.0-original.apk` ni `tools/vendor/`. Se necesita el APK original autorizado que coincida con el SHA-256 fijado en `source/exvius/android_build.py`, y las herramientas externas locales. No se afirma que exista una APK española compilada.
- La APK de prueba debe usar el identificador separado `com.exvius.offline.test`, conservar la APK original instalada y firmarse con un keystore de pruebas propio. No subir APK original, keystore, contraseñas ni binarios propietarios.
- Próximo trabajo de traducción: revisar y traducir por subescenas las 143 entradas 700010401–700010408 antes de incorporarlas al catálogo aceptado. La fuente inglesa recuperada desde japonés requiere revisión semántica.


## Preparación de compilación local (14-11-2026)

- Se verificó el APK original aportado por Juanjo: SHA-256 `955deacfbe4b3d0cd04e2947eb005e310915ba98132d71216626bfb3554ad246`; coincide con el hash fijado por `android_build.py`.
- Se añadió `tools/build_spanish_test_apk.ps1` para automatizar el staging del APK, las dos decodificaciones apktool (cliente sin smali y código smali), la reparación de CPK con el catálogo español, la regeneración de paquetes, las pruebas, la compilación y la firma local.
- Se documentó su uso y los recursos locales que faltan en `docs/PLAN_APK_PRUEBA_ES.md`.
- La APK todavía no está compilada ni instalada. El entorno de esta sesión no es Windows y no dispone de las herramientas privadas ignoradas por Git ni de los datos fuente locales completos. El lanzador requiere esos recursos en un Windows preparado y no publica los paquetes de datos por sí solo.

- Se añadió `tools/prepare_android_build_dependencies.ps1` para preparar localmente apktool 3.0.3 (con SHA verificado), Frida Gadget 17.24.3 arm64, frida-compile 19.1.0 y CriCodecs 1.2.0. Sigue siendo necesario el SDK Android y disponer del conjunto de datos fuente.
