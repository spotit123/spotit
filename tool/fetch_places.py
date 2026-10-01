#!/usr/bin/env python3
"""Scarica i locali di Malasaña (Madrid) da Google Places API (New) e li salva
in assets/data/malasana_bars.json, nel formato letto da Bar.fromJson.

Uso:
    GOOGLE_PLACES_API_KEY=... python3 tool/fetch_places.py

Cosa viene da Google: nome, indirizzo, posizione, voto, numero recensioni,
fascia di prezzo, orari, telefono, sito, descrizione, musica dal vivo,
recensioni e foto.
Cosa NON esiste su Google e viene stimato (indicato in `estimated`): fascia
d'età, affollamento, rapporto uomini/donne e musica quando Google non la dice.
"""
import json
import math
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone

# Rettangolo che copre Malasaña (Gran Vía a sud, Glorieta de Bilbao a nord).
AREA = {
    "low": {"latitude": 40.4200, "longitude": -3.7120},
    "high": {"latitude": 40.4300, "longitude": -3.6990},
}
CENTER = (40.4169, -3.7035)  # Puerta del Sol, per il campo `distance`
QUERIES = [
    "bar Malasaña",
    "cocktail bar Malasaña",
    "pub Malasaña",
    "discoteca Malasaña",
    "taberna vermut tapas Malasaña",
    "rooftop terraza bar Malasaña",
]
BAR_TYPES = {"bar", "pub", "night_club", "cocktail_bar", "wine_bar", "bar_and_grill",
             "irish_pub", "lounge_bar", "karaoke", "live_music_venue"}
FOOD_TYPES = {"restaurant", "tapas_restaurant", "spanish_restaurant", "cafe", "bakery"}
MAX_BARS = 40
PHOTOS_PER_BAR = 3
PLACEHOLDER_IMAGE = ("https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b"
                     "?auto=format&fit=crop&w=600&q=80")

FIELDS = ",".join([
    "nextPageToken",
    "places.id", "places.displayName", "places.formattedAddress", "places.location",
    "places.rating", "places.userRatingCount", "places.priceLevel", "places.priceRange",
    "places.regularOpeningHours", "places.nationalPhoneNumber", "places.websiteUri",
    "places.editorialSummary", "places.generativeSummary", "places.primaryType",
    "places.primaryTypeDisplayName", "places.types", "places.liveMusic",
    "places.servesCocktails", "places.servesBeer", "places.servesWine",
    "places.reviews", "places.photos", "places.businessStatus",
])

MUSIC_WORDS = ["music", "música", "musica", "dj", "concert", "concierto", "live",
               "rock", "indie", "jazz", "techno", "reggaeton", "playlist", "karaoke"]
GENRES = [
    (["techno", "house", "electr"], "Techno / House"),
    (["reggaeton", "latin", "latino"], "Reggaeton / Pop"),
    (["jazz", "soul", "blues"], "Jazz / Soul"),
    (["rock", "indie", "punk", "garage", "britpop"], "Rock / Indie"),
    (["pop"], "Pop"),
]


def api_post(url, body, key, field_mask):
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode(),
        headers={
            "Content-Type": "application/json",
            "X-Goog-Api-Key": key,
            "X-Goog-FieldMask": field_mask,
        },
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def search_all(key):
    found = {}
    for query in QUERIES:
        token = None
        for _ in range(3):  # fino a 60 risultati per ricerca
            body = {
                "textQuery": query,
                "languageCode": "it",
                "regionCode": "ES",
                "pageSize": 20,
                "locationRestriction": {"rectangle": AREA},
            }
            if token:
                body["pageToken"] = token
            data = api_post("https://places.googleapis.com/v1/places:searchText", body, key, FIELDS)
            for p in data.get("places", []):
                found.setdefault(p["id"], p)
            token = data.get("nextPageToken")
            if not token:
                break
    return list(found.values())


