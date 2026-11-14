#!/usr/bin/env python3
"""Dependency-free regression tests for the Spanish dialogue injector."""
import hashlib
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "source" / "exvius"))
import fill_content_from_memorial as localizer


class MemoryArchive:
    def __init__(self, payload):
        self.payload = {0: payload}

    def file_bytes(self, index):
        return self.payload[index]

    def replace_bytes(self, index, data):
        self.payload[index] = data


class SpanishDialogueTests(unittest.TestCase):
    def test_spanish_replaces_only_first_language_cell(self):
        source = "<name=300001><br>Hello, warrior!<wait=30><br>"
        spanish = "<name=300001><br>¡Hola, guerrero!<wait=30><br>"
        key = hashlib.sha256(source.encode("utf-8")).hexdigest()
        archive = MemoryArchive(
            ("210001^" + source + "^ZH^KO^FR^DE^ES^TH^ID\n").encode("utf-8")
        )
        with patch.object(localizer, "_DIALOGUE_SPANISH", {
            key: {"source": source, "spanish": spanish}
        }):
            changed = localizer.apply_spanish_dialogue(
                archive, {"123_event_text_sg.txt": 0}
            )
        self.assertEqual(changed, 1)
        self.assertEqual(
            archive.file_bytes(0).decode("utf-8"),
            "210001^" + spanish + "^ZH^KO^FR^DE^ES^TH^ID\n"
        )

    def test_unknown_source_is_left_untouched(self):
        source = "A line without a reviewed translation"
        archive = MemoryArchive(("210001^" + source + "^^^^^^^\\n").encode("utf-8"))
        with patch.object(localizer, "_DIALOGUE_SPANISH", {}):
            changed = localizer.apply_spanish_dialogue(
                archive, {"123_event_text_sg.txt": 0}
            )
        self.assertEqual(changed, 0)
        self.assertIn(source.encode("utf-8"), archive.file_bytes(0))

    def test_translation_cannot_remove_game_commands(self):
        source = "<name=300001><br>Hello!<keywait>"
        spanish = "¡Hola!"
        key = hashlib.sha256(source.encode("utf-8")).hexdigest()
        archive = MemoryArchive(
            ("210001^" + source + "^^^^^^^\n").encode("utf-8")
        )
        with patch.object(localizer, "_DIALOGUE_SPANISH", {
            key: {"source": source, "spanish": spanish}
        }):
            with self.assertRaises(ValueError):
                localizer.apply_spanish_dialogue(
                    archive, {"123_event_text_sg.txt": 0}
                )

    def test_translation_cannot_inject_table_columns_or_line_breaks(self):
        for forbidden in ("^", "\n", "\r"):
            source = "Continue?"
            spanish = "¿Continuar?" + forbidden
            key = hashlib.sha256(source.encode("utf-8")).hexdigest()
            archive = MemoryArchive(
                ("210001^" + source + "^^^^^^^\n").encode("utf-8")
            )
            with patch.object(localizer, "_DIALOGUE_SPANISH", {
                key: {"source": source, "spanish": spanish}
            }):
                with self.assertRaises(ValueError):
                    localizer.apply_spanish_dialogue(
                        archive, {"123_event_text_sg.txt": 0}
                    )


if __name__ == "__main__":
    unittest.main()
