#!/usr/bin/env python3
"""Scarica i locali di Malasaña (Madrid) da OpenStreetMap (gratis, nessuna chiave)
e li salva in assets/data/malasana_bars.json, nel formato letto da Bar.fromJson.

Uso:  python3 tool/fetch_osm.py

Dati © OpenStreetMap contributors (licenza ODbL).

Da OpenStreetMap arrivano: nome, tipo, indirizzo, posizione e, quando i
volontari li hanno inseriti, orari, telefono, sito, terrazza, musica dal vivo.
NON esistono su OpenStreetMap, quindi vengono stimati (campo `estimated`):
voti e recensioni (lasciati a 0), foto (immagine generica), fascia di prezzo,
fascia d'età, affollamento e musica.
"""
import json
import os
import sys
import time
import urllib.parse
import urllib.request
from datetime import datetime, timezone

sys.path.insert(0, os.path.dirname(__file__))
from fetch_places import AREA, CENTER, haversine  # noqa: E402

ENDPOINTS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
]
MAX_BARS = 60
STOCK_IMAGES = [
    "https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1536935338788-846bb9981813?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1574096079513-d8259312b785?auto=format&fit=crop&w=600&q=80",
    "https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=600&q=80",
]
DAYS = {"Mo": "Lun", "Tu": "Mar", "We": "Mer", "Th": "Gio", "Fr": "Ven", "Sa": "Sab", "Su": "Dom",
        "off": "chiuso", "PH": "festivi"}

QUERY = """[out:json][timeout:60];
nwr["amenity"~"^(bar|pub|nightclub|biergarten)$"]["name"]
  ({s},{w},{n},{e});
out center tags;"""


def query_overpass():
    q = QUERY.format(s=AREA["low"]["latitude"], w=AREA["low"]["longitude"],
                     n=AREA["high"]["latitude"], e=AREA["high"]["longitude"])
    data = urllib.parse.urlencode({"data": q}).encode()
    last = None
    for attempt in range(3):
        for url in ENDPOINTS:
            try:
                req = urllib.request.Request(url, data=data, headers={"User-Agent": "spotit-bar-fetch/1.0"})
                with urllib.request.urlopen(req, timeout=90) as r:
                    return json.load(r)["elements"]
            except Exception as e:  # rete o server occupato: si riprova
                last = e
        time.sleep(10 * (attempt + 1))
    sys.exit(f"Overpass non raggiungibile: {last}")


def street_address(tags):
    street = tags.get("addr:street", "")
    number = tags.get("addr:housenumber", "")
    line = f"{street} {number}".strip()
    return f"{line}, Madrid" if line else "Malasaña, Madrid"


def kind_of(tags):
    amenity = tags.get("amenity")
    text = f"{tags.get('name', '')} {tags.get('cuisine', '')} {tags.get('description', '')}".lower()
    if amenity == "nightclub":
        return "Discoteca"
    if amenity == "pub":
        return "Pub"
    if amenity == "biergarten":
        return "Birreria all'aperto"
    if "cocktail" in text:
        return "Cocktail bar"
    if "wine" in text or "vino" in text or "vermut" in text or "vermú" in text:
        return "Enoteca / Vermuteria"
    if "tapas" in text or "taberna" in text:
        return "Taberna & Tapas"
    return "Bar"


def hours(tags):
    raw = tags.get("opening_hours")
    if not raw:
        return {"Orari": "Non disponibili"}
    for en, it in DAYS.items():
        raw = raw.replace(en, it)
    return {"Orari": raw}


