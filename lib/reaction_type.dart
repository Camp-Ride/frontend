import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatReactionType {
  final String name;
  final IconData icon;
  final Color color;

  const ChatReactionType({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const like = ChatReactionType(
    name: 'like',
    icon: Icons.favorite,
    color: Colors.red,
  );

  static const hate = ChatReactionType(
    name: 'hate',
    icon: Icons.close,
    color: Colors.black,
  );

  static const check = ChatReactionType(
    name: 'check',
    icon: Icons.check,
    color: Colors.green,
  );

  static const List<ChatReactionType> values = [like, hate, check];

  static ChatReactionType fromName(String name) {
    return values.firstWhere((type) => type.name == name);
  }
}