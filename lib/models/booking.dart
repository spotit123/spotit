class Booking {
  final String id;
  final String barId;
  final String barName;
  final String barImageUrl;
  final String date; // E.g. "05/06"
  final String time; // E.g. "21:00"
  final int guestCount;
  final String specialRequests;
  final bool joinPriorityList;

  Booking({
    required this.id,
    required this.barId,
    required this.barName,
    required this.barImageUrl,
    required this.date,
    required this.time,
    required this.guestCount,
    required this.specialRequests,
    required this.joinPriorityList,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barId': barId,
      'barName': barName,
      'barImageUrl': barImageUrl,
      'date': date,
      'time': time,
      'guestCount': guestCount,
      'specialRequests': specialRequests,
      'joinPriorityList': joinPriorityList,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      barId: json['barId'] as String,
      barName: json['barName'] as String,
      barImageUrl: json['barImageUrl'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      guestCount: json['guestCount'] as int,
      specialRequests: json['specialRequests'] as String? ?? '',
      joinPriorityList: json['joinPriorityList'] as bool? ?? false,
    );
  }
}
