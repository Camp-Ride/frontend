import 'package:campride/reaction_type.dart';

class Reaction {
  final String userId;
  final ReactionType reactionType;

  Reaction({
    required this.userId,
    required this.reactionType,
  });
}