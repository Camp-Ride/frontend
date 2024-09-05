import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/Constants.dart';
import 'package:campride/participants.dart';
import 'package:campride/reaction_type.dart';
import 'package:campride/reply_provider.dart';
import 'package:campride/messages_provider.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'auth_dio.dart';
import 'env_config.dart';
import 'message.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';

import 'Image_provider.dart';
import 'message_type.dart';

String formatDateTime(List<int> dateTimeParts) {
  return "${dateTimeParts[0]}-${dateTimeParts[1].toString().padLeft(2, '0')}-${dateTimeParts[2].toString().padLeft(2, '0')} "
      "${dateTimeParts[3].toString().padLeft(2, '0')}:${dateTimeParts[4].toString().padLeft(2, '0')}";
}

class ChatRoomPage extends ConsumerStatefulWidget {
  final Room initialRoom;

  const ChatRoomPage({super.key, required this.initialRoom});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatRoomPageState(initialRoom);
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;
  int startOffset = 0;
  double currentScrollPosition = 0.0;
  String userName = "";
  String userId = "";
  late Room room;

  int selectedIndex = 0;

  Set<Marker> markers = {};
  late KakaoMapController kakaoMapController;

  ScrollController scrollController = ScrollController();
  StompClient? _stompClient;

  _ChatRoomPageState(Room initialRoom) {
    room = initialRoom;
  }

