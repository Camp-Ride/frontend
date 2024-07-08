import 'dart:convert';
import 'dart:io';

import 'package:campride/room.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:chatview/chatview.dart';

class ChatRoomPage extends StatefulWidget {
  final Room room;

  const ChatRoomPage({Key? key, required this.room}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  bool isDarkTheme = false;
  final _chatController = ChatController(
    initialMessageList: [],
    scrollController: ScrollController(),
    currentUser: ChatUser(
      id: '1',
      name: 'Flutter',
    ),
    otherUsers: [
      ChatUser(
        id: '2',
        name: 'Simform',
      ),
      ChatUser(
        id: '3',
        name: 'Jhon',
      ),
      ChatUser(
        id: '4',
        name: 'Mike',
      ),
      ChatUser(
        id: '5',
        name: 'Rich',
      ),
    ],
  );

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  void receiveMessage() async {
    _chatController.addMessage(
      Message(
        id: DateTime.now().toString(),
        message: 'I will schedule the meeting.',
        createdAt: DateTime.now(),
        sentBy: '2',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // receiveMessage();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.room.title,
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: new Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF355A50), Color(0xFF154135)],
            ),
          ),
        ),
      ),
      body: ChatView(
        chatController: _chatController,
        onSendTap: _onSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          lastSeenAgoBuilderVisibility: true,
          receiptsBuilderVisibility: true,
          enableChatSeparator: true,
          enableSwipeToSeeTime: true,
          enableOtherUserName: true,
        ),
        chatViewState: ChatViewState.hasMessages,
        chatViewStateConfig: ChatViewStateConfiguration(
          loadingWidgetConfig: ChatViewStateWidgetConfiguration(),
          onReloadButtonTap: () {},
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          backgroundColor: Colors.white10,
          messageTimeIconColor: Color(0xffF0F0F3),
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            chatSeparatorDatePattern: 'MMM dd, yyyy HH:mm',
            textStyle: TextStyle(
              color: Colors.grey,
              fontSize: 17,
            ),
          ),
        ),
        sendMessageConfig: SendMessageConfiguration(
          allowRecordingVoice: false,
          textFieldConfig: TextFieldConfiguration(
            textStyle: TextStyle(color: Colors.black54),
            onMessageTyping: (status) {
              /// Do with status
              debugPrint(status.toString());
            },
            compositionThresholdTime: const Duration(seconds: 1),
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          outgoingChatBubbleConfig: ChatBubble(
            // 내가 보낸 채팅
            textStyle: TextStyle(color: Colors.white),
            linkPreviewConfig: const LinkPreviewConfiguration(
              backgroundColor: Color(0xff272336),
              bodyStyle: TextStyle(color: Colors.white),
              titleStyle: TextStyle(color: Colors.white),
            ),
            color: Colors.blueAccent,
          ),
          inComingChatBubbleConfig: ChatBubble(
              // 상대방 채팅
              linkPreviewConfig: const LinkPreviewConfiguration(
                backgroundColor: Color(0xff9f85ff),
                bodyStyle: TextStyle(color: Colors.black),
                titleStyle: TextStyle(color: Colors.black),
              ),
              textStyle: TextStyle(color: Colors.black),
              senderNameTextStyle: const TextStyle(color: Colors.black),
              color: Colors.white),
        ),
        replyPopupConfig: ReplyPopupConfiguration(),
        reactionPopupConfig: ReactionPopupConfiguration(
          shadow: BoxShadow(
            color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
            blurRadius: 20,
          ),
        ),
        messageConfig: MessageConfiguration(
          imageMessageConfig: ImageMessageConfiguration(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            shareIconConfig: ShareIconConfiguration(),
          ),
        ),
        repliedMessageConfig: RepliedMessageConfiguration(
          repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
            enableHighlightRepliedMsg: true,
            highlightColor: Colors.pinkAccent.shade100,
            highlightScale: 1.1,
          ),
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    _chatController.addMessage(
      Message(
        id: DateTime.now().toString(),
        createdAt: DateTime.now(),
        message: message,
        sentBy: _chatController.currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        // theme = LightTheme();
        isDarkTheme = false;
      } else {
        // theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}
