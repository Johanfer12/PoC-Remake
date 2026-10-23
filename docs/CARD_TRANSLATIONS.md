# Improved card translations

The launcher setting `improved_card_texts` is optional and defaults to `false`.
It affects card names and descriptions displayed through `CardDB.text()` only.
It does not change menus, card effects, rules, imported resources or saved decks.
The first supported language is Spanish (`spa`); other languages retain their
usual imported text and fallback behavior.

## Source and local storage

The checked-in `game/translations/spanish-card-catalog.json` contains identity
metadata, source references and hashes, not the downloaded Spanish card text.
Official card IDs are matched to game internal IDs using card passwords and
legacy English names. Identity metadata comes from the
[YGOPRODeck API](https://ygoprodeck.com/api-guide/); displayed Spanish text is
fetched from the [official Konami card database](https://www.db.yugioh-card.com/yugiohdb/).

Explicitly enabling the option downloads available entries into
`PoC Data/translations/cards-spa.json`. The local cache accompanies the portable
folder and supports offline play. Network errors or missing entries fall back
to imported text; disabling the option restores the imported wording immediately.
The download does not upload imported cards or game files. Startup reads the
cache without starting network requests, even if the preference is enabled.
Missing or malformed individual pages do not prevent later cards from being
considered. HTTP 403 or 429 stops the entire batch and preserves existing entries;
retrying requires an explicit toggle after waiting for server availability.
A name whose English description verification failed remains available and its
description can be retried later.

Initial local coverage is **110 official Spanish names and 38 verified
descriptions** out of 771 catalog cards. This is a partial development result;
server access limits prevented completing the batch. The downloaded cache is
local data, not text bundled in the public source or a guarantee of full coverage.

## Historical effect wording

The current official database can describe effects with errata introduced after
Power of Chaos. Replacing every description with today's text could misrepresent
the engine's implemented rules. For that reason:

- Names can use the official Spanish name after identity validation.
- Descriptions require a catalog review candidate and a matching normalized
  English description hash for the game's historical description.
- Both official pages are requested by the catalog card ID; the imported card
  must match its expected password, legacy English name and description hash.
  Current official names can differ from historical names. Cache entries record
  their source URLs and verification state.
- Cards without a verified description keep their imported description. This is
  partial description coverage, not a claim that every card has been reviewed.

No machine-generated replacement descriptions are included. Card art, voice
packs and other menu languages are outside this option.

## Regression checks

`game/tests/card_translations_test.gd` uses synthetic card text and synthetic
HTML; it requires an isolated `--storage=` directory. It checks default-off and
Spanish-only behavior, per-field fallback, cache and identity rejection,
description verification, HTML parsing and preservation of imported card data.
It does not fetch card pages or store official text as a repository fixture.

Run from the repository root with the configured Godot executable:

```powershell
. ..\ENTORNO.ps1
& '..\Herramientas\Godot\godot_console.exe' --headless --path game --script res://tests/card_translations_test.gd -- --storage=<isolated-folder>
```

Success requires a zero process exit code as well as the final PASS message.
The launcher integration is covered separately by `launcher_settings_test.gd`.
