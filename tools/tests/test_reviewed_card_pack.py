"""Synthetic historical-review and public-catalog boundary checks; no downloads."""
import copy
import hashlib
import unittest

from tools.pocx.reviewed_card_pack import BULK_SOURCE, build


class ReviewedCardPackTests(unittest.TestCase):
    def setUp(self):
        self.evidence = {"7": {
            "catalog": {"cid": 99, "password": "00000007",
                        "english_name": "Synthetic Beast",
                        "legacy_description_sha256": "historical-hash"},
            "yaml": {"name_es": "Bestia de prueba", "description_es": "Texto de prueba."},
            "modern_en_matches_legacy": True,
        }}

    def test_approved_hashes_bind_both_displayed_fields_and_keep_source_out_of_catalog(self):
        before = copy.deepcopy(self.evidence)
        catalog, pack, audit = build(self.evidence, {}, {})
        expected, displayed = catalog["cards"]["7"], pack["cards"]["7"]
        for field in ("name", "description"):
            self.assertEqual(expected[f"approved_{field}_sha256"],
                             hashlib.sha256(displayed[field].encode("utf-8")).hexdigest())
            self.assertNotIn(field, expected)
        self.assertEqual(displayed["source_url"], BULK_SOURCE)
        self.assertTrue(displayed["description_verified"])
        self.assertEqual(displayed["english_name"], "Synthetic Beast")
        self.assertEqual(audit["count"], 1)
        self.assertEqual(self.evidence, before)

    def test_changed_historical_effect_requires_explicit_semantic_review(self):
        self.evidence["7"]["modern_en_matches_legacy"] = False
        with self.assertRaisesRegex(ValueError, "Missing semantic review: 7"):
            build(self.evidence, {}, {})
        build(self.evidence, {"7": {"mode": "modern", "reason": "Equivalent timing and cost."}}, {})

    def test_missing_field_never_produces_an_incomplete_ready_pack(self):
        for field in ("name_es", "description_es"):
            with self.subTest(field=field):
                incomplete = copy.deepcopy(self.evidence)
                incomplete["7"]["yaml"][field] = " "
                with self.assertRaisesRegex(ValueError, "Incomplete Spanish text: 7"):
                    build(incomplete, {}, {})

    def test_historical_adaptation_overrides_changed_effect_and_hashes_exact_text(self):
        self.evidence["7"]["modern_en_matches_legacy"] = False
        self.evidence["7"]["yaml"]["description_es"] = "Nuevo efecto, una vez por turno."
        historical = "Puedes descartar esta carta para robar 1 carta."
        for mode, key in (("legacy_rewrite", "description"), ("goat", "legacy_adaptation")):
            with self.subTest(mode=mode):
                catalog, pack, audit = build(self.evidence,
                    {"7": {"mode": mode, key: historical, "reason": "Preserve original effect."}}, {})
                self.assertEqual(pack["cards"]["7"]["description"], historical)
                self.assertEqual(catalog["cards"]["7"]["description_override"], historical)
                self.assertEqual(audit["adaptations"], 1)

    def test_missing_source_text_can_use_project_authored_gap_adaptation(self):
        self.evidence["7"]["yaml"] = {}
        catalog, pack, audit = build(self.evidence, {}, {"cards": {"7": {
            "name": "Nombre de prueba", "description": "Efecto histórico de prueba.",
            "reason": "No Spanish source entry."}}})
        self.assertEqual(pack["cards"]["7"]["name"], "Nombre de prueba")
        self.assertEqual(catalog["cards"]["7"]["name_override"], "Nombre de prueba")
        self.assertEqual(audit["cards"]["7"]["reason"], "No Spanish source entry.")

    def test_corrupt_or_unreviewed_annotation_is_rejected(self):
        for text in ("Texto \ufffd", "[OCG ONLY] Texto", "【Nota】 Texto"):
            with self.subTest(text=text):
                self.evidence["7"]["yaml"]["description_es"] = text
                with self.assertRaisesRegex(ValueError, "Unreviewed annotation or corrupt text"):
                    build(self.evidence, {}, {})


if __name__ == "__main__":
    unittest.main()
