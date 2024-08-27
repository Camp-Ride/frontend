import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/reaction_type.dart';
import 'package:campride/reply_provider.dart';
import 'package:campride/messages_provider.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
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
  final Room room;

  const ChatRoomPage({super.key, required this.room});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatRoomPageState(room);
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

  int selectedIndex = 0;

  Set<Marker> markers = {};
  late KakaoMapController kakaoMapController;

  ScrollController scrollController = ScrollController();
  StompClient? _stompClient;

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
      destination: '/topic/messages/room/${widget.room.id}',
      callback: (frame) {
        // print('Received message: ${frame.body}');

        if (mounted) {
          Map<String, dynamic> jsonMap = jsonDecode(frame.body!);
          Message message = Message.fromJson(jsonMap);

          if (message.id == null) {
            ref.read(messagesProvider.notifier).updateMessage(message);
          } else {
            if (userName != message.userId) {
              // print("username not match" + message.toString());
              ref.read(messagesProvider.notifier).addMessage(message);
            }

            if (userName == message.userId) {
              ref.read(messagesProvider.notifier).updateMessageId(message);
              // print("<- updated Message");
            }
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
        const SizedBox(width: 3),
        Text(
          reactionCount.toString(),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(width: 3),
      ],
    );
  }

  void initializeUserName() async {
    userName = (await SecureStroageService.readNickname())!;
  }

  @override
  void initState() {
    super.initState();
    initializeUserName();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        startOffset++;

        ref
            .read(messagesProvider.notifier)
            .getMessages(widget.room.id, startOffset, 5);
      }
    });
    _connectStomp();
    updateLastMessage(widget.room.id);
    ref.read(messagesProvider.notifier).initMessages(widget.room.id);
  }

  @override
  void dispose() async {
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
        String userName) async {
      final notifier = ref.read(messagesProvider.notifier);

      Message message =
          await notifier.reactToMessage(index, reaction, userName);

      _stompClient?.send(
        destination: '/app/send/reaction',
        body: message.toString(),
      );
    }

    void addMessage(String text, bool isReplying, String replyingMessage,
        String imageUrl, ChatMessageType messageType) async {
      Message message = Message(
          id: null,
          roomId: widget.room.id.toInt(),
          userId: userName,
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

    void sendImage() async {
      await ref.read(imageProvider.notifier).pickImageFromGallery();
      File? image = await ref.read(imageProvider);
      print(image);

      String url = "http://localhost:8080/api/v1/images";
      String jwt = (await SecureStroageService.readAccessToken())!;

      String imageUrl = "";

      var headers = {
        'Authorization': 'Bearer $jwt',
      };
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files
          .add(await http.MultipartFile.fromPath('images', image!.path));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      final Map<String, dynamic> decodedJson =
          jsonDecode(await response.stream.bytesToString());
      imageUrl = await decodedJson['imageNames'][0];
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
                onReact(index, message, ChatReactionType.like, userName);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.check),
              title: const Text('확인'),
              onTap: () {
                Navigator.pop(context);
                onReact(index, message, ChatReactionType.check, userName);
              },
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.close),
              title: const Text('싫어요'),
              onTap: () {
                Navigator.pop(context);
                onReact(index, message, ChatReactionType.hate, userName);
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
              if (message.isReply) buildReplyWidget(message.replyingMessage),
              BubbleSpecialThree(
                text: message.text,
                color: userName == message.userId
                    ? const Color(0xFF1B97F3)
                    : const Color(0xFFE8E8EE),
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
              if (message.isReply) buildReplyWidget(message.replyingMessage),
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
            await updateLastMessage(widget.room.id);
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
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {
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
                    SizedBox(width: 48.w), // 왼쪽에 공간을 추가하여 "참가자"를 가운데로 정렬
                  ],
                ),
              ),
              selectedIndex == 1
                  ? Expanded(
                      child: ListView(
                      children: [
                        for (var participant in widget.room.currentParticipants)
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
                                        participant.nickname == widget.room.name
                                            ? const Icon(
                                                Icons.star,
                                                color: Colors.orangeAccent,
                                                size: 15,
                                              )
                                            : const SizedBox.shrink(),
                                        participant.nickname == userName
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
                                    const Icon(
                                      Icons.close,
                                      color: Colors.grey,
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
                                  widget.room.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Text 사이에 여유 공간을 추가할 수도 있습니다.
                              Text(
                                widget.room.createdAt,
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
                                  widget.room.name,
                                  style: TextStyle(
                                      fontSize: 12.sp, color: Colors.black54),
                                ),
                                SizedBox(
                                  width: 50.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "${widget.room.currentParticipants.length}/${widget.room.maxParticipants}"),
                                    ],
                                  ),
                                ),
                                widget.room.rideType == "편도"
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
                                        widget.room.departureLocation[0]
                                            as double,
                                        widget.room.departureLocation[1]
                                            as double);
                                    final destinationLocation = LatLng(
                                        widget.room.arrivalLocation[0]
                                            as double,
                                        widget.room.arrivalLocation[1]
                                            as double);

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
                                    "${widget.room.date} 출발, " +
                                        widget.room.trainingDays.toString() +
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
                                                widget.room.departure,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.black54)),
                                            Text(
                                                overflow: TextOverflow.ellipsis,
                                                widget.room.arrival,
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
                          // 방 나가기 버튼 눌렀을 때의 동작
                          await exitRoom(widget.room.id);
                          Navigator.of(context).pop(); // 예시로 Drawer 닫기
                          Navigator.pop(context);


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
    String jwt = (await SecureStroageService.readAccessToken())!;

    final url =
        Uri.parse('http://localhost:8080/api/v1/room/$roomId/last-message');

    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.put(url, headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        print('Last message: $data');
      } else {
        print(
            'Failed to load last message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> exitRoom(int roomId) async {
    final url = Uri.parse('http://localhost:8080/api/v1/room/$roomId/exit');
    final jwtToken = await SecureStroageService.readAccessToken();

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        print('Successfully exited the room.');
      } else {
        // 서버가 200이 아닌 응답을 반환한 경우
        print('Failed to exit the room. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // 네트워크 오류 또는 예외 처리
      print('Error: $e');
    }
  }
}
