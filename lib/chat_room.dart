import 'dart:async';
import 'package:campride/room.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

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

  // void onSendTap(
  //     String message, ReplyMessage replyMessage, MessageType messageType) {
  //   final message = Message(
  //     id: '3',
  //     message: "How are you",
  //     createdAt: DateTime.now(),
  //     sentBy: "2",
  //     replyMessage: replyMessage,
  //     messageType: messageType,
  //   );
  //   chatController.addMessage(message);
  // }
  //
  // final chatController = ChatController(
  //   initialMessageList: [
  //     Message(
  //       id: '1',
  //       message: "Hi",
  //       createdAt: DateTime.now(),
  //       sentBy: '1',
  //     ),
  //     Message(
  //       id: '2',
  //       message: "Hello",
  //       createdAt: DateTime.now(),
  //       sentBy: '2',
  //     ),
  //   ],
  //   scrollController: ScrollController(),
  //   currentUser: ChatUser(id: '1', name: '준행행님'),
  //   otherUsers: [ChatUser(id: '2', name: '리치준형')],
  // );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final now = new DateTime.now();

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
        appBar: ChatViewAppBar(
          chatTitle: "Chat view",
          chatTitleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.25,
          ),
          userStatus: "online",
          userStatusTextStyle: const TextStyle(color: Colors.grey),
          actions: [
            IconButton(
              onPressed: _onThemeIconTap,
              icon: Icon(
                isDarkTheme
                    ? Icons.brightness_4_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
            IconButton(
              tooltip: 'Toggle TypingIndicator',
              onPressed: _showHideTypingIndicator,
              icon: Icon(
                Icons.keyboard,
              ),
            ),
            IconButton(
              tooltip: 'Simulate Message receive',
              onPressed: receiveMessage,
              icon: Icon(
                Icons.supervised_user_circle,
              ),
            ),
          ],
        ),
        chatBackgroundConfig: ChatBackgroundConfiguration(
          backgroundColor: Colors.white10,
          messageTimeIconColor: Color(0xffF0F0F3),
          defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
            textStyle: TextStyle(
              color: Colors.grey,
              fontSize: 17,
            ),
          ),
        ),
        sendMessageConfig: SendMessageConfiguration(
          allowRecordingVoice: false, // 녹음(음성메시지) 제거
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
    // body: ChatView(
    //   messageConfig: MessageConfiguration(
    //     messageReactionConfig: MessageReactionConfiguration(
    //       reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
    //         reactedUserCallback: (reactedUser, reaction) {
    //           debugPrint(reaction);
    //         },
    //       ),
    //     ),
    //   ),
    //   chatBackgroundConfig: ChatBackgroundConfiguration(
    //     defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
    //         chatSeparatorDatePattern: 'MMM dd, yyyy'),
    //   ),
    //   featureActiveConfig: FeatureActiveConfig(
    //     enableSwipeToReply: true,
    //   ),
    //   chatController: chatController,
    //   onSendTap: onSendTap,
    //   chatViewState:
    //       ChatViewState.hasMessages, // Add this state once data is available.
    // ),
    //   floatingActionButton: null,
    // );
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
