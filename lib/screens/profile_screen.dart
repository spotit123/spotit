import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_profile.dart';
import '../l10n/l10n.dart';
import '../models/bar.dart';
import '../widgets/lang_button.dart';
import '../services/db_service.dart';
import 'detail_screen.dart';
import 'admin_panel_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final List<Bar> bars;
  final Function(UserProfile) onProfileUpdate;
  final Function(String) onFavoriteToggle;
  final VoidCallback onLogout;
  final VoidCallback onRetakeQuiz;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.bars,
    required this.onProfileUpdate,
    required this.onFavoriteToggle,
    required this.onLogout,
    required this.onRetakeQuiz,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEditProfileDialog() {
    final nameController = TextEditingController(text: widget.profile.name);
    final usernameController = TextEditingController(text: widget.profile.username);
    final locationController = TextEditingController(text: widget.profile.location);
    final ageController = TextEditingController(text: widget.profile.age.toString());
    final formKey = GlobalKey<FormState>();

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
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tr('prof.edit'),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                _buildEditField(tr('prof.name'), nameController, (val) => val!.isEmpty ? tr('prof.errName') : null),
                // Username Field
                _buildEditField(tr('login.username'), usernameController, (val) => val!.isEmpty ? tr('prof.errUsername') : null),
                // Location Field
                _buildEditField(tr('prof.city'), locationController, (val) => val!.isEmpty ? tr('prof.errCity') : null),
                // Age Field
                _buildEditField(tr('prof.age'), ageController, (val) => val!.isEmpty ? tr('prof.errAge') : null, keyboardType: TextInputType.number),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final updated = widget.profile.copyWith(
                          name: nameController.text,
                          username: usernameController.text,
                          location: locationController.text,
                          age: int.tryParse(ageController.text) ?? widget.profile.age,
                        );
                        widget.onProfileUpdate(updated);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Profilo aggiornato!', style: GoogleFonts.poppins()),
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
                    child: Text(
                      tr('prof.save'),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller,
    String? Function(String?)? validator, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteBars = widget.bars.where((bar) => bar.isFavorite).toList();
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Artistic Header
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Abstract Digital background
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF311042)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Opacity(
                    opacity: 0.15,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20,
                      ),
                      itemCount: 200,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.all(1),
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),

                // Edit Profile Button (top right)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.white, size: 28),
                    onPressed: _openEditProfileDialog,
                  ),
                ),

                // Title Label
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  child: Text(
                    tr('prof.title'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Floating Avatar
                Positioned(
                  bottom: -50,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.purpleAccent, Colors.pink],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFF090D16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // User Info Section
            Center(
              child: Column(
                children: [
                  Text(
                    profile.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.username,
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📍 ${profile.location} • ${tr('prof.ageYears', {'age': profile.age})}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Badges Row
            // I badge si guadagnano: non sono più uguali per tutti
            if (profile.favoritesCount >= 3 || profile.bookingsCount >= 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profile.favoritesCount >= 3)
                    _buildBadge(
                      label: tr('prof.badgeVibe'),
                      icon: Icons.diamond_outlined,
                      bgColor: Colors.amber.withOpacity(0.12),
                      iconColor: Colors.amber[600]!,
                    ),
                  if (profile.favoritesCount >= 3 && profile.bookingsCount >= 3) const SizedBox(width: 12),
                  if (profile.bookingsCount >= 3)
                    _buildBadge(
                      label: tr('prof.badgePro'),
                      icon: Icons.verified_user_outlined,
                      bgColor: Colors.blue.withOpacity(0.12),
                      iconColor: const Color(0xFF0066FF),
                    ),
                ],
              ),

            const SizedBox(height: 24),

            // Stats row (Bookings, Favorites, Karma)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(profile.bookingsCount.toString(), tr('prof.bookings')),
                  const SizedBox(width: 12),
                  _buildStatCard(favoriteBars.length.toString(), tr('prof.favorites')),
                  const SizedBox(width: 12),
                  _buildStatCard(profile.karma.toString(), 'Karma'),
                ],
              ),
            ),

            // Admin Panel Button (visible only to admins)
            FutureBuilder<bool>(
              future: DbService.isCurrentUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEA580C), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEA580C).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminPanelScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                        label: Text(
                          'Pannello Amministratore',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 28),

            // Your Vibe Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('prof.vibeProfile'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildVibeTag(trVibe('Energetic'), Icons.local_fire_department, Colors.orange),
                      _buildVibeTag(trVibe('Chill'), Icons.brightness_3, Colors.blue),
                      _buildVibeTag(trVibe('Underground'), Icons.home_work_outlined, Colors.purple),
                      _buildVibeTag(trVibe('Neon'), Icons.wb_twilight_outlined, Colors.pink),
                      _buildVibeTag(trVibe('Rooftop'), Icons.domain_outlined, Colors.teal),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Favorite Spots Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('prof.favSpots'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    tr('prof.seeAll'),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0066FF),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List of favorite spots
            favoriteBars.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          tr('prof.noFav'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: favoriteBars.length,
                    itemBuilder: (context, index) {
                      final bar = favoriteBars[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
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
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  bar.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.local_fire_department, size: 12, color: Colors.orange[800]),
                                        const SizedBox(width: 4),
                                        Text(
                                          bar.vibeTags.join(' • '),
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      bar.address,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.pink),
                                onPressed: () {
                                  widget.onFavoriteToggle(bar.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 20),
            // Lingua
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Center(child: LangButton()),
            ),
            // Retake quiz
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: widget.onRetakeQuiz,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    foregroundColor: const Color(0xFF0066FF),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    tr('prof.retake'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF131B2E),
                        title: Text(
                          tr('prof.logoutTitle'),
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          tr('prof.logoutAsk'),
                          style: GoogleFonts.poppins(color: Colors.grey[400]),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(tr('prof.cancel'), style: GoogleFonts.poppins(color: Colors.grey[400])),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              widget.onLogout();
                            },
                            child: Text(tr('prof.logout'), style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    foregroundColor: Colors.redAccent,
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    tr('prof.logout'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: const Color(0xFF0066FF),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibeTag(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