def to_bar(el):
    tags = el["tags"]
    name = tags["name"]
    lat = el.get("lat") or el["center"]["lat"]
    lon = el.get("lon") or el["center"]["lon"]
    kind = kind_of(tags)
    amenity = tags.get("amenity")
    music_tag = tags.get("live_music") == "yes" or tags.get("music") == "yes"
    club = amenity == "nightclub"
    estimated = ["rating", "photos", "priceLevel", "crowdAge", "crowdDensity", "genderRatio"]

    has_music = music_tag or club or amenity in ("bar", "pub")
    if not (music_tag or club):
        estimated.append("hasMusic")
    music_type = "None"
    if has_music:
        music_type = "Musica dal vivo" if music_tag else ("Elettronica / Pop" if club else "Musica di sottofondo")

    # Prezzo e pubblico: stime dal tipo di locale
    if kind == "Cocktail bar":
        price, age = 3, "30s-40s"
    elif club:
        price, age = 2, "Gen Z / Students"
    elif amenity == "pub":
        price, age = 1, "20s-30s"
    elif kind in ("Enoteca / Vermuteria", "Taberna & Tapas"):
        price, age = 2, "30s-50s"
    else:
        price, age = 2, "20s-30s"

    tag_list = []
    if club:
        tag_list += ["Energetic", "Neon"]
    if music_tag:
        tag_list.append("Live Music")
    if "rooftop" in name.lower() or "azotea" in name.lower():
        tag_list.append("Rooftop")
    if amenity == "pub":
        tag_list.append("Underground")
    if not tag_list:
        tag_list.append("Chill")
    tag_list = list(dict.fromkeys(tag_list))

    description = tags.get("description:it") or tags.get("description") or ""
    if not description:
        parts = [f"{kind} a Malasaña, in {street_address(tags).replace(', Madrid', '')}."]
        if tags.get("outdoor_seating") == "yes":
            parts.append("Con tavoli all'aperto.")
        if music_tag:
            parts.append("Con musica dal vivo.")
        if tags.get("cuisine"):
            parts.append(f"Cucina: {tags['cuisine'].replace(';', ', ').replace('_', ' ')}.")
        description = " ".join(parts)

    return {
        "id": f"osm_{el['type']}_{el['id']}",
        "name": name,
        "type": kind,
        "description": description,
        "rating": 0.0,
        "reviewCount": 0,
        "address": street_address(tags),
        "latitude": lat,
        "longitude": lon,
        "imageUrl": STOCK_IMAGES[el["id"] % len(STOCK_IMAGES)],
        "distance": round(haversine(CENTER[0], CENTER[1], lat, lon), 1),
        "popularDrinks": ["Cerveza", "Cubata"] if amenity != "nightclub" else ["Cubata", "Chupito"],
        "phone": tags.get("phone") or tags.get("contact:phone") or "N/D",
        "website": tags.get("website") or tags.get("contact:website") or "N/D",
        "openingHours": hours(tags),
        "isFavorite": False,
        "vibeTags": tag_list,
        "crowdDensity": 85 if club else 65,
        "crowdAge": age,
        "genderRatio": "N/D",
        "hasMusic": has_music,
        "musicType": music_type,
        "reviews": [],
        "galleryImages": [STOCK_IMAGES[el["id"] % len(STOCK_IMAGES)]],
        "priceLevel": price,
        "estimated": sorted(set(estimated)),
    }


def completeness(el):
    t = el["tags"]
    return sum(k in t for k in ("opening_hours", "website", "phone", "addr:street", "description"))


def main():
    elements = [e for e in query_overpass() if "tags" in e and "name" in e["tags"]]
    elements.sort(key=lambda e: (-completeness(e), e["tags"]["name"]))
    seen, picked = set(), []
    for e in elements:  # un solo elemento per nome
        key = e["tags"]["name"].strip().lower()
        if key not in seen:
            seen.add(key)
            picked.append(e)
    picked = picked[:MAX_BARS]
    print(f"{len(picked)} locali trovati")
    if not picked:
        sys.exit("Nessun locale trovato: file dati non modificato")

    result = {
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "source": "OpenStreetMap contributors (ODbL)",
        "area": "Malasaña, Madrid",
        "bars": [to_bar(e) for e in picked],
    }
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "malasana_bars.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"Scritto {os.path.normpath(out)}")


if __name__ == "__main__":
    main()
