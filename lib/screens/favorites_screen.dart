import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bar.dart';
import '../widgets/bar_card.dart';
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
          'I tuoi Preferiti ❤️',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: favoriteBars.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun preferito salvato',
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
                      'Aggiungi i tuoi bar preferiti cliccando sull\'icona del cuore sui dettagli o sulla lista.',
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
