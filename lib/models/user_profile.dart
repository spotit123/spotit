class UserProfile {
  String name;
  String username;
  String location;
  int age;
  int bookingsCount;
  int favoritesCount;
  double karma;
  List<String> preferredVibes;

  UserProfile({
    required this.name,
    required this.username,
    required this.location,
    required this.age,
    required this.bookingsCount,
    required this.favoritesCount,
    required this.karma,
    required this.preferredVibes,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? location,
    int? age,
    int? bookingsCount,
    int? favoritesCount,
    double? karma,
    List<String>? preferredVibes,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      location: location ?? this.location,
      age: age ?? this.age,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      karma: karma ?? this.karma,
      preferredVibes: preferredVibes ?? this.preferredVibes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'location': location,
      'age': age,
      'bookingsCount': bookingsCount,
      'favoritesCount': favoritesCount,
      'karma': karma,
      'preferredVibes': preferredVibes,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      username: json['username'] as String,
      location: json['location'] as String,
      age: json['age'] as int,
      bookingsCount: json['bookingsCount'] as int,
      favoritesCount: json['favoritesCount'] as int,
      karma: (json['karma'] as num).toDouble(),
      preferredVibes: List<String>.from(json['preferredVibes'] as List),
    );
  }
}
