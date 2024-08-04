import 'package:campride/reaction_type.dart';

class Reaction {
  final String userId;
  final ChatReactionType reactionType;

  Reaction({
    required this.userId,
    required this.reactionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reactionType': reactionType,
    };
  }

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      userId: json['userId'],
      reactionType: json['reactionType'],
    );
  }
}
