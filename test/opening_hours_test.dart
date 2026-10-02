import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotit/services/opening_hours.dart';

// 2026-10-05 è un lunedì
DateTime at(int day, int h, int m) => DateTime(2026, 10, 4 + day, h, m); // day: 1=lun ... 7=dom

OpenStatus status(String hours, DateTime when) => openStatus({'Orari': hours}, when);

void main() {
  test('simple daily hours', () {
    expect(status('Lun-Dom 10:00-23:00', at(1, 12, 0)).state, OpenState.open);
    expect(status('Lun-Dom 10:00-23:00', at(1, 12, 0)).label, 'Aperto · chiude alle 23:00');
    expect(status('Lun-Dom 10:00-23:00', at(1, 8, 0)).state, OpenState.closed);
    expect(status('Lun-Dom 10:00-23:00', at(1, 8, 0)).label, 'Chiuso · apre alle 10:00');
  });

  test('after-midnight closing belongs to the previous evening', () {
    const h = 'Lun-Dom 19:00-02:30';
    expect(status(h, at(2, 1, 0)).state, OpenState.open); // martedì 01:00, aperto da lunedì sera
    expect(status(h, at(2, 1, 0)).label, 'Aperto · chiude alle 02:30');
    expect(status(h, at(2, 3, 0)).state, OpenState.closed);
    expect(status(h, at(2, 21, 0)).state, OpenState.open);
  });

  test('different hours per day and day ranges that wrap around the week', () {
    const h = 'Dom-Gio 18:00-01:00; Ven-Sab 18:00-03:00';
    expect(status(h, at(6, 2, 0)).state, OpenState.open); // sabato 02:00: da venerdì sera
    expect(status(h, at(5, 2, 0)).state, OpenState.closed); // venerdì 02:00: giovedì chiude all'1
    expect(status(h, at(2, 2, 0)).state, OpenState.closed); // martedì 02:00: lunedì chiude all'1
    expect(status(h, at(7, 19, 0)).state, OpenState.open); // domenica sera
  });

  test('comma separated rules and split shifts', () {
    const h = 'Lun-Gio 09:00-01:00, Ven 09:00-02:00, Sab 09:30-02:00, Dom 09:30-01:00';
    expect(status(h, at(5, 10, 0)).state, OpenState.open);
    const split = 'Lun-Sab 13:00-15:30, 18:30-23:00';
    expect(status(split, at(1, 16, 0)).state, OpenState.closed);
    expect(status(split, at(1, 16, 0)).label, 'Chiuso · apre alle 18:30');
    expect(status(split, at(1, 14, 0)).state, OpenState.open);
  });

  test('closed today: says when it opens next', () {
    const h = 'Mar-Sab 07:00-02:30';
    expect(status(h, at(1, 12, 0)).label, 'Chiuso · apre domani alle 07:00');
    expect(status(h, at(7, 12, 0)).label, 'Chiuso · apre Mar alle 07:00');
  });

  test('24:00 end and bare time ranges', () {
    expect(status('08:00-24:00', at(3, 23, 30)).state, OpenState.open);
    expect(status('Ven, Sab 00:00-06:00', at(5, 3, 0)).state, OpenState.open);
  });

  test('missing or unreadable hours are unknown, never "closed"', () {
    expect(openStatus({'Orari': 'Non disponibili'}, DateTime(2026, 10, 5, 12)).state, OpenState.unknown);
    expect(openStatus({}, DateTime(2026, 10, 5, 12)).state, OpenState.unknown);
    expect(status('Apr-Oct Lun-Dom 10:00-22:00', at(1, 12, 0)).state, OpenState.unknown);
  });

  test('every opening-hours text in the shipped data is understood', () {
    final data = jsonDecode(File('assets/data/malasana_bars.json').readAsStringSync());
    for (final bar in data['bars'] as List) {
      final hours = Map<String, String>.from(bar['openingHours'] as Map);
      if (hours['Orari'] == 'Non disponibili') continue;
      expect(openStatus(hours, at(1, 12, 0)).state, isNot(OpenState.unknown),
          reason: '${bar['name']}: ${hours['Orari']}');
    }
  });
}
