#!/usr/bin/env python3
"""Create a reproducible structural report for an Android APK and apktool output."""
from __future__ import annotations
import argparse
import hashlib
import zipfile
from collections import Counter, defaultdict
from pathlib import Path

UNITY_MARKERS = (b"UnityFS", b"UnityWeb", b"UnityRaw", b"SerializedFile")
TEXT_EXTS = {".xml", ".json", ".txt", ".csv", ".tsv", ".html", ".js", ".css", ".properties", ".yml", ".yaml", ".ini", ".smali"}
COMPRESSED_EXTS = {".zip", ".gz", ".zst", ".lz4", ".bundle", ".ab", ".cpk", ".obb", ".pak"}

def human(n: int) -> str:
    value = float(n)
    for unit in ("B", "KB", "MB", "GB"):
        if value < 1024 or unit == "GB":
            return f"{value:.2f} {unit}"
        value /= 1024
    return str(n)

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def inventory(root: Path):
    ext, dirs, files = Counter(), defaultdict(int), []
    for p in root.rglob("*"):
        if not p.is_file():
            continue
        try:
            size = p.stat().st_size
        except OSError:
            continue
        rel = p.relative_to(root)
        ext[p.suffix.lower() or "[sin extensión]"] += 1
        dirs[rel.parts[0] if len(rel.parts) > 1 else "."] += size
        files.append((rel.as_posix(), size, p.suffix.lower()))
    return ext, dirs, files

def text_probe(data: bytes) -> bool:
    if not data or b"\x00" in data[:8192]:
        return False
    try:
        decoded = data[:8192].decode("utf-8")
    except UnicodeDecodeError:
        try:
            decoded = data[:8192].decode("utf-16")
        except UnicodeDecodeError:
            return False
    printable = sum(ch.isprintable() or ch in "\r\n\t" for ch in decoded)
    return printable / max(1, len(decoded)) > 0.88

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apk", required=True)
    ap.add_argument("--decoded", default="work/apktool-decoded")
    ap.add_argument("--apktool-status", default="no indicado")
    ap.add_argument("--output", default="docs/INFORME.md")
    args = ap.parse_args()
    apk, decoded, out = Path(args.apk), Path(args.decoded), Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# Informe de análisis del APK", "",
        f"- APK analizada: {apk}",
        f"- Tamaño: {human(apk.stat().st_size)}",
        f"- SHA-256: {sha256(apk)}",
        f"- Resultado de apktool: {args.apktool_status}", "",
        "> Este informe describe la APK comunitaria seleccionada del repositorio. No presupone que sea el cliente Global original ni que sus recursos externos estén incluidos.", ""
    ]
    raw_ext, raw_dirs = Counter(), defaultdict(int)
    unity_hits, clear_text, compressed_entries = [], [], []
    with zipfile.ZipFile(apk) as z:
        infos = [i for i in z.infolist() if not i.is_dir()]
        for info in infos:
            p = Path(info.filename)
            raw_ext[p.suffix.lower() or "[sin extensión]"] += 1
            raw_dirs[p.parts[0] if len(p.parts) > 1 else "."] += info.file_size
            if info.file_size <= 16 * 1024 * 1024:
                try:
                    head = z.read(info)[:8192]
                except Exception:
                    head = b""
                for marker in UNITY_MARKERS:
                    if marker in head:
                        unity_hits.append((info.filename, marker.decode("ascii")))
                if p.suffix.lower() in TEXT_EXTS and text_probe(head):
                    clear_text.append(info.filename)
                if p.suffix.lower() in COMPRESSED_EXTS or head.startswith((b"PK\x03\x04", b"\x1f\x8b")):
                    compressed_entries.append(info.filename)
    lines += ["## Estructura de la APK (ZIP)", "", f"- Entradas de archivo: **{len(infos)}**", "", "### Tamaño descomprimido por carpeta superior", "", "| Carpeta | Tamaño |", "|---|---:|"]
    for name, size in sorted(raw_dirs.items(), key=lambda x: x[1], reverse=True):
        lines.append(f"| {name} | {human(size)} |")
    lines += ["", "### Formatos predominantes dentro de la APK", "", "| Extensión | Archivos |", "|---|---:|"]
    for name, count in raw_ext.most_common(30):
        lines.append(f"| {name} | {count} |")
    lines += ["", "## Resultado de apktool", ""]
    if decoded.exists():
        ext, dirs, files = inventory(decoded)
        lines.append(f"- Archivos decodificados: **{len(files)}**")
        lines += ["", "### Tamaño por carpeta superior", "", "| Carpeta | Tamaño |", "|---|---:|"]
        for name, size in sorted(dirs.items(), key=lambda x: x[1], reverse=True):
            lines.append(f"| {name} | {human(size)} |")
        lines += ["", "### Formatos predominantes tras decodificar", "", "| Extensión | Archivos |", "|---|---:|"]
        for name, count in ext.most_common(30):
            lines.append(f"| {name} | {count} |")
    else:
        lines.append("No se encontró el directorio decodificado; apktool no produjo salida.")
    lines += ["", "## Diagnóstico de recursos y textos", "",
      f"- Archivos de texto legibles detectados por extensión y prueba UTF-8/UTF-16 dentro de la APK: **{len(clear_text)}**."]
    if clear_text:
        lines.append("- Muestras: " + ", ".join(clear_text[:25]))
    lines.append(f"- Entradas con extensión/formato potencialmente comprimido: **{len(compressed_entries)}**.")
    if compressed_entries:
        lines.append("- Muestras: " + ", ".join(compressed_entries[:25]))
    lines.append(f"- Firmas Unity detectadas: **{len(unity_hits)}**.")
    if unity_hits:
        lines += ["", "| Archivo | Firma |", "|---|---|"]
        for name, marker in unity_hits[:50]:
            lines.append(f"| {name} | {marker} |")
    else:
        lines.append("- No se detectaron las firmas UnityFS, UnityWeb, UnityRaw ni SerializedFile en las cabeceras inspeccionadas.")
    lines += ["", "### Conclusión provisional", "",
      "- La APK es un contenedor ZIP; eso no significa que todos los recursos internos sean texto plano.",
      "- La prueba de texto legible es heurística y no demuestra que todos los textos estén localizados.",
      "- La ausencia de firmas Unity no demuestra por sí sola que no existan recursos propietarios; deben contrastarse los formatos propios del proyecto (por ejemplo CPK y tablas MST) y los paquetes de datos externos.",
      "- Los paquetes grandes de contenido no están necesariamente incluidos en esta APK: data/latest.json los declara como descargas independientes.",
      "", "## Siguiente estrategia", "",
      "1. Analizar los paquetes de contenido declarados en data/latest.json de forma selectiva, verificando SHA-256 antes de extraerlos.",
      "2. Priorizar los formatos reconocidos por el código del proyecto: CPK, archivos *_sg.txt, tablas MST y recursos localizados.",
      "3. No modificar ni reemplazar la APK original. La extracción y las pruebas se harán sobre copias.",
      "4. La reconstrucción completa requiere además el APK Global original v9.0.0 con el SHA-256 fijado en source/README.md y herramientas externas no incluidas en el repositorio; no se debe prometer un APK idéntico hasta verificar esos requisitos.", ""]
    out.write_text("\n".join(lines), encoding="utf-8")
    print(f"Informe escrito en {out}")

if __name__ == "__main__":
    main()
