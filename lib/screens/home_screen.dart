import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../models/bar.dart';
import '../models/quiz_answers.dart';
import '../services/location_service.dart';
import '../services/opening_hours.dart';
import '../services/recommendation_service.dart';
import '../utils/geo.dart';
import '../widgets/bar_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Bar> bars;
  final QuizAnswers? quiz;
  final Function(String) onFavoriteToggle;

  const HomeScreen({
    super.key,
    required this.bars,
    this.quiz,
    required this.onFavoriteToggle,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _selectedMood = 'Tutti';

  // Filtri rapidi
  bool _openNow = false;
  bool _withMusic = false;
  int? _budget; // 1, 2 o 3 (€, €€, €€€)
  bool _nearMe = false;
  bool _locating = false;
  LatLng? _myPos;

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Tutti', 'icon': Icons.all_inclusive, 'color': Colors.grey},
    {'name': 'Energetic', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'name': 'Chill', 'icon': Icons.brightness_3, 'color': Colors.blue},
    {'name': 'Jazz', 'icon': Icons.music_note, 'color': Colors.purple},
    {'name': 'Live Music', 'icon': Icons.music_video, 'color': Colors.pink},
  ];

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0066FF) : const Color(0xFF131B2E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? const Color(0xFF0066FF) : const Color(0xFF1E293B)),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleNearMe() async {
    if (_nearMe) {
      setState(() => _nearMe = false);
      return;
    }
    setState(() => _locating = true);
    final pos = await LocationService.currentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _myPos = pos ?? _myPos;
      _nearMe = pos != null;
    });
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Non riesco a leggere la tua posizione. Controlla che il permesso sia attivo.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Stato di apertura di ogni locale, calcolato ora
    final now = DateTime.now();
    final statuses = {for (final b in widget.bars) b.id: openStatus(b.openingHours, now)};

    // Filter bars based on search and selected mood vibe
    final filteredBars = widget.bars.where((bar) {
      final matchesSearch = bar.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bar.address.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesMood = _selectedMood == 'Tutti' ||
          bar.vibeTags.any((vibe) => vibe.toLowerCase() == _selectedMood.toLowerCase()) ||
          (_selectedMood == 'Live Music' && bar.hasMusic);

      final matchesMusic = !_withMusic || bar.hasMusic;
      final matchesBudget = _budget == null || bar.priceLevel == _budget;
      final matchesOpen = !_openNow || statuses[bar.id]!.state == OpenState.open;

      return matchesSearch && matchesMood && matchesMusic && matchesBudget && matchesOpen;
    }).toList();

    // Con "Aperto ora" i locali senza orari non si possono mostrare: lo diciamo.
    final hiddenNoHours = !_openNow
        ? 0
        : widget.bars.where((b) => statuses[b.id]!.state == OpenState.unknown).length;

    // Distanza da me (solo se ho la posizione)
    final myPos = _myPos;
    final distances = <String, double>{
      if (myPos != null)
        for (final b in widget.bars)
          b.id: distanceKm(myPos.latitude, myPos.longitude, b.latitude, b.longitude),
    };

    // Con il quiz completato, i locali più adatti a te vengono per primi
    final quiz = widget.quiz;
    final scores = <String, int>{};
    if (quiz != null) {
      for (final bar in filteredBars) {
        scores[bar.id] = RecommendationService.score(bar, quiz);
      }
      filteredBars.sort((a, b) => scores[b.id]!.compareTo(scores[a.id]!));
    }
    // "Vicino a me" ha la precedenza sull'ordine del quiz
    if (_nearMe && myPos != null) {
      filteredBars.sort((a, b) => distances[a.id]!.compareTo(distances[b.id]!));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top search bar and filter button (matching screenshot 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Cerca bar a Madrid...',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Settings/Filter Button
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            // "What's the mood?" Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quiz != null ? 'Consigliati per te ✨' : "What's the mood?",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "See all",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0066FF), // Electric Blue
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Horizontal scrolling mood list (matching screenshot 1)
            SizedBox(
              height: 54,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  final isSelected = _selectedMood == mood['name'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMood = mood['name'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1A2B4C) : const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF1E293B),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              mood['icon'],
                              size: 14,
                              color: isSelected ? Colors.white : mood['color'],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mood['name'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Filtri rapidi: aperto ora, vicino a me, musica, budget
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _filterChip('🟢 Aperto ora', _openNow, () => setState(() => _openNow = !_openNow)),
                  _filterChip(_locating ? '📍 Cerco…' : '📍 Vicino a me', _nearMe, _toggleNearMe),
                  _filterChip('🎶 Con musica', _withMusic, () => setState(() => _withMusic = !_withMusic)),
                  for (final level in [1, 2, 3])
                    _filterChip('€' * level, _budget == level,
                        () => setState(() => _budget = _budget == level ? null : level)),
                ],
              ),
            ),
            if (hiddenNoHours > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text(
                  '$hiddenNoHours locali senza orari non vengono mostrati',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                ),
              ),

            const SizedBox(height: 8),

            // Madrid Bars List
            Expanded(
              child: filteredBars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_bar_outlined, size: 64, color: Colors.grey[700]),
                          const SizedBox(height: 16),
                          Text(
                            'Nessun bar trovato',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prova ad applicare una vibrazione diversa',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredBars.length,
                      itemBuilder: (context, index) {
                        final bar = filteredBars[index];
                        return BarCard(
                          bar: bar,
                          matchScore: scores[bar.id],
                          distanceKm: distances[bar.id],
                          openStatus: statuses[bar.id],
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
                            ).then((val) => setState(() {}));
                          },
                          onFavoriteTap: () {
                            widget.onFavoriteToggle(bar.id);
                            setState(() {});
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
