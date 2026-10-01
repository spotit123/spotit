import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bar.dart';

/// Locali scaricati da Google Places (vedi tool/fetch_places.py).
class PlacesBars {
  /// Identifica la versione dei dati: cambia a ogni nuovo download.
  final String version;
  final List<Bar> bars;

  const PlacesBars(this.version, this.bars);

  static const assetPath = 'assets/data/malasana_bars.json';

  /// Restituisce null se il file è vuoto o non leggibile: in quel caso l'app
  /// usa i locali di prova.
  static Future<PlacesBars?> load() async {
    try {
      return parse(await rootBundle.loadString(assetPath));
    } catch (_) {
      return null;
    }
  }

  static PlacesBars? parse(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['bars'] as List?) ?? const [];
    if (list.isEmpty) return null;
    final bars = list.map((e) => Bar.fromJson(e as Map<String, dynamic>)).toList();
    return PlacesBars('places:${data['generatedAt']}', bars);
  }
}
