"""Test della trasformazione OpenStreetMap -> formato app (nessuna rete).
Esegui: python3 tool/test_fetch_osm.py   (--write-fixture riscrive test/fixtures/osm_sample_bar.json)"""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import fetch_osm as fo  # noqa: E402

# Elementi SINTETICI con la struttura della risposta Overpass; non sono locali reali.
PUB = {"type": "node", "id": 101, "lat": 40.4270, "lon": -3.7040, "tags": {
    "amenity": "pub", "name": "Pub di Prova", "addr:street": "Calle di Prova", "addr:housenumber": "5",
    "opening_hours": "Mo-Su 19:00-02:30", "phone": "+34 910 00 00 00", "website": "https://example.com",
    "live_music": "yes", "outdoor_seating": "yes"}}
CLUB = {"type": "way", "id": 202, "center": {"lat": 40.4250, "lon": -3.7000}, "tags": {
    "amenity": "nightclub", "name": "Club di Prova"}}
BARE = {"type": "node", "id": 303, "lat": 40.4260, "lon": -3.7010, "tags": {"amenity": "bar", "name": "Cocktail Corner"}}


class ToBarTest(unittest.TestCase):
    def test_osm_fields(self):
        b = fo.to_bar(PUB)
        self.assertEqual(b["id"], "osm_node_101")
        self.assertEqual(b["address"], "Calle di Prova 5, Madrid")
        self.assertEqual(b["phone"], "+34 910 00 00 00")
        self.assertEqual(b["openingHours"], {"Orari": "Lun-Dom 19:00-02:30"})
        self.assertTrue(b["hasMusic"])
        self.assertEqual(b["musicType"], "Musica dal vivo")
        self.assertNotIn("hasMusic", b["estimated"])  # live_music è un dato OSM
        self.assertIn("Live Music", b["vibeTags"])
        self.assertIn("Con tavoli all'aperto.", b["description"])
        self.assertEqual(b["descriptions"]["en"], "Pub in Malasaña, on Calle di Prova 5. With outdoor seating. With live music.")
        self.assertIn("Con terraza.", b["descriptions"]["es"])

    def test_osm_description_is_kept_untranslated(self):
        el = {"type": "node", "id": 9, "lat": 40.42, "lon": -3.70,
              "tags": {"amenity": "bar", "name": "Con Descrizione", "description": "Rooftop on the 26th floor."}}
        b = fo.to_bar(el)
        self.assertEqual(b["description"], "Rooftop on the 26th floor.")
        self.assertEqual(b["descriptions"], {})

    def test_way_uses_center_and_club_defaults(self):
        b = fo.to_bar(CLUB)
        self.assertEqual((b["latitude"], b["longitude"]), (40.4250, -3.7000))
        self.assertEqual(b["type"], "Discoteca")
        self.assertEqual(b["crowdAge"], "Gen Z / Students")
        self.assertIn("Energetic", b["vibeTags"])

    def test_missing_tags_get_honest_defaults(self):
        b = fo.to_bar(BARE)
        self.assertEqual(b["type"], "Cocktail bar")
        self.assertEqual(b["priceLevel"], 3)
        self.assertEqual(b["phone"], "N/D")
        self.assertEqual(b["openingHours"], {"Orari": "Non disponibili"})
        self.assertEqual((b["rating"], b["reviewCount"]), (0.0, 0))
        self.assertIn("priceLevel", b["estimated"])
        self.assertTrue(b["vibeTags"])


if __name__ == "__main__":
    if "--write-fixture" in sys.argv:
        path = os.path.join(os.path.dirname(__file__), "..", "test", "fixtures", "osm_sample_bar.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(fo.to_bar(PUB), f, ensure_ascii=False, indent=2)
        print("fixture scritta")
    else:
        unittest.main()
