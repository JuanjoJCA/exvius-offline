# Informe de análisis del APK

- APK analizada: release/exvius-offline-v0.1.25.apk
- Tamaño: 45.69 MB
- SHA-256: 3625b1e6c423d1c4dfdb54172d8f512444314bd2dd9065d67e32adb45061b531
- Resultado de apktool: success

> Este informe describe la APK comunitaria seleccionada del repositorio. No presupone que sea el cliente Global original ni que sus recursos externos estén incluidos.

## Estructura de la APK (ZIP)

- Entradas de archivo: **3627**

### Tamaño descomprimido por carpeta superior

| Carpeta | Tamaño |
|---|---:|
| assets | 67.21 MB |
| lib | 61.34 MB |
| . | 22.13 MB |
| com | 16.30 MB |
| res | 1.50 MB |
| mac-x86_64 | 1.37 MB |
| META-INF | 841.52 KB |
| windows-x86_64 | 607.50 KB |
| windows-x86 | 452.00 KB |
| org | 92.04 KB |
| okhttp3 | 33.20 KB |
| kotlin | 28.26 KB |
| junit | 1.80 KB |
| mockito-extensions | 17.00 B |

### Formatos predominantes dentro de la APK

| Extensión | Archivos |
|---|---:|
| .res | 2684 |
| .png | 400 |
| .xml | 268 |
| .version | 50 |
| .json | 43 |
| .properties | 39 |
| .kotlin_module | 27 |
| .spp | 12 |
| .brk | 9 |
| .lst | 9 |
| .tsv | 8 |
| .dex | 7 |
| .kotlin_builtins | 7 |
| .icu | 6 |
| .mf | 6 |
| .txt | 4 |
| [sin extensión] | 4 |
| .dict | 4 |
| .nrm | 4 |
| .aidl | 3 |
| .html | 2 |
| .gif | 2 |
| .proto | 2 |
| .c | 2 |
| .dll | 2 |
| .zip | 1 |
| .arsc | 1 |
| .so | 1 |
| .cfu | 1 |
| .escaped | 1 |

## Resultado de apktool

- Archivos decodificados: **28203**

### Tamaño por carpeta superior

| Carpeta | Tamaño |
|---|---:|
| assets | 67.21 MB |
| lib | 61.34 MB |
| smali_classes2 | 60.21 MB |
| smali | 59.38 MB |
| smali_classes3 | 28.62 MB |
| unknown | 18.86 MB |
| res | 2.41 MB |
| original | 857.07 KB |
| smali_classes6 | 390.38 KB |
| smali_classes4 | 174.94 KB |
| . | 152.74 KB |
| smali_classes7 | 50.79 KB |
| kotlin | 28.26 KB |
| META-INF | 240.00 B |
| smali_classes5 | 222.00 B |

### Formatos predominantes tras decodificar

| Extensión | Archivos |
|---|---:|
| .smali | 24457 |
| .res | 2684 |
| .png | 400 |
| .xml | 382 |
| .version | 50 |
| .json | 43 |
| .properties | 39 |
| .kotlin_module | 27 |
| .spp | 12 |
| .lst | 9 |
| .brk | 9 |
| .tsv | 8 |
| .kotlin_builtins | 7 |
| .mf | 6 |
| .icu | 6 |
| .txt | 4 |
| .c | 4 |
| .nrm | 4 |
| .dict | 4 |
| [sin extensión] | 4 |
| .aidl | 3 |
| .html | 2 |
| .proto | 2 |
| .threadchecker | 2 |
| .e$c | 2 |
| .controlledlooper | 2 |
| .shadowsadapter | 2 |
| .a | 2 |
| .provider | 2 |
| .d | 2 |

## Diagnóstico de recursos y textos

- Archivos de texto legibles detectados por extensión y prueba UTF-8/UTF-16 dentro de la APK: **112**.
- Muestras: res/raw/firebase_common_keep.xml, res/raw/keep_cronet_api.xml, assets/rules/assets/banner_art/index.json, assets/rules/banner_campaigns.json, assets/rules/battle_names.json, assets/rules/catchup_bonus.json, assets/rules/colosseum_encounters.json, assets/rules/colosseum_names.json, assets/rules/community_events.json, assets/rules/content/battle/F_BATTLE_GROUP_MST.tsv, assets/rules/content/battle/F_BATTLE_LOTTERY_MST.tsv, assets/rules/content/battle/F_MISSION_MST.tsv, assets/rules/content/battle/F_MISSION_PHASE_MST.tsv, assets/rules/content/battle/F_MONSTER_PARTS_MST.tsv, assets/rules/content/battle/F_MONSTER_SKILL_MST.tsv, assets/rules/content/battle/F_MONSTER_SKILL_SET_MST.tsv, assets/rules/content/battle_skill_translations.json, assets/rules/content/clash_level_rewards.json, assets/rules/content/dialogue_en.json, assets/rules/content/exbonus_masters.json, assets/rules/content/exbonus_text.json, assets/rules/content/expeditions.json, assets/rules/content/field_group_bindings.json, assets/rules/content/field_treasures.json, assets/rules/content/field_treasure_overrides.json
- Entradas con extensión/formato potencialmente comprimido: **2**.
- Muestras: res/raw/amazon_gc_prototype.zip, okhttp3/internal/publicsuffix/publicsuffixes.gz
- Firmas Unity detectadas: **0**.
- No se detectaron las firmas UnityFS, UnityWeb, UnityRaw ni SerializedFile en las cabeceras inspeccionadas.

### Conclusión provisional

- La APK es un contenedor ZIP; eso no significa que todos los recursos internos sean texto plano.
- La prueba de texto legible es heurística y no demuestra que todos los textos estén localizados.
- La ausencia de firmas Unity no demuestra por sí sola que no existan recursos propietarios; deben contrastarse los formatos propios del proyecto (por ejemplo CPK y tablas MST) y los paquetes de datos externos.
- Los paquetes grandes de contenido no están necesariamente incluidos en esta APK: data/latest.json los declara como descargas independientes.

## Siguiente estrategia

1. Analizar los paquetes de contenido declarados en data/latest.json de forma selectiva, verificando SHA-256 antes de extraerlos.
2. Priorizar los formatos reconocidos por el código del proyecto: CPK, archivos *_sg.txt, tablas MST y recursos localizados.
3. No modificar ni reemplazar la APK original. La extracción y las pruebas se harán sobre copias.
4. La reconstrucción completa requiere además el APK Global original v9.0.0 con el SHA-256 fijado en source/README.md y herramientas externas no incluidas en el repositorio; no se debe prometer un APK idéntico hasta verificar esos requisitos.
