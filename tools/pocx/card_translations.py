"""Preparar un paquete español local desde la fuente comunitaria revisada.

Los textos descargados permanecen locales. El catálogo fija sus hashes y adapta
las reglas modernas al inglés histórico. Se conserva el lector antiguo para
catálogos anteriores y pruebas, sin usarlo para el catálogo comunitario actual.
"""
from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import hashlib
import gzip
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import threading
import time
from urllib.request import Request, urlopen
from urllib.error import HTTPError


def text_hash(text: str) -> str:
    return hashlib.sha256(" ".join(re.findall(r"[a-z0-9]+", text.lower())).encode()).hexdigest()


class CardPage(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.name_parts = []
        self.description_parts = []
        self.identity_parts = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "br":
            if any(x[1] == "description" for x in self.stack):
                self.description_parts.append("\n")
            return
        if tag in {"img", "meta", "input", "link", "hr", "source", "wbr"}:
            return
        mode = ""
        if attrs.get("id") == "cardname":
            mode = "cardname"
        elif tag == "span" and any(x[1] == "cardname" for x in self.stack):
            mode = "identity"
        elif "item_box_text" in attrs.get("class", "").split():
            mode = "text_box"
        elif "text_linebreak" in attrs.get("class", "").split() and any(x[1] == "text_box" for x in self.stack):
            mode = "description"
        self.stack.append((tag, mode))

    def handle_endtag(self, tag):
        for index in range(len(self.stack) - 1, -1, -1):
            if self.stack[index][0] == tag:
                del self.stack[index:]
                break

    def handle_data(self, data):
        modes = {x[1] for x in self.stack}
        if "cardname" in modes:
            (self.identity_parts if "identity" in modes else self.name_parts).append(data)
        if "description" in modes:
            self.description_parts.append(data)

    def result(self):
        name = " ".join("".join(self.name_parts).split())
        identity = " ".join("".join(self.identity_parts).split())
        description = "\n".join(" ".join(line.split()) for line in "".join(self.description_parts).splitlines()).strip()
        if not name or not description:
            raise ValueError("Official page does not contain a card name and description")
        return {"name": name, "english_name": identity, "description": description}


class Fetcher:
    def __init__(self, cache: Path, offline: bool = False):
        self.cache = cache
        cache.mkdir(parents=True, exist_ok=True)
        self.lock = threading.Lock()
        self.next_request = 0.0
        self.requests = 0
        self.offline = offline
        self.blocked = threading.Event()

    def fetch(self, cid: int, locale: str):
        target = self.cache / f"{cid}-{locale}.json"
        if target.exists():
            cached = json.loads(target.read_text(encoding="utf-8"))
            if cached.get("cid") != cid or cached.get("locale") != locale:
                raise ValueError("Cached official page identity does not match its requested CID/locale")
            if not all(isinstance(cached.get(key), str) and cached[key].strip()
                       for key in ("name", "description", "source_url")):
                raise ValueError("Cached official page is missing card text/provenance")
            return cached
        if self.offline:
            raise FileNotFoundError(f"No cached official {locale} page for CID {cid}")
        url = f"https://www.db.yugioh-card.com/yugiohdb/card_search.action?ope=2&cid={cid}&request_locale={locale}"
        for attempt in range(3):
            try:
                with self.lock:
                    if self.blocked.is_set():
                        raise RuntimeError("Official database denied access; downloading stopped")
                    delay = max(0.0, self.next_request - time.monotonic())
                    if delay:
                        time.sleep(delay)
                    self.next_request = time.monotonic() + 0.52
                    self.requests += 1
                request = Request(url, headers={"User-Agent": "PowerOfChaos-LocalCardTranslations/1.0",
                                                "Accept-Encoding": "gzip"})
                with urlopen(request, timeout=45) as response:
                    page = response.read(2_000_001)
                    compressed = response.headers.get("Content-Encoding") == "gzip"
                if len(page) > 2_000_000:
                    raise ValueError("Official page exceeds size limit")
                if compressed:
                    import io
                    with gzip.GzipFile(fileobj=io.BytesIO(page)) as stream:
                        page = stream.read(2_000_001)
                    if len(page) > 2_000_000:
                        raise ValueError("Decompressed official page exceeds size limit")
                parser = CardPage()
                parser.feed(page.decode("utf-8"))
                result = parser.result()
                result.update(cid=cid, locale=locale, source_url=url)
                target.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
                return result
            except HTTPError as error:
                if error.code in (403, 429):
                    self.blocked.set()
                    raise RuntimeError(f"Official database returned HTTP {error.code}; downloading stopped") from error
                if attempt == 2:
                    raise
                time.sleep(2 ** attempt)
            except Exception:
                if self.blocked.is_set():
                    raise
                if attempt == 2:
                    raise
                time.sleep(2 ** attempt)


def build_bulk(source: dict, output: Path, cache: Path, offline: bool):
    """Una descarga comunitaria; aceptar solo los textos previamente revisados."""
    url = source["bulk_source"]
    if url != "https://dawnbrandbots.github.io/yaml-yugi/cards.json":
        raise ValueError("Unrecognized community source")
    cache.mkdir(parents=True, exist_ok=True)
    local = cache / "yaml-yugi-cards.json"
    if not local.exists():
        if offline:
            raise FileNotFoundError(local)
        request = Request(url, headers={"User-Agent": "PowerOfChaos-CardTranslations/2.0", "Accept": "application/json"})
        with urlopen(request, timeout=120) as response:
            payload = response.read(160 * 1024 * 1024 + 1)
        if len(payload) > 160 * 1024 * 1024:
            raise ValueError("Community database exceeds size limit")
        local.write_bytes(payload)
    rows = json.loads(local.read_text(encoding="utf-8"))
    if not isinstance(rows, list):
        raise ValueError("Invalid community database")
    wanted = {int(meta["cid"]) for meta in source["cards"].values()}
    by_cid = {int(row["konami_id"]): row for row in rows if row.get("konami_id") in wanted}
    entries = {}
    for card_id, metadata in source["cards"].items():
        row = by_cid.get(int(metadata["cid"]), {})
        name = metadata.get("name_override") or (row.get("name") or {}).get("es") or ""
        description = metadata.get("description_override") or (row.get("text") or {}).get("es") or ""
        for field, value in (("name", name), ("description", description)):
            if not value or hashlib.sha256(value.encode("utf-8")).hexdigest() != metadata.get(f"approved_{field}_sha256"):
                raise ValueError(f"Community text differs from reviewed catalog: {card_id} {field}")
        entry = {key: metadata[key] for key in ("cid", "password", "english_name", "legacy_description_sha256")}
        entry.update(name=name, description=description, description_verified=True, source_url=url, english_source_url="")
        entries[card_id] = entry
    pack = {"format": 1, "locale": "spa", "cards": entries}
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_name(output.name + ".tmp")
    temporary.write_bytes((json.dumps(pack, ensure_ascii=False, indent=2) + "\n").encode("utf-8"))
    temporary.replace(output)
    print(f"Reviewed Spanish pack: {len(entries)} names and descriptions")
    return 0


def build(catalog: Path, output: Path, cache: Path, workers: int = 4, offline: bool = False):
    source = json.loads(catalog.read_text(encoding="utf-8"))
    if source.get("bulk_source"):
        return build_bulk(source, output, cache, offline)
    fetcher = Fetcher(cache, offline)
    entries, failures = {}, {}

    def one(internal_id, metadata):
        spanish = fetcher.fetch(metadata["cid"], "es")
        # The catalog's password -> official CID mapping is the identity anchor.
        # Official English display names can legitimately have changed since
        # this game's release (e.g. Beast of Gilfer -> Archfiend of Gilfer).
        verified = False
        english_url = ""
        if metadata["review_description"]:
            try:
                english = fetcher.fetch(metadata["cid"], "en")
                english_url = english["source_url"]
                verified = text_hash(english["description"]) == metadata["legacy_description_sha256"]
            except (FileNotFoundError, RuntimeError):
                # A verified name remains useful even if the rules text cannot
                # yet be checked. Never guess or replace the legacy rules.
                pass
        result = {key: metadata[key] for key in ("cid", "password", "english_name", "legacy_description_sha256")}
        result.update(name=spanish["name"], official_english_name=spanish["english_name"],
                      description=spanish["description"] if verified else "",
                      description_verified=verified, source_url=spanish["source_url"], english_source_url=english_url)
        return internal_id, result

    output.parent.mkdir(parents=True, exist_ok=True)
    with ThreadPoolExecutor(max_workers=min(4, max(1, workers))) as executor:
        pending = {executor.submit(one, key, value): key for key, value in source["cards"].items()}
        for count, future in enumerate(as_completed(pending), 1):
            key = pending[future]
            try:
                internal_id, result = future.result()
                entries[internal_id] = result
            except Exception as error:
                failures[key] = str(error)
                if not offline:
                    print(f"Card {key} failed: {error}", flush=True)
            if count % 25 == 0 or count == len(pending):
                print(f"{count}/{len(pending)} cards; {len(failures)} failures; {fetcher.requests} requests", flush=True)
    pack = {"format": 1, "locale": "spa", "cards": dict(sorted(entries.items(), key=lambda pair: int(pair[0])))}
    output.write_text(json.dumps(pack, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    report = {"catalog_cards": len(source["cards"]), "translated_names": len(entries),
              "verified_descriptions": sum(x["description_verified"] for x in entries.values()),
              "retained_legacy_descriptions": sum(not x["description_verified"] for x in entries.values()),
              "requests": fetcher.requests, "failures": failures}
    output.with_suffix(".report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False), flush=True)
    return 1 if failures else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, default=Path("game/translations/spanish-card-catalog.json"))
    parser.add_argument("--output", type=Path, default=Path("artifacts/card-translations/cards-spa.json"))
    parser.add_argument("--cache", type=Path, default=Path("artifacts/card-translations/cache"))
    parser.add_argument("--offline", action="store_true", help="Usar solo la base ya descargada, sin solicitudes de red")
    args = parser.parse_args()
    return build(args.catalog, args.output, args.cache, offline=args.offline)


if __name__ == "__main__":
    raise SystemExit(main())