def photo_url(photo_name, key):
    url = (f"https://places.googleapis.com/v1/{photo_name}/media"
           f"?maxWidthPx=800&skipHttpRedirect=true&key={key}")
    try:
        with urllib.request.urlopen(url, timeout=30) as r:
            return json.load(r).get("photoUri")
    except (urllib.error.URLError, ValueError):
        return None


def haversine(a, b, c, d):
    p = math.pi / 180
    x = (math.sin((c - a) * p / 2) ** 2
         + math.cos(a * p) * math.cos(c * p) * math.sin((d - b) * p / 2) ** 2)
    return 2 * 6371 * math.asin(math.sqrt(x))


def is_bar(place):
    types = set(place.get("types", []))
    return bool(types & BAR_TYPES) and place.get("businessStatus", "OPERATIONAL") == "OPERATIONAL"


def price_level(place):
    level = {
        "PRICE_LEVEL_FREE": 1, "PRICE_LEVEL_INEXPENSIVE": 1, "PRICE_LEVEL_MODERATE": 2,
        "PRICE_LEVEL_EXPENSIVE": 3, "PRICE_LEVEL_VERY_EXPENSIVE": 3,
    }.get(place.get("priceLevel"))
    if level:
        return level, False
    pr = place.get("priceRange")
    if pr:
        def val(x):
            return float(x.get("units", 0)) + x.get("nanos", 0) / 1e9
        avg = (val(pr.get("startPrice", {})) + val(pr.get("endPrice", pr.get("startPrice", {})))) / 2
        return (1 if avg <= 12 else 2 if avg <= 25 else 3), False
    return 2, True  # sconosciuto: valore medio, segnato come stimato


def summary_text(place):
    s = (place.get("editorialSummary") or {}).get("text")
    if s:
        return s
    g = ((place.get("generativeSummary") or {}).get("overview") or {}).get("text")
    return g or ""


def derive(place):
    """Campi che Google non fornisce direttamente. Ritorna (campi, elenco_stimati)."""
    estimated = ["crowdDensity", "genderRatio"]
    types = set(place.get("types", []))
    summary = summary_text(place)
    reviews_text = " ".join((r.get("text") or {}).get("text", "") for r in place.get("reviews", []))
    text = f"{summary} {reviews_text}".lower()
    name = place.get("displayName", {}).get("text", "").lower()
    level, level_estimated = price_level(place)
    if level_estimated:
        estimated.append("priceLevel")

    # Musica
    live = place.get("liveMusic")
    if live is True or "night_club" in types or any(w in text for w in MUSIC_WORDS):
        has_music = True
    else:
        has_music = not (types & FOOD_TYPES) or bool(types & BAR_TYPES)
        estimated.append("hasMusic")
    music_type = "None"
    if has_music:
        music_type = "Musica dal vivo" if live else "Musica di sottofondo"
        for words, label in GENRES:
            if any(w in text or w in name for w in words):
                music_type = label
                break
    # Fascia d'età
    if "night_club" in types:
        age = "Gen Z / Students" if level <= 2 else "20s-30s"
    elif any(w in text for w in ["student", "universit", "erasmus"]):
        age = "Gen Z / Students"
    elif level >= 3 or "cocktail_bar" in types or "wine_bar" in types:
        age = "30s-40s"
    elif types & FOOD_TYPES:
        age = "30s-50s"
    else:
        age = "20s-30s"
    estimated.append("crowdAge")

    # Vibe
    tags = []
    if "night_club" in types:
        tags += ["Energetic", "Neon"]
    if live is True:
        tags.append("Live Music")
    if any(w in text or w in name for w in ["rooftop", "terraza", "azotea", "terrazza"]):
        tags.append("Rooftop")
    if any(w in text or w in name for w in ["underground", "alternativ", "garage", "punk", "indie"]):
        tags.append("Underground")
    if "jazz" in text:
        tags.append("Jazz")
    if "cocktail_bar" in types or "wine_bar" in types or not tags:
        tags.append("Chill")
    tags = list(dict.fromkeys(tags))

    count = place.get("userRatingCount", 0)
    density = min(95, 40 + round(math.log10(max(count, 10)) * 14))
    return {
        "priceLevel": level, "hasMusic": has_music, "musicType": music_type,
        "crowdAge": age, "vibeTags": tags, "crowdDensity": density,
    }, estimated


