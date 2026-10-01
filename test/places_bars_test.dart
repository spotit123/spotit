import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotit/data/mock_data.dart';
import 'package:spotit/data/places_bars.dart';
import 'package:spotit/services/db_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('places JSON is parsed into Bar objects', () {
    final bar = jsonDecode(File('test/fixtures/places_sample_bar.json').readAsStringSync());
    final raw = jsonEncode({'generatedAt': '2026-10-01T10:00:00+00:00', 'bars': [bar]});
    final places = PlacesBars.parse(raw)!;
    expect(places.version, 'places:2026-10-01T10:00:00+00:00');
    final b = places.bars.single;
    expect(b.name, 'Bar di Prova');
    expect(b.priceLevel, 1);
    expect(b.hasMusic, isTrue);
    expect(b.crowdAge, 'Gen Z / Students');
    expect(b.reviews.single.userName, 'Mario');
  });

  test('an empty data file means "use the mock bars"', () {
    expect(PlacesBars.parse('{"generatedAt": "", "bars": []}'), isNull);
  });

  test('shipped data file is valid (empty until the first Google download)', () {
    final raw = File('assets/data/malasana_bars.json').readAsStringSync();
    expect(() => PlacesBars.parse(raw), returnsNormally);
  });

  test('getBars falls back to mock bars and keeps favorites across data versions', () async {
    SharedPreferences.setMockInitialValues({});
    await DbService.init();
    final first = await DbService.getBars();
    expect(first.length, mockBars.length);

    first.first.isFavorite = true;
    await DbService.saveBars(first);
    final again = await DbService.getBars();
    expect(again.first.isFavorite, isTrue);
  });
}
