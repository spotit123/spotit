import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotit/l10n/l10n.dart';
import 'package:spotit/services/opening_hours.dart';

void main() {
  tearDown(() => L10n.lang.value = AppLang.it);

  test('every translation has Italian, English and Spanish text', () {
    for (final e in strings.entries) {
      expect(e.value.length, 3, reason: e.key);
      for (final text in e.value) {
        expect(text.trim(), isNotEmpty, reason: e.key);
      }
    }
  });

  test('placeholders are the same in all three languages', () {
    final ph = RegExp(r'\{(\w+)\}');
    for (final e in strings.entries) {
      final sets = e.value.map((t) => ph.allMatches(t).map((m) => m.group(1)).toSet()).toList();
      expect(sets[1], sets[0], reason: '${e.key}: EN differs from IT');
      expect(sets[2], sets[0], reason: '${e.key}: ES differs from IT');
    }
  });

  test('every key used in the code exists in the table', () {
    final used = RegExp(r"""\btr\('([^']+)'""");
    final missing = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in used.allMatches(f.readAsStringSync())) {
        final key = m.group(1)!;
        if (key.contains(r'$')) continue; // chiavi composte: controllate nei test sotto
        if (!strings.containsKey(key)) missing.add('$key (${f.path})');
      }
    }
    expect(missing, isEmpty);
  });

  test('day names exist for all 7 days', () {
    for (var d = 0; d < 7; d++) {
      expect(strings.containsKey('day.$d'), isTrue, reason: 'day.$d');
    }
  });

  test('tr switches language and fills placeholders', () {
    L10n.lang.value = AppLang.it;
    expect(tr('open.until', {'t': '02:30'}), 'Aperto · chiude alle 02:30');
    L10n.lang.value = AppLang.en;
    expect(tr('open.until', {'t': '02:30'}), 'Open · closes at 02:30');
    L10n.lang.value = AppLang.es;
    expect(tr('open.until', {'t': '02:30'}), 'Abierto · cierra a las 02:30');
    expect(tr('does.not.exist'), 'does.not.exist');
  });

  test('values coming from the data are translated, unknown ones are kept', () {
    L10n.lang.value = AppLang.en;
    expect(trType('Discoteca'), 'Nightclub');
    expect(trType('Qualcosa di nuovo'), 'Qualcosa di nuovo');
    expect(trVibe('Rooftop'), 'Rooftop');
    expect(trAge('20s-30s'), '20-30 years');
    expect(trAge('Gen Z / Students'), 'Gen Z / Students');
    L10n.lang.value = AppLang.es;
    expect(trAge('30s-50s'), '30-50 años');
  });

  test('opening status text follows the language', () {
    L10n.lang.value = AppLang.en;
    final status = openStatus({'Orari': 'Lun-Dom 19:00-02:30'}, DateTime(2026, 10, 5, 21, 0));
    expect(status.label, 'Open · closes at 02:30');
    final closed = openStatus({'Orari': 'Mar-Sab 07:00-02:30'}, DateTime(2026, 10, 5, 12, 0));
    expect(closed.label, 'Closed · opens tomorrow at 07:00');
  });

  test('device language is used only when supported', () {
    expect(L10n.detect('es'), AppLang.es);
    expect(L10n.detect('fr'), AppLang.en);
  });
}
