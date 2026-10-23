"""Build a reviewed local Spanish pack from previously acquired source evidence.

The evidence and downloaded card database stay outside the public source tree.
Only identities, approved text hashes and project-authored adaptations enter the
catalog. This command does not access the network.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

BULK_SOURCE = "https://dawnbrandbots.github.io/yaml-yugi/cards.json"


def digest(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def build(evidence: dict, reviews: dict, overrides: dict) -> tuple[dict, dict, dict]:
    catalog, pack, audit = {}, {}, {}
    for card_id, card in evidence.items():
        expected = dict(card["catalog"])
        source = card["yaml"]
        name = source.get("name_es") or ""
        description = source.get("description_es") or ""
        review = reviews.get(card_id)
        adaptation = ""
        reason = "Historical English matches the source, or normal-monster flavor text."
        if review:
            mode = review["mode"]
            reason = review["reason"]
            if mode == "legacy_rewrite":
                adaptation = review["description"]
            elif mode == "goat":
                adaptation = review["legacy_adaptation"]
            elif mode != "modern":
                raise ValueError(f"Unknown review mode: {card_id} {mode}")
        elif not card["modern_en_matches_legacy"]:
            # All effect differences must have an explicit review. The remaining
            # normal-monster flavor rows are recorded in the split review inputs.
            if card_id not in overrides.get("flavor_ids", []):
                raise ValueError(f"Missing semantic review: {card_id}")
        extra = overrides.get("cards", {}).get(card_id, {})
        if extra.get("name"):
            name = extra["name"]
            expected["name_override"] = name
        adaptation = extra.get("description", adaptation)
        if adaptation:
            description = adaptation
            expected["description_override"] = adaptation
        if not name.strip() or not description.strip():
            raise ValueError(f"Incomplete Spanish text: {card_id}")
        if any(token in description for token in ("\ufffd", "OCG ONLY", "[OCG", "【")):
            raise ValueError(f"Unreviewed annotation or corrupt text: {card_id}")
        expected["approved_name_sha256"] = digest(name)
        expected["approved_description_sha256"] = digest(description)
        catalog[card_id] = expected
        pack[card_id] = {
            **{key: expected[key] for key in ("cid", "password", "english_name", "legacy_description_sha256")},
            "name": name, "description": description,
            "description_verified": True, "source_url": BULK_SOURCE,
            "english_source_url": "",
        }
        audit[card_id] = {"mode": "adaptation" if adaptation else "source", "reason": extra.get("reason", reason)}
    return (
        {"format": 1, "locale": "spa", "bulk_source": BULK_SOURCE, "cards": catalog},
        {"format": 1, "locale": "spa", "cards": pack},
        {"count": len(pack), "adaptations": sum(bool(v.get("description_override")) for v in catalog.values()), "cards": audit},
    )


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes((json.dumps(data, ensure_ascii=False, indent=2) + "\n").encode("utf-8"))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--evidence", type=Path, required=True)
    parser.add_argument("--reviews", type=Path, nargs="+", required=True)
    parser.add_argument("--overrides", type=Path, required=True)
    parser.add_argument("--catalog", type=Path, required=True)
    parser.add_argument("--pack", type=Path, required=True)
    parser.add_argument("--audit", type=Path, required=True)
    args = parser.parse_args()
    read = lambda path: json.loads(path.read_text(encoding="utf-8"))
    reviews = {}
    for path in args.reviews:
        incoming = read(path)
        if reviews.keys() & incoming.keys():
            raise ValueError("Duplicate review ids")
        reviews.update(incoming)
    catalog, pack, audit = build(read(args.evidence)["cards"], reviews, read(args.overrides))
    write_json(args.catalog, catalog)
    write_json(args.pack, pack)
    write_json(args.audit, audit)
    print(f"Reviewed Spanish pack: {len(pack['cards'])} names, {len(pack['cards'])} descriptions; {audit['adaptations']} adaptations")


if __name__ == "__main__":
    main()
