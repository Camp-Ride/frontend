import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/reaction_type.dart';
import 'package:campride/reply_provider.dart';
import 'package:campride/messages_provider.dart';
import 'package:campride/room.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'message.dart';

import 'package:image_picker/image_picker.dart';

import 'Image_provider.dart';
import 'message_type.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final Room room;

  ChatRoomPage({required this.room});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatRoomPageState(room);
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  String userName = "junTest";

  StompClient? _stompClient;
  final _channel =
      WebSocketChannel.connect(Uri.parse('ws://localhost:8080/ws'));

  _ChatRoomPageState(Room room);

  void _connectStomp() {
    print("Connecting to STOMP server");
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws',
        // STOMP WebSocket URL
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (error) => print('WebSocket error: $error'),
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
      ),
    );

    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame) {
    print('Connected to STOMP server');
    // Subscribe to a topic or queue
    _stompClient?.subscribe(
      destination: '/topic/messages/room/' + widget.room.id.toString(),
      callback: (frame) {
        print('Received message: ${frame.body}');

        Map<String, dynamic> jsonMap = jsonDecode(frame.body!);
        Message message = Message.fromJson(jsonMap);
        print("changed message :" + message.toString());

        if (message.id != null) {
          ref.read(messagesProvider.notifier).updateMessage(message);
        } else {
          if (userName != message.userId) {
            print("username not match" + message.toString());
            ref.read(messagesProvider.notifier).addMessage(message);
          }

          if (userName == message.userId) {
            print(ref.read(messagesProvider.notifier).updateMessageId(message));
            print("<- updated Message");
          }
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    print('Disconnected from STOMP server');
  }

  final ImagePicker _picker = ImagePicker();

  Row getReactionIcon(ChatReactionType reactionType, int reactionCount) {
    return Row(
      children: [
        Icon(
          reactionType.icon,
          color: reactionType.color,
          size: 15,
        ),
        SizedBox(width: 3),
        Text(
          reactionCount.toString(),
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        SizedBox(width: 3),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _connectStomp();
    ref.read(messagesProvider.notifier).initMessages(widget.room.id);
  }

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    var messages = ref.watch(messagesProvider);
    var isReplying = ref.watch(replyingProvider);
    var replyingMessage = ref.watch(replyingMessageProvider);
    final image = ref.watch(imageProvider);

    print("messages 123 : " + messages.toString());

    void _onReply(var index, Message message) {
      ref.read(replyingProvider.notifier).startReplying();
      ref.read(replyingMessageProvider.notifier).startReplying(message.text);
    }

    void stopReply() {
      ref.read(replyingProvider.notifier).stopReplying();
      ref.read(replyingMessageProvider.notifier).stopReplying();
    }

    void _onReact(var index, Message message, ChatReactionType reaction,
        String userName) async {
      final notifier = ref.read(messagesProvider.notifier);

      Message message =
          await notifier.reactToMessage(index, reaction, userName);

      print("reaction message :" + message.toString());

      _stompClient?.send(
        destination: '/app/send/reaction',
        body: message.toString(),
      );
    }

    void addMessage(String text, bool isReplying, String replyingMessage,
        ChatMessageType messageType) {
      Message message = new Message(
          id: null,
          roomId: widget.room.id.toInt(),
          userId: userName,
          text: text,
          timestamp: now,
          chatMessageType: messageType,
          reactions: [],
          isReply: isReplying,
          replyingMessage: replyingMessage,
          imageUrl: '');
      ref.read(messagesProvider.notifier).addMessage(message);

      print("addmessage: " + message.toString());

      _stompClient?.send(
        destination: '/app/send',
        body: message.toString(),
      );

      if (isReplying) {
        stopReply();
      }
    }

    void sendImage() async {
      await ref.read(imageProvider.notifier).pickImageFromGallery();
      addMessage("imagetest1", false, "", ChatMessageType.IMAGE);
    }

    void _showPopupMenu(
        BuildContext context, Message message, var index, Offset offset) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      showMenu(
        color: Colors.white70,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0).r),
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy,
          overlay.size.width - offset.dx,
          overlay.size.height - offset.dy,
        ),
        items: [
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.reply),
              title: Text('답장'),
              onTap: () {
                Navigator.pop(context);
                _onReply(index, message);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text('좋아요'),
              onTap: () {
                Navigator.pop(context);
                _onReact(index, message, ChatReactionType.like, userName);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('확인'),
              onTap: () {
                Navigator.pop(context);
                _onReact(index, message, ChatReactionType.check, userName);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.close),
              title: Text('싫어요'),
              onTap: () {
                Navigator.pop(context);
                _onReact(index, message, ChatReactionType.hate, userName);
              },
            ),
          ),
        ],
      );
    }

    Widget buildMessageWidget(Message message) {
      final time = DateFormat('h:mm a').format(message.timestamp);
      final alignment = userName == message.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start;
      final textColor =
          userName == message.userId ? Colors.white : Colors.black;

      Widget buildReplyWidget(String replyingMessage) {
        return !replyingMessage.endsWith(".png")
            ? Column(
                crossAxisAlignment: userName == message.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BubbleSpecialThree(
                          text: replyingMessage,
                          color: userName == message.userId
                              ? Colors.lightBlueAccent
                              : Colors.black12,
                          tail: false,
                          textStyle: TextStyle(color: textColor, fontSize: 16),
                          isSender: userName == message.userId ? true : false,
                        ),

                        // if (replyingMessage.imageUrl.isNotEmpty)
                        //   Image.network(replyingMessage.imageUrl, height: 50, fit: BoxFit.cover),
                      ],
                    ),
                  ),
                  userName == message.userId
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20.0).w,
                          child: Transform.flip(
                              flipY: true,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 20.0).w,
                          child: Transform.rotate(
                              angle: 3.14,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                ],
              )
            : Column(
                crossAxisAlignment: userName == message.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    child: BubbleNormalImage(
                      id: message.userId,
                      image: _image(replyingMessage),
                      color: Colors.white,
                      tail: true,
                      isSender: userName == message.userId ? true : false,
                    ),
                  ),
                  userName == message.userId
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20.0).w,
                          child: Transform.flip(
                              flipY: true,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 20.0).w,
                          child: Transform.rotate(
                              angle: 3.14,
                              child: Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                ],
              );
      }

      final reactionsWidget = userName == message.userId
          ? Padding(
              padding: const EdgeInsets.only(left: 8.0).w,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12.0).r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: buildReactions(message),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0).r,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: buildReactions(message),
              ),
            );

      final timeWidget = Text(
        time,
        style: TextStyle(color: Colors.black54, fontSize: 12.sp),
      );

      final reactionAndTime = userName == message.userId
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                timeWidget,
                SizedBox(height: 2.0.h),
                reactionsWidget,
                SizedBox(height: 8.0.h),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                timeWidget,
                SizedBox(height: 2.0.h),
                reactionsWidget,
                SizedBox(height: 8.0.h),
              ],
            );

      switch (message.chatMessageType) {
        case ChatMessageType.TEXT:
          return Column(
            crossAxisAlignment: userName == message.userId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isReply && message.replyingMessage != null)
                buildReplyWidget(message.replyingMessage!),
              BubbleSpecialThree(
                text: message.text,
                color: userName == message.userId
                    ? Color(0xFF1B97F3)
                    : Color(0xFFE8E8EE),
                tail: false,
                textStyle: TextStyle(color: textColor, fontSize: 16),
                isSender: userName == message.userId ? true : false,
                sent: message.id != null && message.userId == userName
                    ? true
                    : false,
              ),
              userName == message.userId
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20.0).r,
                      child: reactionAndTime,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(left: 20.0).r,
                      child: reactionAndTime,
                    ),
            ],
          );
        case ChatMessageType.IMAGE:
          return Column(
            crossAxisAlignment: userName == message.userId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isReply && message.replyingMessage != null)
                buildReplyWidget(message.replyingMessage!),
              BubbleNormalImage(
                id: message.userId,
                image: _image(message.imageUrl),
                color: Colors.white,
                tail: true,
                isSender: userName == message.userId ? true : false,
                sent: message.id != null && message.userId == userName
                    ? true
                    : false,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26.0, right: 26.0).w,
                child: reactionAndTime,
              ),
            ],
          );
        default:
          return Container();
      }
    }

    Widget buildMessageList(List<Message> messages) {
      List<Widget> messageWidgets = [];
      DateTime? lastDate;

      print(messages.toString());

      for (var i = 0; i < messages.length; i++) {
        if (lastDate == null || !isSameDay(lastDate, messages[i].timestamp)) {
          messageWidgets.add(DateChip(date: messages[i].timestamp));
          lastDate = messages[i].timestamp;
        }

        messageWidgets.add(
          GestureDetector(
            onLongPressStart: (details) {
              _showPopupMenu(context, messages[i], i, details.globalPosition);
            },
            child: buildMessageWidget(messages[i]),
          ),
        );
      }

      return ListView(
        children: messageWidgets,
      );
    }

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
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF355A50), Color(0xFF154135)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: buildMessageList(messages)),
          MessageBar(
            replying: isReplying,
            replyingTo: replyingMessage,
            onTapCloseReply: stopReply,
            onSend: (String text) => addMessage(
                text, isReplying, replyingMessage, ChatMessageType.TEXT),
            actions: [
              InkWell(
                child: Icon(
                  Icons.image,
                  color: Colors.lightBlueAccent,
                  size: 24,
                ),
                onTap: () {
                  sendImage();
                },
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: InkWell(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.lightGreen,
                    size: 24,
                  ),
                  onTap: () {
                    ref.read(imageProvider.notifier).captureImageWithCamera();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _image(String url) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 20.0,
        minWidth: 20.0,
      ),
      child: CachedNetworkImage(
        imageUrl: url,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  List<Container> buildReactions(Message message) {
    // 각 reactionType별로 그룹화합니다.
    final reactionGroups = <ChatReactionType, int>{};
    for (var reaction in message.reactions) {
      reactionGroups[reaction.reactionType] =
          (reactionGroups[reaction.reactionType] ?? 0) + 1;
    }

    // 각 그룹에 대해 아이콘을 생성합니다.
    return reactionGroups.entries.map((entry) {
      return entry.value == 0
          ? Container()
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              child: getReactionIcon(entry.key, entry.value),
            );
    }).toList();
  }
}
