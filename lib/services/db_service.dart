import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/bar.dart';
import '../models/booking.dart';
import '../data/mock_data.dart';

class DbService {
  static const String _keyProfile = 'user_profile';
  static const String _keyBars = 'bars';
  static const String _keyBookings = 'bookings';
  static const String _keyUsers = 'registered_users';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Forza la pulizia per il passaggio a Madrid
    final hasClearedForMadrid = _prefs?.getBool('cleared_for_madrid') ?? false;
    if (!hasClearedForMadrid) {
      await _prefs?.remove(_keyBars);
      await _prefs?.remove(_keyProfile);
      await _prefs?.remove(_keyBookings);
      await _prefs?.setBool('cleared_for_madrid', true);
    }

    // Seed default user if not exists
    final usersRaw = _prefs?.getString(_keyUsers);
    if (usersRaw == null) {
      final defaultUsers = [
        {
          'email': 'alex@spotit.com',
          'password': 'password123',
          'name': 'Alex Rivers',
          'username': '@vibe_seeker_99',
        }
      ];
      await _prefs?.setString(_keyUsers, jsonEncode(defaultUsers));
    }
  }

  // Auth Methods
  static Future<bool> login(String email, String password) async {
    if (email.trim() == 'admin@spotit.com' && password == 'admin123') {
      final profile = UserProfile(
        name: 'Administrator',
        username: '@admin',
        location: 'Madrid',
        age: 30,
        bookingsCount: 0,
        favoritesCount: 0,
        karma: 5.0,
        preferredVibes: ['Chill', 'Energetic', 'Underground', 'Neon', 'Rooftop'],
      );
      await saveUserProfile(profile);
      return true;
    }

    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_keyUsers);
    if (usersRaw != null) {
      final List<dynamic> users = jsonDecode(usersRaw);
      for (final u in users) {
        if (u['email'] == email && u['password'] == password) {
          // If profile doesn't exist, create it
          final existingProfile = await getUserProfile();
          if (existingProfile == null || existingProfile.username != u['username']) {
            final profile = UserProfile(
              name: u['name'] ?? 'User',
              username: u['username'] ?? '@user',
              location: 'Madrid',
              age: 25,
              bookingsCount: 0,
              favoritesCount: 0,
              karma: 4.5,
              preferredVibes: ['Chill', 'Energetic', 'Underground', 'Neon', 'Rooftop'],
            );
            await saveUserProfile(profile);
          }
          return true;
        }
      }
    }
    return false;
  }

  static Future<bool> signUp(String email, String password, String name, String username) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_keyUsers) ?? '[]';
    final List<dynamic> users = jsonDecode(usersRaw);
    
    // Check if email already registered
    for (final u in users) {
      if (u['email'] == email) {
        return false;
      }
    }
    
    users.add({
      'email': email,
      'password': password,
      'name': name,
      'username': username,
    });
    
    await prefs.setString(_keyUsers, jsonEncode(users));
    
    // Create new profile for this user
    final profile = UserProfile(
      name: name,
      username: username.startsWith('@') ? username : '@$username',
      location: 'Madrid',
      age: 22,
      bookingsCount: 0,
      favoritesCount: 0,
      karma: 5.0,
      preferredVibes: ['Chill', 'Energetic', 'Underground', 'Neon', 'Rooftop'],
    );
    await saveUserProfile(profile);
    return true;
  }

  // Profile Methods
  static Future<UserProfile?> getUserProfile() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw != null) {
      try {
        return UserProfile.fromJson(jsonDecode(raw));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  static Future<void> clearSession() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_keyProfile);
    await prefs.remove(_keyBookings);
    // Note: We don't remove bars list or registered users so that other people can login
  }

  // Bars Methods
  static Future<List<Bar>> getBars() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBars);
    if (raw != null) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        return list.map((item) => Bar.fromJson(item)).toList();
      } catch (e) {
        // Fallback to mock data if there's any corruption
      }
    }
    // Seed with mock data
    final barsList = List<Bar>.from(mockBars);
    await saveBars(barsList);
    return barsList;
  }

  static Future<void> saveBars(List<Bar> bars) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final listRaw = bars.map((bar) => bar.toJson()).toList();
    await prefs.setString(_keyBars, jsonEncode(listRaw));
  }

  // Bookings Methods
  static Future<List<Booking>> getBookings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBookings);
    if (raw != null) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        return list.map((item) => Booking.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> saveBookings(List<Booking> bookings) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final listRaw = bookings.map((b) => b.toJson()).toList();
    await prefs.setString(_keyBookings, jsonEncode(listRaw));
  }

  static Future<void> addBooking(Booking booking) async {
    final bookings = await getBookings();
    bookings.add(booking);
    await saveBookings(bookings);

    // Update profile bookingsCount
    final profile = await getUserProfile();
    if (profile != null) {
      final updated = profile.copyWith(
        bookingsCount: profile.bookingsCount + 1,
      );
      await saveUserProfile(updated);
    }
  }

  // Admin Methods
  static Future<bool> isCurrentUserAdmin() async {
    final profile = await getUserProfile();
    return profile != null && (profile.username == '@admin' || profile.name == 'Administrator');
  }

  static Future<List<Map<String, dynamic>>> getRegisteredUsers() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUsers);
    final List<Map<String, dynamic>> usersList = [];
    
    // Add default admin if not in store
    usersList.add({
      'name': 'Administrator',
      'username': '@admin',
      'email': 'admin@spotit.com',
      'role': 'Amministratore'
    });

    if (raw != null) {
      try {
        final List<dynamic> list = jsonDecode(raw);
        for (var item in list) {
          if (item['email'] != 'admin@spotit.com') {
            usersList.add({
              'name': item['name'] ?? 'User',
              'username': item['username'] ?? '@user',
              'email': item['email'] ?? '',
              'role': 'Utente'
            });
          }
        }
      } catch (_) {}
    }
    return usersList;
  }

  static Future<void> deleteReview(String barId, String reviewId) async {
    final bars = await getBars();
    final index = bars.indexWhere((b) => b.id == barId);
    if (index != -1) {
      final bar = bars[index];
      bar.reviews.removeWhere((r) => r.id == reviewId);
      bar.reviewCount = bar.reviews.length;
      if (bar.reviewCount > 0) {
        final total = bar.reviews.fold<double>(0, (sum, r) => sum + r.rating);
        bar.rating = double.parse((total / bar.reviewCount).toStringAsFixed(1));
      } else {
        bar.rating = 0.0;
      }
      await saveBars(bars);
    }
  }
}
