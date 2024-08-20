class Room {
  final int id;
  final String name;
  final String date;
  final String title;
  final String rideType;
  final List<dynamic> departureLocation;
  final List<dynamic> arrivalLocation;

  final String departure;
  final String arrival;

  final int currentParticipants;
  final int maxParticipants;
  final String createdAt;

  final String latestMessageSender;
  final String latestMessageContent;
  final int unreadMessageCount;

  Room({
    required this.id,
    required this.name,
    required this.date,
    required this.title,
    required this.rideType,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departure,
    required this.arrival,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.createdAt,
    required this.latestMessageSender,
    required this.latestMessageContent,
    required this.unreadMessageCount,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    List<int> dateParts = List<int>.from(json['createdAt']);
    List<int> departureTime = List<int>.from(json['departureTime']);

    List<dynamic> participants = json['participants'] ?? [];

    String formattedDate =
        "${dateParts[0]}-${dateParts[1].toString().padLeft(2, '0')}-${dateParts[2].toString().padLeft(2, '0')}";

    String formattedDepartureDate =
        "${departureTime[0]}-${departureTime[1].toString().padLeft(2, '0')}-${departureTime[2].toString().padLeft(2, '0')} ${departureTime[3].toString().padLeft(2, '0')}:${departureTime[4].toString().padLeft(2, '0')}";

    List<dynamic> departureLoc = [
      json['departureLocation']['latitude'],
      json['departureLocation']['longitude']
    ].map((e) => e.toDouble()).toList();

    List<dynamic> arrivalLoc = [
      json['destinationLocation']['latitude'],
      json['destinationLocation']['longitude']
    ].map((e) => e.toDouble()).toList();

    Map<String, dynamic> latestMessage = json['latestMessageResponse'] ?? {};

    return Room(
        id: json['id'],
        name: json['leaderNickname'],
        date: formattedDepartureDate,
        title: json['title'],
        rideType: json['roomType'],
        departureLocation: departureLoc,
        arrivalLocation: arrivalLoc,
        departure: json['departure'],
        arrival: json['destination'],
        currentParticipants: participants.length,
        maxParticipants: json['maxParticipants'],
        createdAt: formattedDate,
        latestMessageSender: latestMessage['sender'] ?? '',
        latestMessageContent: latestMessage['content'] ?? '',
        unreadMessageCount: json['unreadMessageCount'] ?? 0);
  }
}
