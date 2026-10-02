// Legge gli orari dei locali (testo tipo "Lun-Ven 18:00-02:00; Sab 12:00-03:00")
// e dice se un locale è aperto in un certo momento.

enum OpenState { open, closed, unknown }

class OpenStatus {
  final OpenState state;

  /// Testo breve da mostrare, es. "Aperto · chiude alle 02:30". Può essere null.
  final String? label;

  const OpenStatus(this.state, [this.label]);

  static const unknown = OpenStatus(OpenState.unknown);
}

class _Interval {
  final int start; // minuti dalla mezzanotte
  final int end; // se end <= start, l'orario continua dopo mezzanotte
  const _Interval(this.start, this.end);
  bool get overnight => end <= start;
}

const _dayNames = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
const _dayKeys = ['lun', 'mar', 'mer', 'gio', 'ven', 'sab', 'dom'];

final _token = RegExp(
  r'(lun|mar|mer|gio|ven|sab|dom)(?:\s*-\s*(lun|mar|mer|gio|ven|sab|dom))?'
  r'|(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})'
  r'|(chiuso)',
);

/// Trasforma il testo in "giorno della settimana (0 = lunedì) -> fasce orarie".
/// Ritorna null se il testo non è comprensibile.
Map<int, List<_Interval>>? _parse(String raw) {
  final text = raw.toLowerCase().replaceAll('–', '-').replaceAll('—', '-').trim();
  if (text.isEmpty) return null;
  if (text.contains('24/7')) {
    return {for (var d = 0; d < 7; d++) d: [const _Interval(0, 1440)]};
  }

  final result = <int, List<_Interval>>{};
  for (final rule in text.split(';')) {
    final leftovers = rule.replaceAll(_token, '').replaceAll(RegExp(r'[\s,]'), '');
    if (leftovers.isNotEmpty) return null; // c'è qualcosa che non capiamo
    final matches = _token.allMatches(rule).toList();
    if (matches.isEmpty) continue;

    var days = <int>{};
    var intervals = <_Interval>[];
    var seenTimes = false;

    void flush() {
      final target = days.isEmpty ? {0, 1, 2, 3, 4, 5, 6} : days;
      for (final d in target) {
        result[d] = intervals; // una regola più avanti sostituisce le precedenti
      }
      days = <int>{};
      intervals = <_Interval>[];
      seenTimes = false;
    }

    for (final m in matches) {
      if (m.group(1) != null) {
        // un nuovo giorno dopo degli orari = inizia una nuova regola
        if (seenTimes) flush();
        final from = _dayKeys.indexOf(m.group(1)!);
        final to = m.group(2) == null ? from : _dayKeys.indexOf(m.group(2)!);
        for (var d = from;; d = (d + 1) % 7) {
          days.add(d);
          if (d == to) break;
        }
      } else if (m.group(3) != null) {
        final start = int.parse(m.group(3)!) * 60 + int.parse(m.group(4)!);
        final end = int.parse(m.group(5)!) * 60 + int.parse(m.group(6)!);
        intervals.add(_Interval(start, end));
        seenTimes = true;
      } else {
        seenTimes = true; // "chiuso": nessuna fascia
      }
    }
    flush();
  }
  return result.isEmpty ? null : result;
}

String _hhmm(int minutes) {
  final m = minutes % 1440;
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}

/// Stato di apertura di un locale in questo momento.
OpenStatus openStatus(Map<String, String> openingHours, DateTime now) {
  final raw = openingHours['Orari'];
  if (raw == null) return OpenStatus.unknown;
  final week = _parse(raw);
  if (week == null) return OpenStatus.unknown;

  final today = now.weekday - 1;
  final yesterday = (today + 6) % 7;
  final minute = now.hour * 60 + now.minute;

  // Aperto da una fascia che è iniziata ieri sera e finisce oggi
  for (final i in week[yesterday] ?? const <_Interval>[]) {
    if (i.overnight && minute < i.end) {
      return OpenStatus(OpenState.open, 'Aperto · chiude alle ${_hhmm(i.end)}');
    }
  }
  // Aperto da una fascia di oggi
  for (final i in week[today] ?? const <_Interval>[]) {
    final isOpen = i.overnight ? minute >= i.start : (minute >= i.start && minute < i.end);
    if (isOpen) return OpenStatus(OpenState.open, 'Aperto · chiude alle ${_hhmm(i.end)}');
  }

  // Chiuso: cerca la prossima apertura nei prossimi 7 giorni
  for (var offset = 0; offset < 7; offset++) {
    final day = (today + offset) % 7;
    final starts = [
      for (final i in week[day] ?? const <_Interval>[])
        if (offset > 0 || i.start > minute) i.start,
    ]..sort();
    if (starts.isNotEmpty) {
      final when = offset == 0
          ? 'alle'
          : offset == 1
              ? 'domani alle'
              : '${_dayNames[day]} alle';
      return OpenStatus(OpenState.closed, 'Chiuso · apre $when ${_hhmm(starts.first)}');
    }
  }
  return const OpenStatus(OpenState.closed, 'Chiuso');
}
