import '../l10n/l10n.dart';
import 'review.dart';

class Bar {
  final String id;
  final String name;
  final String type;
  final String description;

  /// Descrizioni tradotte (it/en/es), se disponibili. Se manca la lingua si usa [description].
  final Map<String, String> descriptions;
  double rating; // Modified to non-final so we can dynamically recalculate average rating
  int reviewCount; // Modified to non-final to update dynamically
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double distance; // in km from user
  final int priceLevel; // 1 = €, 2 = €€, 3 = €€€
  final List<String> popularDrinks;
  final String phone;
  final String website;
  final Map<String, String> openingHours;
  bool isFavorite;

  // Madrid Vibe Metrics
  final List<String> vibeTags;
  int crowdDensity; // Percentage e.g. 65
  String crowdAge;  // e.g. "Gen Z", "20s-30s"
  String genderRatio; // e.g. "50% M / 50% F"
  bool hasMusic;
  String musicType;  // e.g. "Jazz", "Techno", "Pop"

  // Option C: Reviews and Gallery
  final List<Review> reviews;
  final List<String> galleryImages;

  Bar({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.descriptions = const {},
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.distance,
    this.priceLevel = 2,
    required this.popularDrinks,
    required this.phone,
    required this.website,
    required this.openingHours,
    this.isFavorite = false,
    required this.vibeTags,
    required this.crowdDensity,
    required this.crowdAge,
    required this.genderRatio,
    required this.hasMusic,
    required this.musicType,
    required this.reviews,
    required this.galleryImages,
  });

  /// Descrizione nella lingua corrente.
  String get localDescription => descriptions[L10n.code] ?? description;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'descriptions': descriptions,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'distance': distance,
      'priceLevel': priceLevel,
      'popularDrinks': popularDrinks,
      'phone': phone,
      'website': website,
      'openingHours': openingHours,
      'isFavorite': isFavorite,
      'vibeTags': vibeTags,
      'crowdDensity': crowdDensity,
      'crowdAge': crowdAge,
      'genderRatio': genderRatio,
      'hasMusic': hasMusic,
      'musicType': musicType,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'galleryImages': galleryImages,
    };
  }

  factory Bar.fromJson(Map<String, dynamic> json) {
    return Bar(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      descriptions: json['descriptions'] == null
          ? const {}
          : Map<String, String>.from(json['descriptions'] as Map),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      distance: (json['distance'] as num).toDouble(),
      priceLevel: json['priceLevel'] as int? ?? 2,
      popularDrinks: List<String>.from(json['popularDrinks'] as List),
      phone: json['phone'] as String,
      website: json['website'] as String,
      openingHours: Map<String, String>.from(json['openingHours'] as Map),
      isFavorite: json['isFavorite'] as bool? ?? false,
      vibeTags: List<String>.from(json['vibeTags'] as List),
      crowdDensity: json['crowdDensity'] as int,
      crowdAge: json['crowdAge'] as String,
      genderRatio: json['genderRatio'] as String,
      hasMusic: json['hasMusic'] as bool,
      musicType: json['musicType'] as String,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : [],
      galleryImages: json['galleryImages'] != null
          ? List<String>.from(json['galleryImages'] as List)
          : [],
    );
  }
}
