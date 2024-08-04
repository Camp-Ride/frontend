import 'dart:convert';

import 'package:campride/reaction.dart';

import 'message_type.dart';

class Message {
  final int roomId;
  final String userId;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final bool isSender;
  final ChatMessageType chatMessageType;
  final List<Reaction> reactions;
  final bool isReply;
  final String replyingMessage;

  Message({
    required this.roomId,
    required this.userId,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.isSender,
    required this.chatMessageType,
    required this.reactions,
    required this.isReply,
    required this.replyingMessage,
  });

  Message copyWith({
    int? roomId,
    String? userId,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    bool? isSender,
    ChatMessageType? chatMessageType,
    List<Reaction>? reactions,
    bool? isReply,
    String? replyingMessage,
  }) {
    return Message(
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isSender: isSender ?? this.isSender,
      chatMessageType: chatMessageType ?? this.chatMessageType,
      reactions: reactions ?? this.reactions,
      isReply: isReply ?? this.isReply,
      replyingMessage: replyingMessage ?? this.replyingMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'userId': userId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isSender': isSender,
      'chatMessageType': chatMessageType.toString().split(".").last.toUpperCase(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'isReply': isReply,
      'replyingMessage': replyingMessage,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
