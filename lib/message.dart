import 'dart:convert';

import 'package:campride/reaction.dart';

import 'message_type.dart';

class Message {
  late  String? chatMessageId;
  final int roomId;
  final String userId;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final ChatMessageType chatMessageType;
  final List<Reaction> reactions;
  final bool isReply;
  final String replyingMessage;

  Message({
    required this.chatMessageId,
    required this.roomId,
    required this.userId,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.chatMessageType,
    required this.reactions,
    required this.isReply,
    required this.replyingMessage,
  });

  Message copyWith({
    String? chatMessageId,
    int? roomId,
    String? userId,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    ChatMessageType? chatMessageType,
    List<Reaction>? reactions,
    bool? isReply,
    String? replyingMessage,
  }) {
    return Message(
      chatMessageId: chatMessageId ?? this.chatMessageId,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      chatMessageType: chatMessageType ?? this.chatMessageType,
      reactions: reactions ?? this.reactions,
      isReply: isReply ?? this.isReply,
      replyingMessage: replyingMessage ?? this.replyingMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatMessageId': chatMessageId,
      'roomId': roomId,
      'userId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'chatMessageType':
          chatMessageType.toString().split(".").last.toUpperCase(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'isReply': isReply,
      'replyingMessage': replyingMessage,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    List<Reaction> reactions = (json['reactions'] as List<dynamic>)
        .map((reactionJson) => Reaction.fromJson(reactionJson))
        .toList();

    print("json['timestamp'] : " + json['timestamp'].toString());

    List<int> dateParts = List<int>.from(json['timestamp']);

    DateTime timestamp = DateTime(
      dateParts[0],
      dateParts[1],
      dateParts[2],
      dateParts[3],
      dateParts[4],
      dateParts[5],
    );
    print("timestamp : " + timestamp.toString());
    print("reactions : " + reactions.toString());

    return Message(
      chatMessageId: json['chatMessageId'],
      roomId: json['roomId'],
      userId: json['userId'],
      text: json['text'],
      imageUrl: json['imageUrl'],
      timestamp: timestamp,
      chatMessageType: ChatMessageType.values.firstWhere((e) =>
          e.toString().split(".").last.toUpperCase() ==
          json['chatMessageType']),
      // ChatMessageType enum 변환
      reactions: reactions,
      isReply: json['isReply'],
      replyingMessage: json['replyingMessage'],
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
