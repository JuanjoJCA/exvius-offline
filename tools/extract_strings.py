#!/usr/bin/env python3
"""Extract translatable JSON string values without changing source resources."""
import argparse
import hashlib
import json
from pathlib import Path

def walk(value, pointer=""):
    if isinstance(value, str):
        yield pointer, value
    elif isinstance(value, list):
        for i, item in enumerate(value):
            yield from walk(item, f"{pointer}/{i}")
    elif isinstance(value, dict):
        for key, item in value.items():
            escaped = str(key).replace("~", "~0").replace("/", "~1")
            yield from walk(item, f"{pointer}/{escaped}")

def stable_id(path, pointer):
    raw = f"{path}\0{pointer}".encode("utf-8")
    return hashlib.sha256(raw).hexdigest()[:20]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default="work/apktool-decoded/assets")
    ap.add_argument("--out", default="strings")
    args = ap.parse_args()
    root, out = Path(args.root), Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    records = []
    scanned = 0
    for path in sorted(root.rglob("*.json")):
        try:
            raw = path.read_text(encoding="utf-8")
            data = json.loads(raw)
        except (OSError, UnicodeError, json.JSONDecodeError):
            continue
        scanned += 1
        rel = path.relative_to(root).as_posix()
        for pointer, text in walk(data):
            if not text.strip():
                continue
            records.append({
                "id": stable_id(rel, pointer),
                "source": rel,
                "pointer": pointer,
                "en": text,
                "es": ""
            })
    payload = {"schema": 1, "source_root": "assets", "files_scanned": scanned,
               "strings_count": len(records), "strings": records}
    (out / "en.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    es = {**payload, "strings": [{**r, "es": ""} for r in records]}
    (out / "es.json").write_text(json.dumps(es, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"JSON analizados: {scanned}; cadenas extraídas: {len(records)}")

if __name__ == "__main__":
    main()
