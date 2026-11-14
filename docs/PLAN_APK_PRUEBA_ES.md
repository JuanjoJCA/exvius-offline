# Plan de APK de prueba en español

## Objetivo

Generar una APK Android de prueba instalable en paralelo a la aplicación original, con el catálogo español integrado en los paquetes CPK que consume el cliente Global v9.0.0. Esta compilación no es una distribución pública ni sustituye a la APK original.

## Estado verificado del repositorio

- Rama de trabajo: `traduccion-es`.
- Catálogo revisado: `source/server/content/dialogue_es.json` (166 entradas).
- Integración: `source/exvius/fill_content_from_memorial.py` aplica `apply_spanish_dialogue` al generar paquetes localizados.
- Pruebas: `tools/test_spanish_localizer.py` comprueba hashes, comandos, columnas CPK y rechazo de traducciones que alteran la estructura.
- Compilador de cliente: `source/exvius/android_build.py`.
- Orquestación de distribución existente: `source/exvius/build_distribution.ps1`.
- Entorno descrito por el proyecto: Windows, Java 11, Python 3.10, Node.js, Android SDK platform 33, build-tools 36.0.0, Gradle 7.6.4, apktool 3.0.3 y Frida Gadget 17.24.3 arm64.
- El script exige el APK Global v9.0.0 original con SHA-256 `955deacfbe4b3d0cd04e2947eb005e310915ba98132d71216626bfb3554ad246`, además de herramientas externas en `tools/vendor/` y un almacén de firma propio.

## Bloqueos previos a la compilación

El repositorio no contiene `repository snapshots/FFBE-Global-v9.0.0-original.apk` ni `tools/vendor/`. Tampoco debe subirse al repositorio el APK original, las herramientas de terceros empaquetadas, el almacén de claves ni contraseñas. Por tanto, el código permite definir el proceso, pero no se puede afirmar que la APK esté compilada hasta disponer de esos componentes localmente y ejecutar todas las verificaciones.

## Secuencia de construcción

1. Preparar una copia de trabajo limpia de esta rama en Windows. No modificar `main`.
2. Colocar localmente el APK original autorizado en `repository snapshots/FFBE-Global-v9.0.0-original.apk` y comprobar el SHA-256 exacto indicado arriba.
3. Instalar las versiones de herramientas enumeradas en `source/README.md` y ubicar las dependencias externas en `tools/vendor/`.
4. Configurar `JAVA_HOME`, `ANDROID_HOME` y `EXVIUS_KEYSTORE_PASSWORD`. Usar un keystore de pruebas propio y conservarlo para futuras actualizaciones de esa misma instalación.
5. Ejecutar primero las validaciones independientes:
   - `python -m py_compile source/exvius/fill_content_from_memorial.py tools/test_spanish_localizer.py`
   - `python tools/test_spanish_localizer.py`
   - `node source/exvius/test_android_display.js`
   - `node source/exvius/test_home_carousel.js`
   - `node source/exvius/test_summon_art.js`
   - `python source/exvius/test_release_data.py`
6. Ejecutar el orquestador existente, que realiza las pruebas de interfaz/datos, compila el runtime Android con el Gradle Wrapper, prepara el cliente, compila el bundle nativo, empaqueta, alinea, firma y verifica la APK: `powershell -ExecutionPolicy Bypass -File source/exvius/build_distribution.ps1 -Version 0.1.32-es-test -ClientVersion 9.0.0-es-test.1 -VersionCode 9003 -KeyStore tools/vendor/exvius-test.jks -KeyAlias exvius-test`.
7. Confirmar que `source/exvius/finalize_distribution.py` termina correctamente; revisar el manifiesto y el identificador de paquete de prueba, y calcular SHA-256 del APK resultante.
8. Instalar en un dispositivo Android arm64 sin desinstalar ni sobrescribir la app original. El cliente de prueba cambia el identificador de paquete a `com.exvius.offline.test`, lo que permite mantener ambas instalaciones separadas.
9. Probar arranque, descarga/preparación de datos, prólogo, diálogos de Ifrit, nombres de personajes, textos de mapa, saltos de línea y comandos de diálogo. Registrar capturas y errores de Logcat antes de ampliar la cobertura.

## Criterios de aceptación

- Todas las pruebas automatizadas anteriores terminan correctamente.
- El APK se instala y arranca en un dispositivo arm64.
- La APK original y sus datos permanecen intactos.
- Los diálogos traducidos aparecen en pantalla y conservan tiempos, nombres, saltos y comandos.
- Los textos sin traducción permanecen en el idioma de origen; no se rellenan con traducciones inventadas.
- Se publica el APK de prueba como artefacto privado/temporal de CI o se conserva localmente; nunca se publica una clave de firma ni el APK original.

## Siguiente lote de traducción

El catálogo de recuperación identifica 143 registros para las escenas `700010401–700010408`. Parte del inglés procede de recursos japoneses preservados y no debe tratarse como guion inglés oficial. Traducir por subescenas, cotejar el sentido con el material fuente disponible, mantener la terminología del juego y ejecutar las pruebas del inyector tras cada lote. No incorporar estas cadenas al catálogo aceptado hasta completar esa revisión.
