import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/bar.dart';
import 'models/user_profile.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_spot_screen.dart';
import 'screens/login_screen.dart';
import 'services/db_service.dart';
import 'services/google_places_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final profile = await DbService.getUserProfile();
    setState(() {
      _isLoggedIn = profile != null;
      _isLoading = false;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() async {
    await DbService.clearSession();
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const Scaffold(
          backgroundColor: Color(0xFF090D16),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF0066FF)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'SpotIt Madrid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0066FF), // Electric Blue
        scaffoldBackgroundColor: const Color(0xFF090D16), // Dark Slate Background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0066FF),
          secondary: Color(0xFFEA580C),
          surface: Color(0xFF131B2E),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: _isLoggedIn
          ? MainNavigationWrapper(onLogout: _onLogout)
          : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  final VoidCallback onLogout;

  const MainNavigationWrapper({
    super.key,
    required this.onLogout,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  List<Bar> _bars = [];
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = await DbService.getUserProfile();
    final barsList = await DbService.getBars();
    
    // Auto-update user profile's favoritesCount to match actual favorites list
    final favCount = barsList.where((b) => b.isFavorite).length;
    UserProfile? updatedProfile = profile;
    if (profile != null && profile.favoritesCount != favCount) {
      updatedProfile = profile.copyWith(favoritesCount: favCount);
      await DbService.saveUserProfile(updatedProfile);
    }

    setState(() {
      _userProfile = updatedProfile;
      _bars = barsList;
      _isLoading = false;
    });

    // Avvia l'arricchimento in background dei dati con Google Places API
    _enrichBarsWithGoogle(barsList);
  }

  Future<void> _enrichBarsWithGoogle(List<Bar> currentBars) async {
    List<Bar> enriched = [];
    bool changed = false;

    for (var bar in currentBars) {
      final googleBar = await GooglePlacesService.fetchRealGoogleData(bar);
      enriched.add(googleBar);
      // Se ci sono cambiamenti reali nei dati scaricati da Google (es. nuove foto o recensioni)
      if (googleBar.reviewCount != bar.reviewCount || 
          googleBar.rating != bar.rating || 
          googleBar.galleryImages.length != bar.galleryImages.length) {
        changed = true;
      }
    }

    if (changed && mounted) {
      setState(() {
        _bars = enriched;
      });
      await DbService.saveBars(enriched);
    }
  }

  void _toggleFavorite(String id) async {
    setState(() {
      final index = _bars.indexWhere((bar) => bar.id == id);
      if (index != -1) {
        _bars[index].isFavorite = !_bars[index].isFavorite;
      }
    });
    await DbService.saveBars(_bars);
    
    // Dynamic updates of favorites count in profile
    if (_userProfile != null) {
      final favCount = _bars.where((bar) => bar.isFavorite).length;
      final updated = _userProfile!.copyWith(favoritesCount: favCount);
      setState(() {
        _userProfile = updated;
      });
      await DbService.saveUserProfile(updated);
    }
  }

  void _addNewBar(Bar newBar) async {
    setState(() {
      _bars.add(newBar);
    });
    await DbService.saveBars(_bars);
  }

  void _updateProfile(UserProfile updated) async {
    setState(() {
      _userProfile = updated;
    });
    await DbService.saveUserProfile(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D16),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0066FF)),
        ),
      );
    }

    final List<Widget> screens = [
      HomeScreen(
        bars: _bars,
        onFavoriteToggle: _toggleFavorite,
      ),
      MapScreen(
        bars: _bars,
        onFavoriteToggle: _toggleFavorite,
      ),
      FavoritesScreen(
        bars: _bars,
        onFavoriteToggle: _toggleFavorite,
      ),
      ProfileScreen(
        profile: _userProfile ?? UserProfile(
          name: 'Anonymous',
          username: '@anonymous',
          location: 'Madrid',
          age: 25,
          bookingsCount: 0,
          favoritesCount: 0,
          karma: 4.0,
          preferredVibes: [],
        ),
        bars: _bars,
        onProfileUpdate: _updateProfile,
        onFavoriteToggle: _toggleFavorite,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // Float shortcut button to Add Spot (Madrid layout)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSpotScreen(onAddBar: _addNewBar),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0066FF),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_location_alt_outlined),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 3) {
              // Reload profile data from DB to capture any new bookings/karma updates
              _loadData();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF131B2E), // Dark bar
          selectedItemColor: const Color(0xFF0066FF), // Electric Blue
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_bar),
              label: 'Locali',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mappa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Preferiti',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}
