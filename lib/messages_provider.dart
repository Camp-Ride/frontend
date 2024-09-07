import 'dart:convert';

import 'package:campride/reaction.dart';
import 'package:campride/reaction_type.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'auth_dio.dart';
import 'message.dart';

List<Message> messageDatas = [];

// StateNotifier to manage the state of the message list
class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier(super.initialMessages);

  // Add a new message to the list
  List<Message> addMessage(Message message) {
    return state = [...state, message];
  }

  // Update a message in the list
  Future<Message> updateMessage(Message updatedMessage) async {
    state = [
      for (final message in state)
        if (message.id == updatedMessage.id) updatedMessage else message,
    ];

    // print(updatedMessage);
    // print("7");
    // print(state);
    return updatedMessage;
  }

  List<Message> updateMessageId(Message updatedMessage) {
    bool updated = false;
    return state = [
      for (final message in state)
        if (!updated &&
            message.userId == updatedMessage.userId &&
            message.id == null)
          () {
            updated = true;
            return message.copyWith(id: updatedMessage.id);
          }()
        else
          message
    ];
  }

  // Remove a message from the list
  void removeMessage(String id) {
    state = state.where((message) => message.userId != id).toList();
  }

  Future<Message> reactToMessage(
      int index, ChatReactionType reactionType, String userId) {
    // 기존 상태에서 reactions 리스트를 복사하여 업데이트할 새로운 리스트를 생성합니다.
    final updatedReactions = state[index].reactions;

    // print("1");
    // 동일한 userId로 기존 reactionType이 존재하는 경우 제거합니다.

    // print("2");

    // print(updatedReactions);

    // 새로운 반응을 추가합니다.
    if (updatedReactions.any((reaction) =>
        reaction.reactionType.name == reactionType.name &&
        reaction.userId == userId)) {
      // 이미 동일한 반응이 있는 경우 제거
      print("3");
      updatedReactions.removeWhere((reaction) =>
          reaction.reactionType == reactionType && reaction.userId == userId);
    } else {
      // 새로운 반응 추가
      // print("4");
      updatedReactions.removeWhere((reaction) => reaction.userId == userId);
      updatedReactions
          .add(Reaction(userId: userId, reactionType: reactionType));
    }

    // print("5");
    // print("updatedReactions " + updatedReactions.toString());

    // 복사된 메시지 객체에 업데이트된 reactions를 설정합니다.
    final updatedMessage = state[index].copyWith(reactions: updatedReactions);
    // print("updatedMessage " + updatedMessage.toString());
    // print("6");

    // 업데이트된 메시지를 상태에 반영합니다.
    return updateMessage(updatedMessage);
  }

  Future<void> initMessages(int roomId, BuildContext context) async {
    var dio = await authDio(context);

    dio.get('/chat/messages/latest?roomId=$roomId').then((response) {
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        state = data.map((item) => Message.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    });
  }

  Future<dynamic> getMessages(
      int roomId, int startOffset, int count, BuildContext context) async {
    var dio = await authDio(context);

    print("getMessages");

    return dio
        .get(
            '/chat/messages?roomId=$roomId&startOffset=$startOffset&count=$count')
        .then((response) {
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        state = [...data.map((item) => Message.fromJson(item)), ...state];
        return response;
      } else {
        throw Exception('Failed to load messages');
      }
    });
  }
}

//   void reactToMessage(int index, String reaction, String userName) {
//     final updatedReactions =
//         Map<String, List<String>>.from(state[index].reactions);
//
//     for (var entry in updatedReactions.entries) {
//       entry.value.remove(userName);
//     }
//
//     final users = updatedReactions[reaction] ?? [];
//     if (users.contains(userName)) {
//       users.remove(userName);
//     } else {
//       users.add(userName);
//     }
//
//     updatedReactions[reaction] = users;
//     final updatedMessage = state[index].copyWith(reactions: updatedReactions);
//     updateMessage(updatedMessage);
//   }
// }

// Provider to watch the message list state
final messagesProvider =
    StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier(messageDatas);
});
