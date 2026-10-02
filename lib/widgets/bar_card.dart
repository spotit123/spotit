import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bar.dart';
import '../services/opening_hours.dart';
import '../utils/geo.dart';

class BarCard extends StatelessWidget {
  final Bar bar;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final int? matchScore; // 0-100, from the onboarding quiz
  final double? distanceKm; // distanza dall'utente, se ha dato la posizione
  final OpenStatus? openStatus; // aperto/chiuso adesso

  const BarCard({
    super.key,
    required this.bar,
    required this.onTap,
    required this.onFavoriteTap,
    this.matchScore,
    this.distanceKm,
    this.openStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E), // Dark card background from screenshot
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1E293B).withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Header with Rating Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    bar.imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[900],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                // Rating (top right, matching screenshot) - hidden until there are reviews
                if (bar.reviewCount > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        bar.rating.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (matchScore != null)
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '✨ $matchScore% per te',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite Heart Button
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        bar.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: bar.isFavorite ? Colors.pink : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body (matching screenshot elements)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          bar.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Crowd Gender Icon indicator (pink badge, matching screenshot)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.pink[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Distance + open/closed
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          distanceKm != null
                              ? '${formatDistance(distanceKm!)} · ${walkMinutes(distanceKm!)} min a piedi'
                              : '${bar.distance} km dal centro',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (openStatus?.label != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: openStatus!.state == OpenState.open ? Colors.greenAccent[400] : Colors.redAccent,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            openStatus!.label!,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: openStatus!.state == OpenState.open
                                  ? Colors.greenAccent[400]
                                  : Colors.redAccent[100],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Vibe & Music Badges (matching screenshot)
                  Row(
                    children: [
                      _buildOutlineBadge(bar.vibeTags.first),
                      const SizedBox(width: 8),
                      _buildOutlineBadge(bar.musicType == 'None' ? 'No Music' : bar.musicType),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    bar.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.blue[100],
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
