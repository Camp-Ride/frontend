import 'package:campride/message_type.dart';
import 'package:campride/participants.dart';

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

  final List<dynamic> currentParticipants;
  final int trainingDays;
  final int maxParticipants;
  final String createdAt;

  late String latestMessageSender;
  late String latestMessageNickname;
  late String latestMessageContent;
  late ChatMessageType latestMessageType;
  late String latestMessageCreatedAt;
  late int unreadMessageCount;

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
    required this.trainingDays,
    required this.maxParticipants,
    required this.createdAt,
    required this.latestMessageSender,
    required this.latestMessageNickname,
    required this.latestMessageContent,
    required this.latestMessageType,
    required this.latestMessageCreatedAt,
    required this.unreadMessageCount,
  });

  static ChatMessageType fromType(String type) {
    if (type == "TEXT") {
      return ChatMessageType.TEXT;
    } else if (type == "IMAGE") {
      return ChatMessageType.IMAGE;
    } else if (type == "LEAVE") {
      return ChatMessageType.LEAVE;
    } else {
      return ChatMessageType.JOIN;
    }
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    // createdAt 및 departureTime을 적절히 포맷팅
    String formatDate(List<int> dateParts) {
      return "${dateParts[0]}-${dateParts[1].toString().padLeft(2, '0')}-${dateParts[2].toString().padLeft(2, '0')}";
    }

    String formatDateTime(List<int> dateTimeParts) {
      return "${dateTimeParts[0]}-${dateTimeParts[1].toString().padLeft(2, '0')}-${dateTimeParts[2].toString().padLeft(2, '0')} "
          "${dateTimeParts[3].toString().padLeft(2, '0')}:${dateTimeParts[4].toString().padLeft(2, '0')}";
    }

    // 출발지 및 도착지 위치를 List<double>로 변환
    List<dynamic> departureLoc = [
      json['departureLocation']['latitude'],
      json['departureLocation']['longitude']
    ].map((e) => e.toDouble()).toList();

    List<dynamic> arrivalLoc = [
      json['destinationLocation']['latitude'],
      json['destinationLocation']['longitude']
    ].map((e) => e.toDouble()).toList();

    // latestMessageResponse 처리
    Map<String, dynamic> latestMessage = json['latestMessageResponse'] ?? {};
    String latestMessageCreatedAtFormatted = latestMessage.isNotEmpty
        ? formatDateTime(List<int>.from(latestMessage['createdAt']))
        : '';

    return Room(
      id: json['id'],
      name: json['leaderNickname'],
      date: formatDateTime(List<int>.from(json['departureTime'])),
      title: json['title'],
      rideType: json['roomType'],
      departureLocation: departureLoc,
      arrivalLocation: arrivalLoc,
      departure: json['departure'],
      arrival: json['destination'],
      currentParticipants: json['participants']
          .map((participant) => Participant.fromJson(participant))
          .toList(),
      trainingDays: json['trainingDays'],
      maxParticipants: json['maxParticipants'],
      createdAt: formatDate(List<int>.from(json['createdAt'])),
      latestMessageSender: latestMessage['sender'] ?? '',
      latestMessageNickname: latestMessage['nickname'] ?? '',
      latestMessageContent: latestMessage['content'] ?? '',
      latestMessageType: latestMessage['chatMessageType'] == null ? ChatMessageType.TEXT : fromType(latestMessage['chatMessageType']),
      latestMessageCreatedAt: latestMessageCreatedAtFormatted,
      unreadMessageCount: json['unreadMessageCount'] ?? 0,
    );
  }


}
