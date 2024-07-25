class Room {
  final int id;
  final String name;
  final String date;
  final String title;
  final String rideType; // 왕복 or 편도
  final String departureLocation;
  final String arrivalLocation;
  final int currentParticipants;
  final int maxParticipants;
  final int unreadMessages;
  final String createdAt;

  Room(
      {required this.id,
      required this.name,
      required this.date,
      required this.title,
      required this.rideType,
      required this.departureLocation,
      required this.arrivalLocation,
      required this.currentParticipants,
      required this.maxParticipants,
      required this.unreadMessages,
      required this.createdAt});

  factory Room.fromJson(Map<String, dynamic> json) {
    List<int> dateParts = List<int>.from(json['createdAt']);
    List<int> departureTime = List<int>.from(json['departureTime']);

    List<dynamic> participants = json['participants'] ?? [];

    String formattedDate =
        "${dateParts[0]}-${dateParts[1].toString().padLeft(2, '0')}-${dateParts[2].toString().padLeft(2, '0')}";

    String formattedDepartureDate =
        "${departureTime[0]}-${departureTime[1].toString().padLeft(2, '0')}-${departureTime[2].toString().padLeft(2, '0')} ${departureTime[3].toString().padLeft(2, '0')}:${departureTime[4].toString().padLeft(2, '0')}";

    return Room(
        id: json['id'],
        name: json['leaderNickname'],
        date: formattedDepartureDate,
        title: json['title'],
        rideType: json['roomType'],
        departureLocation: json['departure'],
        arrivalLocation: json['destination'],
        currentParticipants: participants.length,
        maxParticipants: json['maxParticipants'],
        unreadMessages: 0,
        createdAt: formattedDate);
  }
}
