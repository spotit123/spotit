import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bar.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../services/db_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Bar> _bars = [];
  List<Booking> _bookings = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final barsList = await DbService.getBars();
      final bookingsList = await DbService.getBookings();
      final usersList = await DbService.getRegisteredUsers();

      // Sort bookings descending by ID (timestamp-like)
      bookingsList.sort((a, b) => b.id.compareTo(a.id));

      setState(() {
        _bars = barsList;
        _bookings = bookingsList;
        _users = usersList;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalReviews {
    int count = 0;
    for (var bar in _bars) {
      count += bar.reviews.length;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pannello Admin 🌋',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFEA580C),
          labelColor: const Color(0xFFEA580C),
          unselectedLabelColor: Colors.grey[500],
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.storefront, size: 20), text: 'Locali'),
            Tab(icon: Icon(Icons.confirmation_number_outlined, size: 20), text: 'Prenot.'),
            Tab(icon: Icon(Icons.rate_review_outlined, size: 20), text: 'Recens.'),
            Tab(icon: Icon(Icons.group_outlined, size: 20), text: 'Utenti'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEA580C)))
          : Column(
              children: [
                // Top KPI dashboard row
                _buildKPIDashboard(),
                const Divider(color: Colors.white10, height: 1),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBarsTab(),
                      _buildBookingsTab(),
                      _buildReviewsTab(),
                      _buildUsersTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildKPIDashboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF131B2E).withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildKPICard('Prenotazioni', _bookings.length.toString(), const Color(0xFF0066FF)),
          _buildKPICard('Recensioni', _totalReviews.toString(), Colors.amber),
          _buildKPICard('Utenti Reg.', _users.length.toString(), Colors.purpleAccent),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.03)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Locali Control
  Widget _buildBarsTab() {
    if (_bars.isEmpty) {
      return Center(
        child: Text(
          'Nessun locale caricato.',
          style: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bars.length,
      itemBuilder: (context, index) {
        final bar = _bars[index];
        final isHigh = bar.crowdDensity > 80;

        return Card(
          color: const Color(0xFF131B2E),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        bar.imageUrl,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 42,
                          height: 42,
                          color: Colors.grey[850],
                          child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bar.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bar.type,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHigh ? Colors.redAccent.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Cap: ${bar.crowdDensity}%',
                        style: GoogleFonts.poppins(
                          color: isHigh ? Colors.redAccent[100] : Colors.green[300],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          activeTrackColor: const Color(0xFF0066FF),
                          inactiveTrackColor: Colors.grey[800],
                          thumbColor: const Color(0xFF0066FF),
                          overlayColor: const Color(0xFF0066FF).withOpacity(0.12),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: bar.crowdDensity.toDouble(),
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              bar.crowdDensity = value.toInt();
                            });
                          },
                          onChangeEnd: (value) async {
                            await DbService.saveBars(_bars);
                          },
                        ),
                      ),
                    ),
                    Text(
                      '${bar.crowdDensity}%',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 2: Prenotazioni
  Widget _buildBookingsTab() {
    if (_bookings.isEmpty) {
      return Center(
        child: Text(
          'Nessuna prenotazione trovata.',
          style: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        final isPriority = booking.joinPriorityList;

        return Card(
          color: const Color(0xFF131B2E),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0066FF).withOpacity(0.1),
              child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFF0066FF)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.barName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPriority)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'PRIORITARIO',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF0066FF),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Data: ${booking.date} • Ore: ${booking.time} • ${booking.guestCount} Persone',
                  style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 11),
                ),
                if (booking.specialRequests.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Richieste: "${booking.specialRequests}"',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 3: Recensioni Moderation
  Widget _buildReviewsTab() {
    final allReviews = <Map<String, dynamic>>[];
    for (var bar in _bars) {
      for (var rev in bar.reviews) {
        allReviews.add({
          'barId': bar.id,
          'barName': bar.name,
          'review': rev,
        });
      }
    }

    if (allReviews.isEmpty) {
      return Center(
        child: Text(
          'Nessuna recensione trovata.',
          style: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allReviews.length,
      itemBuilder: (context, index) {
        final item = allReviews[index];
        final String barId = item['barId'];
        final String barName = item['barName'];
        final Review rev = item['review'];

        return Card(
          color: const Color(0xFF131B2E),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Su $barName',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFEA580C),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF131B2E),
                            title: Text(
                              'Moderazione Recensione',
                              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            content: Text(
                              'Vuoi eliminare definitivamente questa recensione scritta da ${rev.userName}?',
                              style: GoogleFonts.poppins(color: Colors.grey[400]),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Annulla', style: GoogleFonts.poppins(color: Colors.grey[450])),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Elimina', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await DbService.deleteReview(barId, rev.id);
                          await _loadAllData();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Recensione eliminata con successo', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green[805] ?? Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(rev.userAvatar),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rev.userName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (starIdx) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: starIdx < rev.rating ? Colors.amber : Colors.grey[700],
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rev.comment,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[300],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    rev.date,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // TAB 4: Utenti
  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'Nessun utente registrato.',
          style: GoogleFonts.poppins(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final String role = user['role'] ?? 'Utente';
        final bool isAdmin = role == 'Amministratore';

        return Card(
          color: const Color(0xFF131B2E),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: isAdmin ? Colors.orange.withOpacity(0.1) : Colors.grey[850],
              child: Icon(
                isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                color: isAdmin ? Colors.orange : Colors.grey[400],
              ),
            ),
            title: Text(
              user['name'] ?? 'User',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              user['username'] ?? '@user',
              style: GoogleFonts.poppins(
                color: const Color(0xFF0066FF),
                fontSize: 11,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.orange.withOpacity(0.12) : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  color: isAdmin ? Colors.orange[300] : Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
