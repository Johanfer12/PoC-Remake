"""Synthetic coverage for local official card translation acquisition."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import HTTPError

from tools.pocx.card_translations import CardPage, Fetcher, build, text_hash


class CardTranslationsTests(unittest.TestCase):
    def test_official_markup_decodes_names_and_preserves_text_breaks(self):
        parser = CardPage()
        parser.feed('''<div id="cardname"><h1>Drag&oacute;n Blanco
            <span>Blue-Eyes White Dragon</span></h1></div>
            <span class="text_linebreak">unrelated summary</span>
            <div class="item_box_text"><div class="text_title">Texto</div>
            <div class="text_linebreak">L&iacute;nea uno.<br>Línea dos.</div></div>''')
        self.assertEqual(parser.result(), {
            'name': 'Dragón Blanco', 'english_name': 'Blue-Eyes White Dragon',
            'description': 'Línea uno.\nLínea dos.',
        })

    def test_missing_card_markup_fails_closed(self):
        parser = CardPage()
        parser.feed('<h1>Access denied</h1>')
        with self.assertRaises(ValueError):
            parser.result()

    def test_cached_pack_preserves_identity_and_checks_legacy_rules(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            cache = root/'cache'
            cache.mkdir()
            cards = {}
            for number, review, english_text in ((1, True, 'Old RULES!'),
                                                  (2, False, 'Old rules.'),
                                                  (3, True, 'Changed rules.'),
                                                  (4, True, None)):
                cards[str(number)] = {
                    'cid': number, 'password': f'{number:08}',
                    'english_name': f'Legacy {number}',
                    'legacy_description_sha256': text_hash('Old rules.'),
                    'review_description': review,
                }
                spanish = {'name': f'Carta {number}', 'description': f'Texto {number}',
                           'english_name': f'Renamed {number}', 'cid': number,
                           'locale': 'es', 'source_url': f'https://official/{number}/es'}
                (cache/f'{number}-es.json').write_text(json.dumps(spanish), encoding='utf-8')
                if english_text is not None:
                    english = dict(spanish, description=english_text,
                                   locale='en',
                                   source_url=f'https://official/{number}/en')
                    (cache/f'{number}-en.json').write_text(json.dumps(english), encoding='utf-8')
            catalog = root/'catalog.json'
            catalog.write_text(json.dumps({'cards': cards}), encoding='utf-8')
            output = root/'pack.json'
            with contextlib.redirect_stdout(io.StringIO()):
                result = build(catalog, output, cache, workers=1, offline=True)
            self.assertEqual(result, 0)
            packed = json.loads(output.read_text(encoding='utf-8'))['cards']
            self.assertEqual(packed['1']['description'], 'Texto 1')
            for key in ('2', '3', '4'):
                self.assertEqual(packed[key]['description'], '')
                self.assertFalse(packed[key]['description_verified'])
            for key, entry in packed.items():
                self.assertEqual(entry['password'], cards[key]['password'])
                self.assertEqual(entry['english_name'], cards[key]['english_name'])
                self.assertEqual(entry['official_english_name'], f'Renamed {key}')

    def test_access_denial_halts_all_subsequent_network_requests(self):
        for status in (403, 429):
            with self.subTest(status=status), tempfile.TemporaryDirectory() as folder:
                fetcher = Fetcher(Path(folder))
                denial = HTTPError('https://official/', status, 'Denied', {}, None)
                with patch('tools.pocx.card_translations.urlopen', side_effect=denial) as opened:
                    with self.assertRaisesRegex(RuntimeError, str(status)):
                        fetcher.fetch(1, 'es')
                    with self.assertRaisesRegex(RuntimeError, 'denied access'):
                        fetcher.fetch(2, 'es')
                    self.assertEqual(opened.call_count, 1)
                    self.assertEqual(fetcher.requests, 1)

    def test_offline_never_opens_network(self):
        with tempfile.TemporaryDirectory() as folder:
            with patch('tools.pocx.card_translations.urlopen') as opened:
                with self.assertRaises(FileNotFoundError):
                    Fetcher(Path(folder), offline=True).fetch(1, 'es')
                opened.assert_not_called()

    def test_mismatched_cached_cid_is_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root/'1-es.json').write_text(json.dumps({'cid': 2, 'locale': 'es'}), encoding='utf-8')
            with patch('tools.pocx.card_translations.urlopen') as opened:
                with self.assertRaisesRegex(ValueError, 'identity'):
                    Fetcher(root, offline=True).fetch(1, 'es')
                opened.assert_not_called()


if __name__ == '__main__':
    unittest.main()
