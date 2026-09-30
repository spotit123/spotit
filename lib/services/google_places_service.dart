import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bar.dart';
import '../models/review.dart';

class GooglePlacesService {
  // CONFIGURA LA TUA CHIAVE API DI GOOGLE CLOUD QUI
  // Esempio: static const String apiKey = '';
  static const String apiKey = '';

  /// Carica i dettagli reali da Google Places per ciascun locale.
  /// Se apiKey è vuota, restituisce il locale inalterato (con i dati di mock).
  static Future<Bar> fetchRealGoogleData(Bar bar) async {
    if (apiKey.isEmpty) {
      return bar; // Fallback al mock se non c'è chiave API
    }

    try {
      // 1. Cerca il Place ID usando il nome e l'indirizzo del locale
      final searchUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json'
        '?input=${Uri.encodeComponent('${bar.name} ${bar.address}')}'
        '&inputtype=textquery'
        '&fields=place_id'
        '&key=$apiKey'
      );

      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) return bar;

      final searchData = jsonDecode(searchResponse.body);
      final candidates = searchData['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return bar;

      final placeId = candidates[0]['place_id'] as String;

      // 2. Recupera i dettagli del locale da Google Places
      final detailsUrl = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,rating,user_ratings_total,formatted_phone_number,website,reviews,photos'
        '&key=$apiKey'
        '&language=it'
      );

      final detailsResponse = await http.get(detailsUrl);
      if (detailsResponse.statusCode != 200) return bar;

      final detailsData = jsonDecode(detailsResponse.body);
      final result = detailsData['result'] as Map<String, dynamic>?;
      if (result == null) return bar;

      // Estrai e mappa i dati di Google
      final googleRating = (result['rating'] as num?)?.toDouble() ?? bar.rating;
      final googleReviewCount = (result['user_ratings_total'] as num?)?.toInt() ?? bar.reviewCount;
      final googlePhone = result['formatted_phone_number'] as String? ?? bar.phone;
      final googleWebsite = result['website'] as String? ?? bar.website;

      // Mappa le foto di Google
      final List<String> googleGallery = [];
      final photosList = result['photos'] as List?;
      if (photosList != null) {
        for (var i = 0; i < photosList.length; i++) {
          final photoRef = photosList[i]['photo_reference'] as String;
          final photoUrl = 'https://maps.googleapis.com/maps/api/place/photo'
              '?maxwidth=800'
              '&photo_reference=$photoRef'
              '&key=$apiKey';
          googleGallery.add(photoUrl);
        }
      }

      // Mappa le recensioni di Google
      final List<Review> googleReviews = [];
      final reviewsList = result['reviews'] as List?;
      if (reviewsList != null) {
        for (var i = 0; i < reviewsList.length; i++) {
          final rev = reviewsList[i];
          googleReviews.add(
            Review(
              id: 'google_${bar.id}_$i',
              userName: rev['author_name'] as String? ?? 'Anonimo Google',
              userAvatar: rev['profile_photo_url'] as String? ?? 
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80',
              rating: (rev['rating'] as num?)?.toDouble() ?? 5.0,
              comment: rev['text'] as String? ?? '',
              date: rev['relative_time_description'] as String? ?? 'Recente',
            ),
          );
        }
      }

      // Restituisce un nuovo oggetto Bar combinando i dati locali con quelli di Google
      return Bar(
        id: bar.id,
        name: bar.name,
        type: bar.type,
        description: bar.description,
        rating: googleRating,
        reviewCount: googleReviewCount,
        address: bar.address,
        latitude: bar.latitude,
        longitude: bar.longitude,
        imageUrl: googleGallery.isNotEmpty ? googleGallery[0] : bar.imageUrl,
        distance: bar.distance,
        popularDrinks: bar.popularDrinks,
        phone: googlePhone,
        website: googleWebsite,
        openingHours: bar.openingHours,
        isFavorite: bar.isFavorite,
        vibeTags: bar.vibeTags,
        crowdDensity: bar.crowdDensity,
        crowdAge: bar.crowdAge,
        genderRatio: bar.genderRatio,
        hasMusic: bar.hasMusic,
        musicType: bar.musicType,
        reviews: googleReviews.isNotEmpty ? googleReviews : bar.reviews,
        galleryImages: googleGallery.isNotEmpty ? googleGallery.sublist(1) : bar.galleryImages,
      );
    } catch (_) {
      // In caso di errore di connessione o formato, fallisce silenziosamente ritornando i dati di mock
      return bar;
    }
  }
}
