import 'package:campride/reaction.dart';
import 'package:campride/reaction_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'message.dart';
import 'message_type.dart';

List<Message> messageDatas = [
  Message(
      id: 'id001',
      text: '',
      imageUrl: 'https://i.ibb.co/JCyT1kT/Asset-1.png',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isSender: true,
      messageType: MessageType.image,
      reactions: [],
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id002',
      text: 'bubble special three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isSender: true,
      messageType: MessageType.text,
      reactions: [],
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id003',
      text: 'bubble special three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isSender: false,
      messageType: MessageType.text,
      reactions: [],
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id004',
      text: '',
      imageUrl:
          'https://campride.s3.ap-northeast-2.amazonaws.com/images/040bc953569bfe134984ed5f101ed2db5b61587d6ad6fdb045c4cbd73f6c0a29.png',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isSender: false,
      messageType: MessageType.image,
      reactions: [],
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id005',
      text: '',
      imageUrl:
          'https://campride.s3.ap-northeast-2.amazonaws.com/images/021ec2bee243290f27282f13f8f627d64765de8f1dc3476ff1000b400f342d53.png',
      timestamp: DateTime.now(),
      isSender: true,
      messageType: MessageType.image,
      reactions: [],
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id006',
      text: 'bubble special three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isSender: false,
      messageType: MessageType.text,
      reactions: [],
      isReply: true,
      replyingMessage: "this is replying message original"),
  Message(
      id: 'id007',
      text:
          'bubble special three without tailspecial three without tailspecial three without tailspecial three without tailspecial three without tailspecial three without tailspecial three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isSender: true,
      messageType: MessageType.text,
      reactions: [],
      isReply: true,
      replyingMessage: "this is replying message original"),
  Message(
    id: 'id007',
    text:
        'bubble special three without tailspecial three without tailspecial three without tailspecial three without tailspecial three without tailspecial three without tailspecial three without tail',
    imageUrl: '',
    timestamp: DateTime.now().subtract(Duration(days: 1)),
    isSender: true,
    messageType: MessageType.text,
    reactions: [],
    isReply: true,
    replyingMessage:
        'https://campride.s3.ap-northeast-2.amazonaws.com/images/021ec2bee243290f27282f13f8f627d64765de8f1dc3476ff1000b400f342d53.png',
  ),
  Message(
    id: 'id008',
    text:
    'bubble special three without tailspecial three without tailspecial three without',
    imageUrl: '',
    timestamp: DateTime.now().subtract(Duration(days: 1)),
    isSender: false,
    messageType: MessageType.text,
    reactions: [],
    isReply: true,
    replyingMessage:
    'https://campride.s3.ap-northeast-2.amazonaws.com/images/021ec2bee243290f27282f13f8f627d64765de8f1dc3476ff1000b400f342d53.png',
  ),
];

// StateNotifier to manage the state of the message list
class MessagesNotifier extends StateNotifier<List<Message>> {
  MessagesNotifier(List<Message> initialMessages) : super(initialMessages);

  // Add a new message to the list
  void addMessage(Message message) {
    state = [...state, message];
  }

  // Update a message in the list
  void updateMessage(Message updatedMessage) {
    state = [
      for (final message in state)
        if (message.id == updatedMessage.id) updatedMessage else
          message,
    ];
  }

  // Remove a message from the list
  void removeMessage(String id) {
    state = state.where((message) => message.id != id).toList();
  }

  void reactToMessage(int index, ReactionType reactionType, String userId) {
    // 기존 상태에서 reactions 리스트를 복사하여 업데이트할 새로운 리스트를 생성합니다.
    final updatedReactions = List<Reaction>.from(state[index].reactions);

    // 동일한 userId로 기존 reactionType이 존재하는 경우 제거합니다.
    updatedReactions.removeWhere((reaction) => reaction.userId == userId);

    // 새로운 반응을 추가합니다.
    if (updatedReactions.any((reaction) =>
    reaction.reactionType == reactionType && reaction.userId == userId)) {
      // 이미 동일한 반응이 있는 경우 제거
      updatedReactions.removeWhere((reaction) =>
      reaction.reactionType == reactionType && reaction.userId == userId);
    } else {
      // 새로운 반응 추가
      updatedReactions.add(
          Reaction(userId: userId, reactionType: reactionType));
    }

    // 복사된 메시지 객체에 업데이트된 reactions를 설정합니다.
    final updatedMessage = state[index].copyWith(reactions: updatedReactions);

    // 업데이트된 메시지를 상태에 반영합니다.
    updateMessage(updatedMessage);
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
