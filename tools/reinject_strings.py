#!/usr/bin/env python3
"""Reinject translated JSON strings into a decoded APK tree, preserving other values."""
import argparse
import json
from pathlib import Path

def resolve_parent(root, pointer):
    parts = pointer.split("/")[1:] if pointer else []
    parts = [p.replace("~1", "/").replace("~0", "~") for p in parts]
    cur = root
    for part in parts[:-1]:
        cur = cur[int(part)] if isinstance(cur, list) else cur[part]
    return cur, parts[-1] if parts else None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default="work/apktool-decoded/assets")
    ap.add_argument("--translations", default="strings/es.json")
    ap.add_argument("--output", default="work/apktool-translated/assets")
    args = ap.parse_args()
    root, output = Path(args.root), Path(args.output)
    payload = json.loads(Path(args.translations).read_text(encoding="utf-8"))
    grouped = {}
    for row in payload.get("strings", []):
        translated = row.get("es", "")
        if translated:
            grouped.setdefault(row["source"], []).append((row["pointer"], translated))
    changed = 0
    for rel, edits in grouped.items():
        source = root / rel
        if not source.is_file():
            raise FileNotFoundError(f"Falta el recurso original: {source}")
        data = json.loads(source.read_text(encoding="utf-8"))
        for pointer, translated in edits:
            parent, key = resolve_parent(data, pointer)
            old = parent[int(key)] if isinstance(parent, list) else parent[key]
            if not isinstance(old, str):
                raise TypeError(f"El destino dejó de ser texto: {rel} {pointer}")
            if isinstance(parent, list):
                parent[int(key)] = translated
            else:
                parent[key] = translated
            changed += 1
        target = output / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(data, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Cadenas reinyectadas: {changed}; archivos modificados: {len(grouped)}")

if __name__ == "__main__":
    main()
