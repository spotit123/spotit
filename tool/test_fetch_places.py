"""Test della trasformazione dati Google Places -> formato app (nessuna rete).
Esegui: python3 tool/test_fetch_places.py
Con --write-fixture riscrive test/fixtures/places_sample_bar.json."""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import fetch_places as fp  # noqa: E402

# Risposta SINTETICA con la stessa struttura di Places API (New); non è un locale reale.
SAMPLE = {
    "id": "TEST_PLACE_1",
    "displayName": {"text": "Bar di Prova"},
    "formattedAddress": "Calle di Prova 1, 28004 Madrid, Spagna",
    "location": {"latitude": 40.4265, "longitude": -3.7040},
    "rating": 4.4,
    "userRatingCount": 1200,
    "priceLevel": "PRICE_LEVEL_INEXPENSIVE",
    "types": ["bar", "night_club", "point_of_interest"],
    "primaryTypeDisplayName": {"text": "Bar"},
    "liveMusic": True,
    "servesBeer": True,
    "servesCocktails": True,
    "editorialSummary": {"text": "Locale con musica rock e indie."},
    "nationalPhoneNumber": "910 00 00 00",
    "websiteUri": "https://example.com",
    "regularOpeningHours": {"weekdayDescriptions": ["lunedì: 19:00–02:00", "martedì: Chiuso"]},
    "reviews": [{
        "rating": 5,
        "text": {"text": "Ottimo posto"},
        "relativePublishTimeDescription": "un mese fa",
        "authorAttribution": {"displayName": "Mario", "photoUri": ""},
    }],
}


class ToBarTest(unittest.TestCase):
    def setUp(self):
        self.bar = fp.to_bar(SAMPLE, ["https://example.com/p1.jpg"])

    def test_google_fields(self):
        b = self.bar
        self.assertEqual(b["name"], "Bar di Prova")
        self.assertEqual(b["rating"], 4.4)
        self.assertEqual(b["reviewCount"], 1200)
        self.assertEqual(b["priceLevel"], 1)
        self.assertEqual(b["description"], "Locale con musica rock e indie.")
        self.assertEqual(b["openingHours"]["Lunedì"], "19:00–02:00")
        self.assertEqual(b["imageUrl"], "https://example.com/p1.jpg")

    def test_music_and_age(self):
        b = self.bar
        self.assertTrue(b["hasMusic"])
        self.assertEqual(b["musicType"], "Rock / Indie")
        self.assertEqual(b["crowdAge"], "Gen Z / Students")  # night_club + prezzo basso
        self.assertNotIn("hasMusic", b["estimated"])  # liveMusic è un dato Google
        self.assertIn("crowdAge", b["estimated"])

    def test_missing_fields_fall_back(self):
        minimal = {"id": "X", "displayName": {"text": "Senza dati"},
                   "formattedAddress": "Calle X 2, Madrid", "location": {"latitude": 40.42, "longitude": -3.7},
                   "types": ["bar"]}
        b = fp.to_bar(minimal, [])
        self.assertEqual(b["priceLevel"], 2)
        self.assertIn("priceLevel", b["estimated"])
        self.assertEqual(b["phone"], "N/D")
        self.assertEqual(b["imageUrl"], fp.PLACEHOLDER_IMAGE)
        self.assertTrue(b["vibeTags"])

    def test_is_bar_filters_restaurants_and_closed(self):
        self.assertTrue(fp.is_bar(SAMPLE))
        self.assertFalse(fp.is_bar({"types": ["restaurant"]}))
        self.assertFalse(fp.is_bar({"types": ["bar"], "businessStatus": "CLOSED_PERMANENTLY"}))


if __name__ == "__main__":
    if "--write-fixture" in sys.argv:
        path = os.path.join(os.path.dirname(__file__), "..", "test", "fixtures", "places_sample_bar.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(fp.to_bar(SAMPLE, ["https://example.com/p1.jpg"]), f, ensure_ascii=False, indent=2)
        print("fixture scritta")
    else:
        unittest.main()
