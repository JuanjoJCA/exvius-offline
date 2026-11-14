# Decisiones del proyecto de traducción española

## 2026-11-14 — Inicio de la rama de trabajo

- Se crea la rama `traduccion-es` desde `main`. La rama `main` no se modifica.
- La APK conservada en el repositorio es la fuente de análisis inicial. El workflow no modifica, reemplaza ni vuelve a firmar ese archivo.
- El manifiesto `data/latest.json` declara una APK de versión 0.1.31 y paquetes de datos separados, pero el directorio `release/` del fork contiene APK versionadas hasta 0.1.25. Para evitar mezclar versiones, la Fase 1 analiza únicamente la APK que ya está versionada en `release/`.
- El README de `source/` documenta un requisito de compilación distinto: APK original Global v9.0.0 con SHA-256 `955deacfbe4b3d0cd04e2947eb005e310915ba98132d71216626bfb3554ad246`, además de herramientas externas. No se asumirá que la APK comunitaria equivale a ese cliente original.
- No se presume que el juego use Unity. El análisis comprueba firmas conocidas de Unity y formatos legibles/comprimidos; los formatos CPK/MST documentados en el código se investigarán por separado.
- La descarga y extracción de los 17,8 GB de datos queda fuera del primer análisis. Se estudiarán después los paquetes selectivamente y se validarán sus SHA-256 antes de extraerlos.
- La firma de una APK modificada requiere una clave propia. No se genera ni se sube ninguna clave privada al repositorio durante la Fase 1.


## 2026-11-14 — Estrategia de idioma y primer inyector español

- El contrato del cliente v9.0.0 documenta que solicita `LANGUAGE_ENGLISH`; las tablas CPK `_sg.txt` conservan ocho columnas EN/ZH/KO/FR/DE/ES/TH/ID.
- Para que el cliente existente muestre español sin cambiar su selector interno, el inyector sustituye únicamente la primera celda (EN) por una traducción española revisada. No se escribe en la columna ES, que el cliente no está solicitando.
- Se añade `source/server/content/dialogue_es.json`, indexado por SHA-256 del texto inglés exacto. El inyector verifica origen, etiquetas de control y separadores antes de escribir.
- Se añaden pruebas independientes de las dependencias nativas y un workflow de GitHub Actions. El workflow ha validado correctamente el catálogo inicial.
- El primer lote contiene 35 diálogos del prólogo y el primer encuentro con Ifrit; todas las fuentes inglesas se verificaron contra el catálogo aceptado y los comandos de control se comparan en CI. Es una prueba de integración, no una cobertura funcional amplia.
- La compilación final sigue bloqueada hasta resolver la discrepancia entre el APK comunitario analizado (v0.1.25) y los requisitos de compilación documentados para el cliente Global original v9.0.0, así como las herramientas externas y la clave de firma local.

- Los paquetes de datos grandes no están incluidos en el árbol Git: `data/README.md` indica que se descargan desde las releases. Se prioriza un overlay incremental y selectivo; no se descargará el conjunto completo de datos sin necesidad.