  void _connectStomp() {
    print("Connecting to STOMP server");
    _stompClient = StompClient(
      config: StompConfig(
        url: Constants.WS,
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
      destination: '/topic/messages/room/${room.id}',
      callback: (frame) async {
        print('Received message: ${frame.body}');

        if (mounted) {
          Map<String, dynamic> jsonMap = jsonDecode(frame.body!);
          Message message = Message.fromJson(jsonMap);

          if ((message.chatMessageType == ChatMessageType.LEAVE ||
                  message.chatMessageType == ChatMessageType.KICK) &&
              userId != message.text) {
            print("leaved user: " + message.text);

            var response = await fetchRoom(room.id);
            if (response != null) {
              room = response;
            }
            Navigator.pop(context);
          }

          if ((message.chatMessageType == ChatMessageType.LEAVE ||
                  message.chatMessageType == ChatMessageType.KICK) &&
              userId == message.text) {
            print("leaved user: " + message.text);
            Navigator.pop(context);
          }

          if (message.id == null) {
            ref.read(messagesProvider.notifier).updateMessage(message);
          } else {
            if (userId != message.userId ||
                message.chatMessageType == ChatMessageType.JOIN) {
              ref.read(messagesProvider.notifier).addMessage(message);
              return;
            }

            if (userId == message.userId) {
              ref.read(messagesProvider.notifier).updateMessageId(message);
              return;
            }
          }
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) async {
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
        const SizedBox(width: 3),
        Text(
          reactionCount.toString(),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(width: 3),
      ],
    );
  }

  void initializeUserInfo() async {
    userName = (await SecureStroageService.readNickname())!;
    userId = (await SecureStroageService.readUserId())!;
  }

  @override
  void initState() {
    super.initState();
    room = widget.initialRoom;
    initializeUserInfo();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        startOffset++;

        ref
            .read(messagesProvider.notifier)
            .getMessages(room.id, startOffset, 5, context);
      }
    });
    _connectStomp();
    updateLastMessage(room.id);
    ref.read(messagesProvider.notifier).initMessages(room.id, context);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _stompClient?.deactivate();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var messages = ref.watch(messagesProvider);
    var isReplying = ref.watch(replyingProvider);
    var replyingMessage = ref.watch(replyingMessageProvider);

    void onReply(var index, Message message) {
      ref.read(replyingProvider.notifier).startReplying();
      ref.read(replyingMessageProvider.notifier).startReplying(message.text);
    }

    void stopReply() {
      ref.read(replyingProvider.notifier).stopReplying();
      ref.read(replyingMessageProvider.notifier).stopReplying();
    }

    void onReact(var index, Message message, ChatReactionType reaction,
        String userId) async {
      final notifier = ref.read(messagesProvider.notifier);

      Message message = await notifier.reactToMessage(index, reaction, userId);

      _stompClient?.send(
        destination: '/app/send/reaction',
        body: message.toString(),
      );
    }

    void addMessage(String text, bool isReplying, String replyingMessage,
        String imageUrl, ChatMessageType messageType) async {
      Message message = Message(
          id: null,
          roomId: room.id.toInt(),
          userId: userId,
          userNickname: userName,
          text: text,
          timestamp: now,
          chatMessageType: messageType,
          reactions: [],
          isReply: isReplying,
          replyingMessage: replyingMessage,
          imageUrl: imageUrl);
      ref.read(messagesProvider.notifier).addMessage(message);
      _stompClient?.send(
        destination: '/app/send',
        body: message.toString(),
      );

      if (isReplying) {
        stopReply();
      }
    }

    void sendLeaveUser(int leavedUserId, String leavedUserNickname,
        ChatMessageType messageType) async {
      Message message = Message(
          id: null,
          roomId: room.id.toInt(),
          userId: userId,
          userNickname: leavedUserNickname,
          text: leavedUserId.toString(),
          timestamp: now,
          chatMessageType: messageType,
          reactions: [],
          isReply: false,
          replyingMessage: "",
          imageUrl: "");
      ref.read(messagesProvider.notifier).addMessage(message);
      _stompClient?.send(
        destination: '/app/send/leave',
        body: message.toString(),
      );
    }

    void sendKickUser(int leavedUserId, String leavedUserNickname,
        ChatMessageType messageType) async {
      Message message = Message(
          id: null,
          roomId: room.id.toInt(),
          userId: userId,
          userNickname: leavedUserNickname,
          text: leavedUserId.toString(),
          timestamp: now,
          chatMessageType: messageType,
          reactions: [],
          isReply: false,
          replyingMessage: "",
          imageUrl: "");
      ref.read(messagesProvider.notifier).addMessage(message);
      _stompClient?.send(
        destination: '/app/send/kick',
        body: message.toString(),
      );
    }

    Future<void> exitRoom(int roomId) async {
      final response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("정말 나가시겠습니까?"),
            content: room.name == userName
                ? Text(
                    "방장이 방을 나가게 되면 자동으로 현재 방은 삭제됩니다.",
                    style: TextStyle(fontSize: 10.sp),
                  )
                : null,
            actions: <Widget>[
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.of(context).pop(true); // Yes 선택 시 true 반환
                },
              ),
              TextButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop(false); // No 선택 시 false 반환
                },
              ),
            ],
          );
        },
      );

      if (response == true) {
        sendLeaveUser(int.parse(userId), userName, ChatMessageType.LEAVE);
        Navigator.pop(context);
      }
    }

    Future<void> kickUser(int roomId, String leaderName,
        Participant participant, String currentName) async {
      if (currentName != leaderName) {
        final response = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "방장만 유저를 내보낼 수 있습니다.",
                style: TextStyle(fontSize: 15.sp),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Yes 선택 시 true 반환
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      if (leaderName == participant.nickname) {
        final response = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "본인은 내보낼 수 없습니다.",
                style: TextStyle(fontSize: 15.sp),
              ),
              content: Text("방 삭제를 원하면 하단의 방 나가기를 선택해 주세요.",
                  style: TextStyle(fontSize: 12.sp)),
              actions: <Widget>[
                TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Yes 선택 시 true 반환
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      final response = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "정말 ${participant.nickname}님을 내보내시겠습니까?",
              style: TextStyle(fontSize: 15.sp),
            ),
            content: Text("한번 퇴장당한 유저는 다시 참여할 수 없습니다.",
                style: TextStyle(fontSize: 12.sp)),
            actions: <Widget>[
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.of(context).pop(true); // Yes 선택 시 true 반환
                },
              ),
              TextButton(
                child: Text("취소"),
                onPressed: () {
                  Navigator.of(context).pop(false); // No 선택 시 false 반환
                },
              ),
            ],
          );
        },
      );

      if (response == true) {
        sendKickUser(
            participant.id, participant.nickname, ChatMessageType.KICK);
      }
    }

    void sendImage() async {
      await ref.read(imageProvider.notifier).pickImageFromGallery();
      File? image = await ref.read(imageProvider);
      print(image);

      var dio = await authDio(context);

      final response = await dio.post(
        '/images',
        data: FormData.fromMap({
          'images': await MultipartFile.fromFile(image!.path),
        }),
      );

      final Map<String, dynamic> decodedJson = response.data;

      final imageUrl = await decodedJson['imageNames'][0];
      print(imageUrl);

      addMessage("사진", false, "", imageUrl, ChatMessageType.IMAGE);
    }

    void sendImageWithCamera() async {
      await ref.read(imageProvider.notifier).captureImageWithCamera();
      File? image = await ref.read(imageProvider);
      print(image);

      var dio = await authDio(context);

      final response = await dio.post(
        '/images',
        data: FormData.fromMap({
          'images': await MultipartFile.fromFile(image!.path),
        }),
      );

      final Map<String, dynamic> decodedJson = response.data;

      final imageUrl = await decodedJson['imageNames'][0];
      print(imageUrl);

      addMessage("사진", false, "", imageUrl, ChatMessageType.IMAGE);
    }

    void showPopupMenu(
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
              leading: const Icon(Icons.reply),
              title: const Text('답장'),
              onTap: () {
                Navigator.pop(context);

                onReply(index, message);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('좋아요'),
              onTap: () {
                Navigator.pop(context);
                onReact(index, message, ChatReactionType.like, userId);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.check),
              title: const Text('확인'),
              onTap: () {
                Navigator.pop(context);
                onReact(index, message, ChatReactionType.check, userId);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.close),
              title: const Text('싫어요'),
              onTap: () {
                Navigator.pop(context);
                onReact(index, message, ChatReactionType.hate, userId);
              },
            ),
          ),
        ],
      );
    }

    Widget buildMessageWidget(Message message) {
      final time = DateFormat('h:mm a').format(message.timestamp);
      final alignment = userId == message.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start;
      final textColor = userId == message.userId ? Colors.white : Colors.black;

      Widget buildReplyWidget(String replyingMessage) {
        return !replyingMessage.endsWith(".png")
            ? Column(
                crossAxisAlignment: userId == message.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BubbleSpecialThree(
                          text: replyingMessage,
                          color: userId == message.userId
                              ? Colors.lightBlueAccent
                              : Colors.black12,
                          tail: false,
                          textStyle: TextStyle(color: textColor, fontSize: 16),
                          isSender: userId == message.userId ? true : false,
                        ),

                        // if (replyingMessage.imageUrl.isNotEmpty)
                        //   Image.network(replyingMessage.imageUrl, height: 50, fit: BoxFit.cover),
                      ],
                    ),
                  ),
                  userId == message.userId
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20.0).w,
                          child: Transform.flip(
                              flipY: true,
                              child: const Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 20.0).w,
                          child: Transform.rotate(
                              angle: 3.14,
                              child: const Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                ],
              )
            : Column(
                crossAxisAlignment: userId == message.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    child: BubbleNormalImage(
                      id: message.userId,
                      image: _image(replyingMessage),
                      color: Colors.white,
                      tail: true,
                      isSender: userId == message.userId ? true : false,
                    ),
                  ),
                  userId == message.userId
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20.0).w,
                          child: Transform.flip(
                              flipY: true,
                              child: const Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 20.0).w,
                          child: Transform.rotate(
                              angle: 3.14,
                              child: const Icon(
                                Icons.reply,
                                color: Colors.black54,
                              )),
                        )
                ],
              );
      }

      final reactionsWidget = userId == message.userId
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

      final reactionAndTime = userId == message.userId
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
            crossAxisAlignment: userId == message.userId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isReply) buildReplyWidget(message.replyingMessage),
              BubbleSpecialThree(
                text: message.text,
                color: userId == message.userId
                    ? const Color(0xFF1B97F3)
                    : const Color(0xFFE8E8EE),
                tail: false,
                textStyle: TextStyle(color: textColor, fontSize: 16),
                isSender: userId == message.userId ? true : false,
                sent: message.id != null && message.userId == userId
                    ? true
                    : false,
              ),
              userId == message.userId
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
            crossAxisAlignment: userId == message.userId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isReply) buildReplyWidget(message.replyingMessage),
              BubbleNormalImage(
                id: message.userId,
                image: _image(message.imageUrl),
                color: Colors.white,
                tail: true,
                isSender: userId == message.userId ? true : false,
                sent: message.id != null && message.userId == userId
                    ? true
                    : false,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26.0, right: 26.0).w,
                child: reactionAndTime,
              ),
            ],
          );

        case ChatMessageType.LEAVE:
          return Padding(
              padding: EdgeInsets.only(top: 5).h,
              child: Center(
                  child: Text(
                "${message.userNickname}님이 채팅방을 떠나셨습니다.",
                style: TextStyle(color: Colors.black54),
              )));
        case ChatMessageType.JOIN:
          return Padding(
              padding: EdgeInsets.only(top: 5).h,
              child: Center(
                  child: Text(
                "${message.userNickname}님이 채팅방에 입장하였습니다.",
                style: TextStyle(color: Colors.black54),
              )));

        case ChatMessageType.KICK:
          return Padding(
              padding: EdgeInsets.only(top: 5).h,
              child: Center(
                  child: Text(
                "${message.userNickname}님이 채팅방에서 강제 퇴장당하였습니다.",
                style: TextStyle(color: Colors.black54),
              )));
        default:
          return Container();
      }
    }

    Widget buildMessageList(List<Message> messages) {
      List<Widget> messageWidgets = [];
      DateTime? lastDate;

      for (var i = 0; i < messages.length; i++) {
        if (lastDate == null || !isSameDay(lastDate, messages[i].timestamp)) {
          messageWidgets.add(DateChip(date: messages[i].timestamp));
          lastDate = messages[i].timestamp;
        }

        messageWidgets.add(
          GestureDetector(
            onLongPressStart: (details) {
              showPopupMenu(context, messages[i], i, details.globalPosition);
            },
            child: buildMessageWidget(messages[i]),
          ),
        );
      }

      return ListView.builder(
        controller: scrollController,
        itemCount: messageWidgets.length,
        itemBuilder: (context, index) {
          return messageWidgets[index];
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(
          room.title,
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF355A50), Color(0xFF154135)],
            ),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () async {
                room = (await fetchRoom(room.id))!;
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: buildMessageList(messages)),
          MessageBar(
            messageBarHintText: "메시지를 입력하세요",
            messageBarHintStyle: const TextStyle(color: Colors.black54),
            replying: isReplying,
            replyingTo: replyingMessage,
            onTapCloseReply: stopReply,
            onSend: (String text) => addMessage(
                text, isReplying, replyingMessage, "", ChatMessageType.TEXT),
            actions: [
              InkWell(
                child: const Icon(
                  Icons.image,
                  color: Colors.lightBlueAccent,
                  size: 24,
                ),
                onTap: () {
                  sendImage();
                },
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: InkWell(
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.green,
                      size: 24,
                    ),
                    onTap: () {
                      sendImageWithCamera();
                    },
                  )),
            ],
          ),
        ],
      ),
      endDrawer: SafeArea(
        child: Drawer(
          child: Column(
            children: [
              Container(
                height: 50.h,
                alignment: Alignment.center,
                color: const Color(0xFF355A50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Drawer 닫기
                      },
                    ),
                    Text(
                      selectedIndex == 1 ? "참가자" : "방정보",
                      style: TextStyle(color: Colors.white),
                    ),

                    SizedBox(width: 48.w) // 왼쪽에 공간을 추가하여 "참가자"를 가운데로 정렬
                  ],
                ),
              ),
              selectedIndex == 1
                  ? Expanded(
                      child: ListView(
                      children: [
                        for (var participant in room.currentParticipants)
                          Column(children: [
                            ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(participant.nickname),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        room.name == participant.nickname
                                            ? const Icon(
                                                Icons.star,
                                                color: Colors.orangeAccent,
                                                size: 15,
                                              )
                                            : const SizedBox.shrink(),
                                        participant.id.toString() == userId
                                            ? const Icon(
                                                Icons.circle,
                                                color: Colors.blue,
                                                size: 10,
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        kickUser(room.id, room.name,
                                            participant, userName);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ]),
                            ),
                            const Divider(color: Colors.black12),
                          ]),
                      ],
                    ))
                  : Expanded(
                      child: Container(
                      margin: EdgeInsets.all(10).r,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  room.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Text 사이에 여유 공간을 추가할 수도 있습니다.
                              Text(
                                room.createdAt,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0).h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  overflow: TextOverflow.ellipsis,
                                  room.name,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: Colors.black54),
                                ),
                                SizedBox(
                                  width: 50.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "${room.currentParticipants.length}/${room.maxParticipants}"),
                                    ],
                                  ),
                                ),
                                room.rideType == "편도"
                                    ? Container(
                                        width: 50.w,
                                        // 컨테이너 크기
                                        height: 20.h,
                                        // 컨테이너 높이
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xff48ADE5),
                                                Color(0xff76CB68)
                                              ]),
                                          // 컨테이너 색상
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "편도",
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : Container(
                                        width: 50.w,
                                        // 컨테이너 크기
                                        height: 20.h,
                                        // 컨테이너 높이
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xffDCCB37),
                                                Color(0xff44EB29)
                                              ]),
                                          // 컨테이너 색상
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "왕복",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0).h,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black12,
                                ),
                                child: KakaoMap(
                                  onMapCreated: ((controller) async {
                                    kakaoMapController = controller;

                                    final departureLocation = LatLng(
                                        room.departureLocation[0] as double,
                                        room.departureLocation[1] as double);
                                    final destinationLocation = LatLng(
                                        room.arrivalLocation[0] as double,
                                        room.arrivalLocation[1] as double);

                                    // 출발지 마커 추가
                                    markers.add(Marker(
                                      markerId: UniqueKey().toString(),
                                      latLng: departureLocation,
                                    ));

                                    markers.add(Marker(
                                        markerId: UniqueKey().toString(),
                                        latLng: destinationLocation));

                                    kakaoMapController.panTo(departureLocation);
                                    kakaoMapController.addMarker(
                                        markers: markers.toList());

                                    setState(() {});
                                  }),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40.h,
                                  ),
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    "${room.date} 출발, " +
                                        room.trainingDays.toString() +
                                        "일",
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 50.h,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: 13.33.w,
                                        height: 46.4.h,
                                        child: Image.asset(
                                          "assets/images/start_end.png",
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 215.w,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                overflow: TextOverflow.ellipsis,
                                                room.departure,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black54)),
                                            Text(
                                                overflow: TextOverflow.ellipsis,
                                                room.arrival,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black54)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              Container(
                height: 50.h,
                color: Color(0xFF355A50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedIndex = 0;
                                  });
                                },
                                child: Text(
                                  "방정보",
                                  style: TextStyle(color: Colors.white),
                                )),
                            Container(
                              height: 2,
                              width: 30,
                              color: selectedIndex == 0
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    selectedIndex = 1;
                                  });
                                },
                                child: Text(
                                  "참가자",
                                  style: TextStyle(color: Colors.white),
                                )),
                            Container(
                              height: 2,
                              width: 30,
                              color: selectedIndex == 1
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0).w,
                      child: InkWell(
                        child: Icon(Icons.exit_to_app, color: Colors.white),
                        onTap: () async {
                          await exitRoom(room.id);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _image(String url) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 20.0,
        minWidth: 20.0,
      ),
      child: CachedNetworkImage(
        imageUrl: ('${EnvConfig().s3Url}$url'),
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
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: getReactionIcon(entry.key, entry.value),
            );
    }).toList();
  }

  Future updateLastMessage(int roomId) async {
    var dio = await authDio(context);

    await dio.put('/room/$roomId/last-message').then((response) {
      print('Last message: ${response.data}');
    }).catchError((error) {
      print('Failed to load last message. Error: $error');
    });
  }

  Future<Room?> fetchRoom(int roomId) async {
    var dio = await authDio(context);

    try {
      final response = await dio.get('/room/$roomId');
      print('Room data: ${response.data}');
      return Room.fromJson(response.data);
    } catch (e) {
      print('Failed to load room. Error: $e');
    }
  }
}
