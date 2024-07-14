import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplyingState extends StateNotifier<bool> {
  ReplyingState() : super(false);

  void startReplying() {
    state = true;
  }

  void stopReplying() {
    state = false;
  }
}

// Provider to watch the replying state
final replyingProvider = StateNotifierProvider<ReplyingState, bool>((ref) {
  return ReplyingState();
});




class ReplyingMessageState  extends StateNotifier<String>{
  ReplyingMessageState() : super("");

  void startReplying(String message) {
    state = message;
  }

  void stopReplying() {
    state = "";
  }
}

final replyingMessageProvider = StateNotifierProvider<ReplyingMessageState, String>((ref) {
  return ReplyingMessageState();
});

