import 'package:flutter_test/flutter_test.dart';
import 'package:spotit/data/mock_data.dart';
import 'package:spotit/services/share_service.dart';
import 'package:spotit/utils/geo.dart';

void main() {
  test('distance Puerta del Sol -> Plaza Dos de Mayo is about 1.2 km', () {
    final km = distanceKm(40.4169, -3.7035, 40.4277, -3.7043);
    expect(km, closeTo(1.2, 0.1));
    expect(distanceKm(40.4, -3.7, 40.4, -3.7), 0);
  });

  test('distance and walking time formatting', () {
    expect(formatDistance(0.347), '350 m');
    expect(formatDistance(1.234), '1.2 km');
    expect(walkMinutes(1.0), 12);
  });

  test('share text contains name, address, map link and the site', () {
    final bar = mockBars.first;
    final text = barShareText(bar);
    expect(text, contains(bar.name));
    expect(text, contains(bar.address));
    expect(text, contains('google.com/maps'));
    expect(text, contains(siteUrl));
  });

  test('plan share text lists every bar', () {
    final text = plansShareText(mockBars.take(3).toList());
    for (final b in mockBars.take(3)) {
      expect(text, contains(b.name));
    }
    expect(text, contains('3.'));
  });
}
