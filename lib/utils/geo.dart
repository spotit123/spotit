import 'dart:math' as math;

/// Distanza in km tra due punti sulla Terra (formula di Haversine).
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const toRad = math.pi / 180;
  final dLat = (lat2 - lat1) * toRad;
  final dLon = (lon2 - lon1) * toRad;
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1 * toRad) * math.cos(lat2 * toRad) * math.pow(math.sin(dLon / 2), 2);
  return 2 * 6371 * math.asin(math.sqrt(a));
}

/// "350 m" sotto il chilometro, "1.2 km" sopra.
String formatDistance(double km) {
  if (km < 1) return '${(km * 100).round() * 10} m'; // arrotondato a 10 m
  return '${km.toStringAsFixed(1)} km';
}

/// Minuti a piedi, a circa 5 km/h.
int walkMinutes(double km) => (km * 12).round();
