import 'package:campride/reaction.dart';

import 'message_type.dart';

class Message {
  final String id;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final bool isSender;
  final MessageType messageType;
  final List<Reaction> reactions;
  final bool isReply;
  final String replyingMessage;

  Message({
    required this.id,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.isSender,
    required this.messageType,
    required this.reactions,
    required this.isReply,
    required this.replyingMessage,
  });

  Message copyWith({
    String? id,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
    bool? isSender,
    MessageType? messageType,
    List<Reaction>? reactions,
    bool? isReply,
    String? replyingMessage,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isSender: isSender ?? this.isSender,
      messageType: messageType ?? this.messageType,
      reactions: reactions ?? this.reactions,
      isReply: isReply ?? this.isReply,
      replyingMessage: replyingMessage ?? this.replyingMessage,
    );
  }
}