def weekday_hours(place):
    out = {}
    for line in (place.get("regularOpeningHours") or {}).get("weekdayDescriptions", []):
        day, _, hours = line.partition(": ")
        out[day.capitalize()] = hours
    return out or {"Orari": "Non disponibili"}


def to_bar(place, photos):
    derived, estimated = derive(place)
    types = set(place.get("types", []))
    name = place["displayName"]["text"]
    loc = place["location"]
    kind = (place.get("primaryTypeDisplayName") or {}).get("text") or "Bar"
    summary = summary_text(place)
    street = place.get("formattedAddress", "").split(",")[0]
    drinks = []
    if place.get("servesCocktails"):
        drinks.append("Cocktail")
    if place.get("servesBeer"):
        drinks.append("Birra")
    if place.get("servesWine"):
        drinks.append("Vino")
    reviews = []
    for i, r in enumerate(place.get("reviews", [])[:3]):
        attribution = r.get("authorAttribution", {})
        reviews.append({
            "id": f"{place['id']}_{i}",
            "userName": attribution.get("displayName", "Utente Google"),
            "userAvatar": attribution.get("photoUri", ""),
            "rating": float(r.get("rating", 0)),
            "comment": (r.get("text") or {}).get("text", ""),
            "date": r.get("relativePublishTimeDescription", ""),
        })
    return {
        "id": place["id"],
        "name": name,
        "type": kind,
        "description": summary or f"{kind} a Malasaña, in {street}.",
        "rating": float(place.get("rating", 0)),
        "reviewCount": int(place.get("userRatingCount", 0)),
        "address": place.get("formattedAddress", ""),
        "latitude": loc["latitude"],
        "longitude": loc["longitude"],
        "imageUrl": photos[0] if photos else PLACEHOLDER_IMAGE,
        "distance": round(haversine(CENTER[0], CENTER[1], loc["latitude"], loc["longitude"]), 1),
        "popularDrinks": drinks or ["Birra"],
        "phone": place.get("nationalPhoneNumber", "N/D"),
        "website": place.get("websiteUri", "N/D"),
        "openingHours": weekday_hours(place),
        "isFavorite": False,
        "vibeTags": derived["vibeTags"],
        "crowdDensity": derived["crowdDensity"],
        "crowdAge": derived["crowdAge"],
        "genderRatio": "N/D",
        "hasMusic": derived["hasMusic"],
        "musicType": derived["musicType"],
        "reviews": reviews,
        "galleryImages": photos or [PLACEHOLDER_IMAGE],
        "priceLevel": derived["priceLevel"],
        "estimated": sorted(set(estimated)),
    }


def main():
    key = os.environ.get("GOOGLE_PLACES_API_KEY", "").strip()
    if not key:
        sys.exit("Manca la variabile GOOGLE_PLACES_API_KEY")
    out_path = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "malasana_bars.json")

    places = [p for p in search_all(key) if is_bar(p)]
    places.sort(key=lambda p: p.get("userRatingCount", 0), reverse=True)
    places = places[:MAX_BARS]
    print(f"{len(places)} locali trovati")

    bars = []
    for p in places:
        photos = []
        for ph in p.get("photos", [])[:PHOTOS_PER_BAR]:
            url = photo_url(ph["name"], key)
            if url:
                photos.append(url)
        bars.append(to_bar(p, photos))

    result = {
        "generatedAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "source": "Google Places API (New)",
        "area": "Malasaña, Madrid",
        "bars": bars,
    }
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"Scritto {os.path.normpath(out_path)}")


if __name__ == "__main__":
    main()
