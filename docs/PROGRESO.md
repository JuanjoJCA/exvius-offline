# Progreso de la traducción española

## Estado actual

- Fase 1 — análisis del APK: completada. APK v0.1.25 decodificada correctamente con apktool.
- Fase 2 — inventario inicial: extracción completada como artefacto de GitHub Actions. Se analizaron 43 archivos JSON y se recogieron 1.691.933 valores de texto.
- El catálogo completo se conserva como artefacto de la ejecución [43623959118](https://github.com/JuanjoJCA/exvius-offline/actions/runs/43623959118), no dentro de Git, porque el JSON generado supera el límite de 100 MB por archivo.
- Importante: el inventario incluye todos los valores de tipo cadena de esos JSON; todavía no equivale a 1.691.933 frases traducibles. Hay que clasificar y filtrar identificadores, datos técnicos, nombres, diálogos y textos visibles.
- Cobertura actual: solo JSON. No se han inventariado todavía otros formatos de recursos del juego.

## Siguientes fases

- Fase 2b — clasificación: identificar los archivos y campos que contienen texto visible y priorizar diálogos, misiones, habilidades e interfaz.
- Fase 3 — traducción: todavía no iniciada. No se declara porcentaje de traducción.
- Fase 4 — reinyección y construcción: todavía no iniciada. El APK original permanece intacto.

## Criterios

- Trabajar exclusivamente en la rama `traduccion-es`; no modificar `main`.
- No sustituir ni alterar el APK original.
- Validar etiquetas, marcadores y variables antes de reintegrar traducciones.
- No publicar claves, firmas ni binarios propietarios.
