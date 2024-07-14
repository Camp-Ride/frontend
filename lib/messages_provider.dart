import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_room.dart';

List<Message> messageDatas = [
  Message(
      id: 'id001',
      text: '',
      imageUrl: 'https://i.ibb.co/JCyT1kT/Asset-1.png',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isSender: true,
      messageType: MessageType.image,
      reactions: {},
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id002',
      text: 'bubble special three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      isSender: true,
      messageType: MessageType.text,
      reactions: {},
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id003',
      text: 'bubble special three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isSender: false,
      messageType: MessageType.text,
      reactions: {},
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
      reactions: {},
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
      reactions: {},
      isReply: false,
      replyingMessage: ""),
  Message(
      id: 'id006',
      text: 'bubble special three without tail',
      imageUrl: '',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      isSender: false,
      messageType: MessageType.text,
      reactions: {},
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
      reactions: {},
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
    reactions: {},
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
    reactions: {},
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
        if (message.id == updatedMessage.id) updatedMessage else message,
    ];
  }

  // Remove a message from the list
  void removeMessage(String id) {
    state = state.where((message) => message.id != id).toList();
  }

  void reactToMessage(int index, String reaction, String userName) {
    final updatedReactions =
        Map<String, List<String>>.from(state[index].reactions);

    for (var entry in updatedReactions.entries) {
      entry.value.remove(userName);
    }

    final users = updatedReactions[reaction] ?? [];
    if (users.contains(userName)) {
      users.remove(userName);
    } else {
      users.add(userName);
    }

    updatedReactions[reaction] = users;
    final updatedMessage = state[index].copyWith(reactions: updatedReactions);
    updateMessage(updatedMessage);
  }
}

// Provider to watch the message list state
final messagesProvider =
    StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier(messageDatas);
});
