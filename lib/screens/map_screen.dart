import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bar.dart';
import 'booking_screen.dart';

class MapScreen extends StatefulWidget {
  final List<Bar> bars;
  final Function(String) onFavoriteToggle;

  const MapScreen({
    super.key,
    required this.bars,
    required this.onFavoriteToggle,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Bar? _selectedBar;
  final MapController _mapController = MapController();
  String _selectedVibe = 'Tutti';

  final List<String> _vibes = ['Tutti', 'Energetic', 'Chill', 'Live Music'];

  void _selectBar(Bar bar) {
    setState(() {
      _selectedBar = bar;
    });
    // Center map on selected bar
    _mapController.move(LatLng(bar.latitude, bar.longitude), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    // Filter markers based on selected vibe
    final filteredBars = widget.bars.where((bar) {
      if (_selectedVibe == 'Tutti') return true;
      if (_selectedVibe == 'Live Music') return bar.hasMusic;
      return bar.vibeTags.any((v) => v.toLowerCase() == _selectedVibe.toLowerCase());
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map with dark/gray style tiles (using carto dark tiles for premium dark style map!)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(40.4270, -3.7020), // Madrid Center (Malasaña)
              initialZoom: 14.5,
              // Con più locali, la mappa parte inquadrandoli tutti
              initialCameraFit: widget.bars.length > 1
                  ? CameraFit.bounds(
                      bounds: LatLngBounds.fromPoints(
                        widget.bars.map((b) => LatLng(b.latitude, b.longitude)).toList(),
                      ),
                      padding: const EdgeInsets.fromLTRB(48, 160, 48, 120),
                      maxZoom: 16,
                    )
                  : null,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedBar = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', // PREMIUM dark style tile server!
                // Se il server CARTO non risponde, si usa la mappa standard di OpenStreetMap
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.spotit.app',
              ),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap contributors © CARTO'),
              ),
              MarkerLayer(
                markers: filteredBars.map((bar) {
                  final isSelected = _selectedBar?.id == bar.id;
                  return Marker(
                    point: LatLng(bar.latitude, bar.longitude),
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () => _selectBar(bar),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: isSelected ? const Color(0xFF0066FF) : Colors.pink[400],
                            size: isSelected ? 48 : 38,
                          ),
                          Positioned(
                            top: isSelected ? 6 : 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_bar,
                                size: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Header Overlay with Search bar and Vibe filters (matching screenshot 3)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF090D16).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Cerca locali a Madrid...',
                                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filters button
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D16).withOpacity(0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vibe filter pills (High Energy, Chill, Live Music, etc.)
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _vibes.length,
                    itemBuilder: (context, index) {
                      final vibe = _vibes[index];
                      final isSelected = _selectedVibe == vibe;
                      
                      IconData vibeIcon = Icons.local_fire_department;
                      Color iconColor = Colors.orange;
                      if (vibe == 'Chill') {
                        vibeIcon = Icons.local_bar;
                        iconColor = Colors.teal;
                      } else if (vibe == 'Live Music') {
                        vibeIcon = Icons.music_note;
                        iconColor = Colors.pink;
                      } else if (vibe == 'Tutti') {
                        vibeIcon = Icons.all_inclusive;
                        iconColor = Colors.grey;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVibe = vibe;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1A2B4C) : const Color(0xFF090D16).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF1E293B),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(vibeIcon, size: 12, color: iconColor),
                                const SizedBox(width: 6),
                                Text(
                                  vibe,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
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
              ],
            ),
          ),

          // Bottom Booking & Info Card overlay (matching screenshot 3 exactly!)
          if (_selectedBar != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E), // Dark theme popup card
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // Round image (screenshot style)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _selectedBar!.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 72,
                                height: 72,
                                color: Colors.grey[800],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedBar!.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_selectedBar!.musicType} • ${_selectedBar!.vibeTags.first}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Crowd Age & Gender (matching screenshot: e.g. "Gen Z • Students")
                                Text(
                                  '${_selectedBar!.crowdAge} • Locals',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // "Book a Table" action button (blue button from screenshot 3 overlay)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingScreen(bar: _selectedBar!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF), // Electric blue
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            'Book a Table',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
