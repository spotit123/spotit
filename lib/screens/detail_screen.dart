import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/share_service.dart';
import '../models/bar.dart';
import '../models/review.dart';
import '../services/db_service.dart';
import 'booking_screen.dart';

class DetailScreen extends StatefulWidget {
  final Bar bar;
  final VoidCallback onFavoriteToggle;

  const DetailScreen({
    super.key,
    required this.bar,
    required this.onFavoriteToggle,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Live survey temporary choices
  int _surveyCrowdDensity = 50;
  String _surveyAge = '20s-30s';
  String _surveyMusic = 'Soft';
  bool _surveySubmitted = false;

  void _submitSurvey() async {
    setState(() {
      widget.bar.crowdDensity = _surveyCrowdDensity;
      widget.bar.crowdAge = _surveyAge;
      widget.bar.musicType = _surveyMusic;
      widget.bar.hasMusic = _surveyMusic != 'Nessuna';
      _surveySubmitted = true;
    });

    // Persist user crowd survey feedback to offline storage
    try {
      final bars = await DbService.getBars();
      final index = bars.indexWhere((b) => b.id == widget.bar.id);
      if (index != -1) {
        bars[index].crowdDensity = _surveyCrowdDensity;
        bars[index].crowdAge = _surveyAge;
        bars[index].musicType = _surveyMusic;
        bars[index].hasMusic = _surveyMusic != 'Nessuna';
        await DbService.saveBars(bars);
      }
    } catch (_) {}

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sondaggio inviato! Informazioni aggiornate per ${widget.bar.name}.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  Future<void> _shareBar() async {
    final ok = await shareOnWhatsApp(barShareText(widget.bar));
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossibile aprire WhatsApp.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _openMapDirections() async {
    final lat = widget.bar.latitude;
    final lng = widget.bar.longitude;
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Maps url';
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossibile aprire Google Maps per questo locale.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _openAddPhotoDialog() {
    final stockImages = [
      'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-151097252790b-af4f90267300?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=600&q=80',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aggiungi Foto Locale 📸',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tocca un\'immagine per caricarla nella galleria del locale (simulato)',
                style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stockImages.length,
                  itemBuilder: (context, index) {
                    final imgUrl = stockImages[index];
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          widget.bar.galleryImages.add(imgUrl);
                        });
                        
                        try {
                          final bars = await DbService.getBars();
                          final bIndex = bars.indexWhere((b) => b.id == widget.bar.id);
                          if (bIndex != -1) {
                            bars[bIndex].galleryImages.add(imgUrl);
                            await DbService.saveBars(bars);
                          }
                        } catch (_) {}

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Foto caricata con successo!', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green[800],
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                          image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _openAddReviewDialog() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lascia una Recensione ✍️',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stars Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1.0;
                      return IconButton(
                        icon: Icon(
                          selectedRating >= starVal ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setModalState(() {
                            selectedRating = starVal;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Comment Field
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cosa ne pensi di questo locale? Com\'è l\'atmosfera stasera?',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (commentController.text.trim().isEmpty) return;

                        final profile = await DbService.getUserProfile();
                        final newReview = Review(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userName: profile?.name ?? 'Alex Rivers',
                          userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80',
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                          date: '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}',
                        );

                        setState(() {
                          widget.bar.reviews.insert(0, newReview);
                          // Recalculate average rating
                          final totalRating = widget.bar.reviews.fold<double>(0, (sum, r) => sum + r.rating);
                          widget.bar.reviewCount = widget.bar.reviews.length;
                          widget.bar.rating = double.parse((totalRating / widget.bar.reviewCount).toStringAsFixed(1));
                        });

                        // Save to database
                        try {
                          final bars = await DbService.getBars();
                          final bIndex = bars.indexWhere((b) => b.id == widget.bar.id);
                          if (bIndex != -1) {
                            bars[bIndex].reviews.insert(0, newReview);
                            final totalRating = bars[bIndex].reviews.fold<double>(0, (sum, r) => sum + r.rating);
                            bars[bIndex].reviewCount = bars[bIndex].reviews.length;
                            bars[bIndex].rating = double.parse((totalRating / bars[bIndex].reviewCount).toStringAsFixed(1));
                            await DbService.saveBars(bars);
                          }
                        } catch (_) {}

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Recensione pubblicata con successo!', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green[800],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Invia Recensione', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bar = widget.bar;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark background
      body: Stack(
        children: [
          // Background Hero Image Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: Hero(
              tag: 'bar-image-${bar.id}',
              child: Image.network(
                bar.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          // Floating Back and Favorite Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.onFavoriteToggle();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      bar.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: bar.isFavorite ? Colors.pink : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Panel (Draggable Scrollable Sheet)
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.65,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF090D16), // Dark background matching body
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100), // padding bottom for float button
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title section
                      Text(
                        bar.name,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (bar.reviewCount > 0) ...[
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            bar.reviewCount > 0
                                ? '${bar.rating} (${bar.reviewCount} recensioni) • ${bar.type}'
                                : '${bar.type} • ancora nessuna recensione',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // THE VIBE Tags Section (matching screenshot 4)
                      Text(
                        'THE VIBE',
                        style: GoogleFonts.poppins(
                          color: Colors.amber[600],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: bar.vibeTags.map((vibe) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131B2E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Text(
                              vibe,
                              style: GoogleFonts.poppins(
                                color: Colors.blue[100],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Option C: GALLERY Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GALLERIA FOTO',
                            style: GoogleFonts.poppins(
                              color: Colors.amber[600],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF0066FF), size: 20),
                            onPressed: _openAddPhotoDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Main hero image
                            Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(bar.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Gallery items
                            ...bar.galleryImages.map((imgUrl) {
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: NetworkImage(imgUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }),
                            // Add button placeholder
                            GestureDetector(
                              onTap: _openAddPhotoDialog,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131B2E),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF1E293B), style: BorderStyle.solid),
                                ),
                                child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 28),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // LIVE INSIGHTS Card Box (matching screenshot 4 exactly!)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                  Text(
                                  'LIVE INSIGHTS',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0066FF), // Electric Blue
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                Text(
                                  'Aggiornato 2m fa',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Crowd Stats Row
                            Row(
                              children: [
                                // Crowd Age
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.face_outlined, color: Colors.amber, size: 24),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'CROWD AGE',
                                              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              bar.crowdAge,
                                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Gender Ratio
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people_outline, color: Colors.pink, size: 24),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'GENDER RATIO',
                                              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              bar.genderRatio,
                                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Crowd Density Progress Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Affollamento',
                                  style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                                ),
                                Text(
                                  '${bar.crowdDensity}% di capacità',
                                  style: GoogleFonts.poppins(
                                    color: bar.crowdDensity > 80 ? Colors.redAccent : Colors.greenAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: bar.crowdDensity / 100,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF1E293B),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  bar.crowdDensity > 80 ? Colors.redAccent : const Color(0xFF0066FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Real-time Check-In Survey System (Madrid Crowd feedback)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A), // Dark panel
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: _surveySubmitted
                            ? Center(
                                child: Column(
                                  children: [
                                    const Icon(Icons.done_all, color: Colors.greenAccent, size: 36),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Grazie per aver aggiornato la community!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.rate_review_outlined, color: Colors.pink, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sei in questo locale? Sondaggio Live 📣',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Question 1: Crowd Density slider/selector
                                  Text(
                                    'Quanto è affollato in questo momento?',
                                    style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                                  ),
                                  Slider(
                                    value: _surveyCrowdDensity.toDouble(),
                                    min: 0,
                                    max: 100,
                                    divisions: 10,
                                    label: '$_surveyCrowdDensity%',
                                    activeColor: const Color(0xFF0066FF),
                                    inactiveColor: const Color(0xFF131B2E),
                                    onChanged: (val) {
                                      setState(() {
                                        _surveyCrowdDensity = val.toInt();
                                      });
                                    },
                                  ),

                                  // Question 2: Vibe / Music type
                                  Text(
                                    'Che tipo di musica/vibe c\'è?',
                                    style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: ['Jazz', 'Techno', 'Pop', 'Nessuna'].map((music) {
                                      final isSelected = _surveyMusic == music;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _surveyMusic = music;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF131B2E),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            music,
                                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 14),

                                  // Question 3: Crowd Age
                                  Text(
                                    'Che tipo di persone frequentano il locale stasera?',
                                    style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: ['Gen Z', '20s-30s', '30s-50s', 'Professionals'].map((age) {
                                      final isSelected = _surveyAge == age;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _surveyAge = age;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF131B2E),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            age,
                                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submitSurvey,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1E293B),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(
                                        'Invia Aggiornamento',
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 24),

                      // ABOUT THE SPOT Section (matching screenshot 4)
                      Text(
                        'ABOUT THE SPOT',
                        style: GoogleFonts.poppins(
                          color: Colors.amber[600],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bar.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Option C: REVIEWS Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RECENSIONI CLIENTE',
                            style: GoogleFonts.poppins(
                              color: Colors.amber[600],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.rate_review, size: 16, color: Color(0xFF0066FF)),
                            label: Text(
                              'Scrivi',
                              style: GoogleFonts.poppins(color: const Color(0xFF0066FF), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _openAddReviewDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      bar.reviews.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131B2E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Nessuna recensione ancora. Sii il primo a scriverne una!',
                                  style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                                ),
                              ),
                            )
                          : Column(
                              children: bar.reviews.map((review) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF1E293B)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage: review.userAvatar.isEmpty
                                                ? null
                                                : NetworkImage(review.userAvatar),
                                            child: review.userAvatar.isEmpty
                                                ? Text(
                                                    review.userName.isEmpty ? '?' : review.userName[0].toUpperCase(),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review.userName,
                                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  review.date,
                                                  style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 10),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < review.rating ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                                size: 14,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        review.comment,
                                        style: GoogleFonts.poppins(color: Colors.grey[300], fontSize: 13, height: 1.4),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                      const SizedBox(height: 24),

                      // Location & Address details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LOCATION',
                            style: GoogleFonts.poppins(
                              color: Colors.amber[600],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: _shareBar,
                                child: Row(
                                  children: [
                                    const Icon(Icons.share, color: Color(0xFF25D366), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Condividi',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF25D366),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              InkWell(
                                onTap: _openMapDirections,
                                child: Row(
                                  children: [
                                    const Icon(Icons.directions, color: Color(0xFF0066FF), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Indicazioni',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF0066FF),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Location Info Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.bar.address,
                                style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Action Button Sheet (Secure a Table - matching screenshot 4)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(bar: bar),
                    ),
                  ).then((value) {
                    if (value == true && mounted) {
                      setState(() {});
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF), // Electric Blue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  'Richiedi un tavolo',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
