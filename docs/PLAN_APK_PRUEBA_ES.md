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

El repositorio sí contiene APKs anteriores del producto Exvius Offline en `release/` y publica actualmente la versión v0.1.31 (build 9072), pero ese binario ya es una aplicación modificada y no sustituye al APK Global v9.0.0 original que exige `android_build.py`. No están versionados `repository snapshots/FFBE-Global-v9.0.0-original.apk` ni `tools/vendor/`. Tampoco debe subirse al repositorio el APK original, las herramientas de terceros empaquetadas, el almacén de claves ni contraseñas. La APK v0.1.31 publicada no contiene esta nueva integración española y no debe presentarse como APK traducida. Por tanto, no se puede afirmar que la APK española esté compilada hasta disponer del cliente original exacto y las dependencias locales, y ejecutar todas las verificaciones.

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


## Lanzador automatizado de Windows (14-11-2026)

Se ha añadido `tools/build_spanish_test_apk.ps1`. El lanzador verifica el hash del APK, prepara las dos decodificaciones necesarias (recursos y smali), aplica los diálogos españoles a los CPK, regenera los paquetes de datos, ejecuta pruebas, compila el runtime, empaqueta, firma y verifica la APK.

Desde la raíz de una copia limpia de `traduccion-es`, en Windows:

```powershell
powershell -ExecutionPolicy Bypass -File tools/build_spanish_test_apk.ps1 -OriginalApk "C:\ruta\FFEXVIUS-9.0.0.apk"
```

El lanzador no descarga herramientas de terceros. Antes de ejecutarlo deben estar instalados los requisitos de `source/README.md` y existir los siguientes recursos locales, excluidos de Git:

- `tools/vendor/apktool_3.0.3.jar`
- `tools/vendor/frida-gadget-17.24.3-android-arm64.so`
- `tools/vendor/android-agent/node_modules/frida-compile/dist/cli.js`
- `tools/vendor/python/cricodecs` y sus dependencias
- Android SDK platform 33 y build-tools 36.0.0
- Los datos fuente completos bajo `data/` (Memorial, caché Global, MST decodificado y overlays)

El script solicita la contraseña del keystore de pruebas y no la guarda en Git. El APK original y el keystore permanecen locales.

**Publicación pendiente:** el script regenera los paquetes de datos localizados en `source/build/distribution/assets`, pero no los publica. Para que el juego descargue los datos al arrancar, esos paquetes deben publicarse como assets de la release indicada por `-DataTag`.


### Preparación automática de dependencias auxiliares

Con Java 11, Python 3.10 y Node.js/npm ya instalados, ejecutar primero:

```powershell
powershell -ExecutionPolicy Bypass -File tools/prepare_android_build_dependencies.ps1
```

Este preparador descarga apktool 3.0.3 y verifica su SHA-256, descarga y descomprime Frida Gadget 17.24.3 arm64, instala `frida-compile` 19.1.0 y `cricodecs` 1.2.0 en `tools/vendor/`. Las versiones de apktool y Frida se corresponden con las fijadas por el proyecto; la descarga de apktool se valida contra el hash publicado en su distribución. <Cite refs="turn265394search1,turn265394search2,turn265394search11,turn120551search0,turn493374search5" />

Sigue siendo necesario instalar Android SDK platform 33 y build-tools 36.0.0, y disponer de los datos fuente completos del juego bajo `data/`. El script principal comprueba los requisitos antes de modificar o generar artefactos.
