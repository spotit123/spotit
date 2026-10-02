import 'package:url_launcher/url_launcher.dart';
import '../l10n/l10n.dart';
import '../models/bar.dart';

const siteUrl = 'https://spotit123.github.io/spotit/';

String mapsLink(Bar bar) =>
    'https://www.google.com/maps/search/?api=1&query=${bar.latitude},${bar.longitude}';

/// Messaggio per un solo locale, pronto da incollare in una chat.
String barShareText(Bar bar) {
  final lines = <String>[
    tr('share.bar', {'name': bar.name}),
    '📍 ${bar.address}',
    mapsLink(bar),
    '',
    tr('share.found', {'url': siteUrl}),
  ];
  return lines.join('\n');
}

/// Messaggio con più locali tra cui scegliere ("dove andiamo stasera?").
String plansShareText(List<Bar> bars) {
  final lines = <String>[tr('share.plan'), ''];
  for (var i = 0; i < bars.length; i++) {
    lines.add('${i + 1}. ${bars[i].name} - ${bars[i].address}');
    lines.add('   ${mapsLink(bars[i])}');
  }
  lines
    ..add('')
    ..add(tr('share.foundMany', {'url': siteUrl}));
  return lines.join('\n');
}

/// Apre WhatsApp (app o sito) con il testo già scritto.
Future<bool> shareOnWhatsApp(String text) {
  final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
  return launchUrl(url, mode: LaunchMode.externalApplication);
}
