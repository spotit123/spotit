import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';
import '../models/bar.dart';
import '../widgets/bar_card.dart';
import '../services/opening_hours.dart';
import '../services/share_service.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Bar> bars;
  final Function(String) onFavoriteToggle;

  const FavoritesScreen({
    super.key,
    required this.bars,
    required this.onFavoriteToggle,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteBars = widget.bars.where((bar) => bar.isFavorite).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        title: Text(
          tr('fav.title'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (favoriteBars.isNotEmpty)
            TextButton.icon(
              onPressed: () => shareOnWhatsApp(plansShareText(favoriteBars)),
              icon: const Icon(Icons.share, size: 16, color: Color(0xFF25D366)),
              label: Text(
                tr('fav.share'),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF25D366),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: favoriteBars.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    tr('fav.empty'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      tr('fav.emptyHint'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: favoriteBars.length,
              itemBuilder: (context, index) {
                final bar = favoriteBars[index];
                return BarCard(
                  bar: bar,
                  openStatus: openStatus(bar.openingHours, DateTime.now()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          bar: bar,
                          onFavoriteToggle: () {
                            widget.onFavoriteToggle(bar.id);
                            setState(() {});
                          },
                        ),
                      ),
                    ).then((value) {
                      setState(() {});
                    });
                  },
                  onFavoriteTap: () {
                    widget.onFavoriteToggle(bar.id);
                    setState(() {});
                  },
                );
              },
            ),
    );
  }
}
