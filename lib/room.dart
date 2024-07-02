class Room {
  final int id;
  final String name;
  final String date;
  final int durationMinutes;
  final String title;
  final String rideType; // 왕복 or 편도
  final String departureLocation;
  final String arrivalLocation;
  final int currentParticipants;
  final int maxParticipants;
  final int unreadMessages;

  Room({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.title,
    required this.rideType,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.unreadMessages,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      durationMinutes: json['durationMinutes'],
      title: json['title'],
      rideType: json['tripType'],
      departureLocation: json['departureLocation'],
      arrivalLocation: json['arrivalLocation'],
      currentParticipants: json['currentPeople'],
      maxParticipants: json['maxParticipants'],
      unreadMessages: json['unreadMessages'],
    );
  }
}
