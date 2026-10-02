import 'package:flutter/foundation.dart';
import '../services/db_service.dart';
import 'strings_core.dart';
import 'strings_quiz.dart';
import 'strings_screens.dart';

/// Lingue supportate. Il nome (`it`, `en`, `es`) è anche il codice usato nei dati.
enum AppLang { it, en, es }

class L10n {
  /// Lingua corrente. Chi la ascolta (main.dart) ridisegna l'app quando cambia.
  static final ValueNotifier<AppLang> lang = ValueNotifier(AppLang.it);

  static String get code => lang.value.name;

  /// Lingua del dispositivo se supportata, altrimenti inglese.
  static AppLang detect(String deviceCode) {
    for (final l in AppLang.values) {
      if (l.name == deviceCode) return l;
    }
    return AppLang.en;
  }

  static Future<void> setLang(AppLang l) async {
    lang.value = l;
    await DbService.saveLang(l.name);
  }

  static String label(AppLang l) => switch (l) {
        AppLang.it => 'Italiano',
        AppLang.en => 'English',
        AppLang.es => 'Español',
      };
}

/// Traduce una chiave nella lingua corrente. I segnaposto `{nome}` vengono
/// sostituiti con i valori passati in [args]. Se la chiave non esiste ritorna la chiave.
String tr(String key, [Map<String, Object>? args]) {
  final row = strings[key];
  if (row == null) return key;
  var text = row[L10n.lang.value.index];
  args?.forEach((k, v) => text = text.replaceAll('{$k}', '$v'));
  return text;
}

// ---- Traduzioni dei valori che arrivano dai dati (tipo di locale, vibe, età...) ----

String _lookup(String prefix, String value) {
  final key = '$prefix.$value';
  return strings.containsKey(key) ? tr(key) : value;
}

String trType(String type) => _lookup('type', type);
String trMusic(String music) => _lookup('music', music);
String trVibe(String vibe) => _lookup('vibe', vibe);
String trDrink(String drink) => _lookup('drink', drink);

/// "20s-30s" -> "20-30 anni"; "Gen Z / Students" -> "Gen Z / Studenti"
String trAge(String age) {
  final m = RegExp(r'^(\d)0s(?:-(\d)0s)?$').firstMatch(age);
  if (m != null) {
    final from = '${m.group(1)}0';
    final to = m.group(2) == null ? '+' : '-${m.group(2)}0';
    return m.group(2) == null ? '$from+ ${tr('unit.years')}' : '$from$to ${tr('unit.years')}';
  }
  return _lookup('age', age);
}

String trDay(int dayIndex) => tr('day.$dayIndex');

/// Ordine delle colonne: [italiano, inglese, spagnolo]
final Map<String, List<String>> strings = {...coreStrings, ...screenStrings, ...quizStrings};
