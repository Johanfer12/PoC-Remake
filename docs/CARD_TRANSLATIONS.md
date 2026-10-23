# Improved card translations

The launcher setting `improved_card_texts` is optional and defaults to `false`.
It covers Spanish (`spa`) card names and descriptions for all **771 catalog
cards** in Yugi, Kaiba and Joey, including alternate internal card identities.
It affects text displayed through `CardDB.text()`; menus, card art, voices,
effect implementations, rules, imported resources and saved decks are unchanged.
Other languages retain their imported text and existing fallback behavior.

This is a community translation improvement with project-authored historical
adaptations. It is not an official Konami translation pack or a claim of
certification by the original publisher.

## Public sources and local preparation

- [YAML Yugi](https://github.com/DawnbrandBots/yaml-yugi) supplies public card
  identity metadata and multilingual text. The launcher downloads its aggregate
  [cards.json](https://dawnbrandbots.github.io/yaml-yugi/cards.json), approximately
  **110 MB**, once to prepare the local Spanish pack.
- [CDBEsp](https://github.com/ryoken08/CDBEsp) was used during research and
  comparison to obtain Spanish wording for the full catalog and identify
  historical discrepancies. The launcher does not require downloading its
  SQLite database. Gaps in YAML Yugi use project-authored adaptations.
- The [YGOPRODeck API](https://ygoprodeck.com/api-guide/) helped establish the
  mapping between legacy game identities and public card identifiers.

These are public community sources; their text is not presented as independently
verified official Spanish. Some source entries contain modern errata or community
annotations. The reviewed mapping selects equivalent wording and uses adaptations
where necessary to preserve the historical effect.

The checked-in `game/translations/spanish-card-catalog.json` contains card identity
metadata, approved hashes and the project's own wording adaptations. It does not
bundle the downloaded community database. Card text and artwork retain their
respective rights; the source repositories' software licenses do not relicense
the original card text.

Preparation starts only when the user explicitly enables the option. Startup
reads the existing cache without starting a download, even if the preference
is enabled. The prepared pack lives in
`PoC Data/translations/cards-spa.json`, travels with the portable folder and works
offline. Preparation validates the card identities and approved text before use.
Network failures, malformed data or mismatched imported cards retain the imported
text. Disabling the option restores imported wording immediately. Imported game
files are neither overwritten nor uploaded.

## Historical effect wording

Current card databases can describe effects with errata introduced after Power
of Chaos. Replacing every description indiscriminately could misrepresent the
original rules. The review therefore compares each candidate against the imported
historical English description:

- Equivalent current wording can be used after reviewing costs, timing, targets,
  optionality, numeric values and Summoning restrictions.
- Historical Spanish references are compared where available.
- Project-authored Spanish adaptations preserve the historical English when the
  available wording changes an effect, omits a required condition, contains
  obvious translation errors or is missing.
- Modern once-per-turn restrictions, activation locks, changed battle positions
  and other errata are not added merely because a current database includes them.
- Community annotations about current OCG functionality are not displayed as part
  of a historical card description.

Coverage means 771 names and 771 descriptions are available in the prepared pack.
It does not certify every implementation of every effect. An imported card must
still match the expected legacy identity and description hash before the text
is applied; incompatible editions safely retain their imported wording.

## Regression checks

`game/tests/card_translations_test.gd` requires an isolated `--storage=` directory.
It uses synthetic text and scripted transport fixtures to check the default-off
preference, Spanish-only behavior, fallbacks, cache and identity rejection,
preservation of imported card data and startup without network requests. Bulk
checks include exact approved hashes, duplicate public IDs mapped to alternate
internal IDs, historical overrides, worker preparation, request reuse, failure
rollback and preservation of existing cached text. It does not download card
databases or store source card text as test fixtures.

Run from the PC repository root:

```powershell
. ..\ENTORNO.ps1
& '..\Herramientas\Godot\godot_console.exe' --headless --path game --script res://tests/card_translations_test.gd -- --storage=<isolated-folder>
```

Success requires a zero process exit code as well as the final PASS message.
The launcher integration is covered separately by `launcher_settings_test.gd`.
`tools/tests/test_reviewed_card_pack.py` checks that effect differences require
review, missing Spanish fields are rejected, both displayed fields receive exact
hashes, historical adaptations override changed source effects and downloaded
source text stays out of the public catalog.

Local full-pack validation checks every catalog identity and both Spanish fields.
The integration smoke accepts `--bulk-input=<local-cards.json>` to exercise real
worker preparation and cache saving with the downloaded aggregate, without
network requests; a frame heartbeat checks that the scene loop keeps advancing.
The downloaded source and prepared cache remain local artifacts rather than
public source files.
