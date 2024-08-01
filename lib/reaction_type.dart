import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReactionType {
  final String name;
  final IconData icon;
  final Color color;

  const ReactionType({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const like = ReactionType(
    name: 'like',
    icon: Icons.favorite,
    color: Colors.red,
  );

  static const hate = ReactionType(
    name: 'hate',
    icon: Icons.close,
    color: Colors.black,
  );

  static const check = ReactionType(
    name: 'check',
    icon: Icons.check,
    color: Colors.green,
  );

  static const List<ReactionType> values = [like, hate, check];

  static ReactionType fromName(String name) {
    return values.firstWhere((type) => type.name == name);
  }
}