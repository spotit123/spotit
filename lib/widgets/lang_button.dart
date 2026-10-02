import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';

/// Piccolo menu per cambiare lingua (IT / EN / ES). Si può mettere in qualunque schermata.
class LangButton extends StatelessWidget {
  const LangButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Si ridisegna da solo quando cambia la lingua (altrimenti, essendo "const", Flutter lo salterebbe)
    return ValueListenableBuilder<AppLang>(
      valueListenable: L10n.lang,
      builder: (context, current, _) => _menu(current),
    );
  }

  Widget _menu(AppLang current) {
    return PopupMenuButton<AppLang>(
      tooltip: tr('lang.title'),
      color: const Color(0xFF131B2E),
      onSelected: L10n.setLang,
      itemBuilder: (_) => [
        for (final l in AppLang.values)
          PopupMenuItem(
            value: l,
            child: Text(
              '${l.name.toUpperCase()}  ·  ${L10n.label(l)}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: l == current ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              current.name.toUpperCase(),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
