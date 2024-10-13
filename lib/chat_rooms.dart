import 'dart:async';
import 'dart:convert';
import 'package:campride/Constants.dart';
import 'package:campride/chat_room.dart';
import 'package:campride/main.dart';
import 'package:campride/message_type.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:dio/dio.dart';

import 'auth_dio.dart';
import 'message.dart';
import 'messages_provider.dart';

const String minDateTimeString = "-999999999-01-01 00:00";

class ChatRoomsPage extends ConsumerStatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends ConsumerState<ChatRoomsPage> {
  late Future<List<Room>> futureRooms;
  late String userName;
  late String userId;

  @override
  void initState() {
    super.initState();
    initializeUserInfo();
    futureRooms = fetchRooms();
    subscribeStomps(futureRooms);
    print("initstate");
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    super.dispose();
  }

  void subscribeStomps(Future<List<Room>> futureRooms) async {
    List<Room> rooms = await futureRooms;
    for (var room in rooms) {
      _connectStomp(room.id);
    }
  }

  StompClient? _stompClient;

  void initializeUserInfo() async {
    userName = (await SecureStroageService.readNickname())!;
    userId = (await SecureStroageService.readUserId())!;
  }

  void _connectStomp(int roomId) {
    print("Connecting to STOMP server for room ID: $roomId");

    print(Constants.PROD_WS);

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: Constants.PROD_WS,
        stompConnectHeaders: {'userId': userId},
        webSocketConnectHeaders: {'userId': userId},
        onConnect: (StompFrame frame) => _onConnect(frame, roomId),
        onDisconnect: _onDisconnect,
        onWebSocketError: (error) => print('WebSocket error: $error'),
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
      ),
    );

    _stompClient?.activate();
  }

  void _onConnect(StompFrame frame, int roomId) {
    print('Connected to STOMP server for room ID: $roomId');

    // Subscribe to a topic or queue based on the room ID
    _stompClient?.subscribe(
      destination: '/topic/messages/room/$roomId',
      callback: (frame) {
        if (!mounted) return;
        Map<String, dynamic> jsonMap = jsonDecode(frame.body!);
        Message message = Message.fromJson(jsonMap);

        if(message.chatMessageType == ChatMessageType.LEAVE) {
          setState(() {
            futureRooms = fetchRooms();
          });
          return;
        }

        setState(() {
          futureRooms.then((rooms) => {
                for (var room in rooms)
                  {
                    if (room.id == roomId)
                      {
                        room.latestMessageSender = message.userId,
                        room.latestMessageNickname = message.userNickname,
                        room.latestMessageContent = message.text,
                        room.latestMessageCreatedAt =
                            message.timestamp.toString().substring(0, 16),
                        room.latestMessageType = message.chatMessageType,
                        room.unreadMessageCount++,
                        message.chatMessageType == ChatMessageType.LEAVE
                            ? room.currentParticipantsCount--
                            : room.currentParticipantsCount++,
                      }
                  }
              });
        });
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    print('Disconnected from STOMP server');
  }

  Future<List<Room>> fetchRooms() async {
    var dio = await authDio(context);

    return await dio.get('/room/joined').then((response) {
      if (response.statusCode == 200) {
        List<dynamic> content = response.data;
        print("joinedRoomdata : " + content.toString());

        return content.map((json) => Room.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rooms');
      }
    });
  }

  Future updateLastMessage(int roomId) async {
    var dio = await authDio(context);

    await dio.put('/room/$roomId/last-message').then((response) {
      print('Last message: ${response.data}');
    }).catchError((error) {
      print('Failed to load last message. Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "나의 채팅 목록",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF355A50), Color(0xFF154135)],
              ),
            ),
          ),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          color: Colors.white,
          child: FutureBuilder<List<Room>>(
            future: futureRooms,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator()); // 로딩 중일 때 표시
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // 에러 발생 시 표시
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('참여 중인 방이 없습니다.')); // 데이터가 없을 때 표시
              } else {
                List<Room> rooms = snapshot.data!; // 데이터가 존재할 때 처리

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => {
                        rooms[index].unreadMessageCount = 0,
                        navigatorKey.currentState
                            ?.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatRoomPage(initialRoom: rooms[index]),
                              ),
                            )
                            .then((value) async => {
                                  await updateLastMessage(rooms[index].id),
                                  setState(() {
                                    updateLastMessage(rooms[index].id);
                                    futureRooms = fetchRooms();
                                  })
                                }),
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: screenWidth,
                              height: 140.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0).r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rooms[index].name,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(
                                            child: Text(
                                          overflow: TextOverflow.ellipsis,
                                          (rooms[index]
                                                      .latestMessageCreatedAt ==
                                                  minDateTimeString
                                              ? ("최근 대화 없음")
                                              : ("최근 대화 ${rooms[index].latestMessageCreatedAt}")),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.black54,
                                          ),
                                        )),
                                        InkWell(
                                          onTap: () {
                                            deleteRoom(rooms[index].id,
                                                rooms[index].leaderId);
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: 14.r,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Text(
                                            overflow: TextOverflow.ellipsis,
                                            rooms[index].title,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.people),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "${rooms[index].currentParticipantsCount}/${rooms[index].maxParticipants}",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Text(
                                              overflow: TextOverflow.ellipsis,
                                              rooms[index]
                                                      .latestMessageSender
                                                      .isEmpty
                                                  ? "채팅방을 클릭해 대화를 시작해 보세요."
                                                  : createLatestChatMessage(
                                                      rooms[index]),
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 40.w,
                                            height: 25.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: rooms[index]
                                                          .unreadMessageCount ==
                                                      0
                                                  ? Colors.white
                                                  : Colors.redAccent,
                                            ),
                                            child: Center(
                                              child: Text(
                                                rooms[index]
                                                    .unreadMessageCount
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          rooms[index].rideType == "편도"
                                              ? Container(
                                                  width: 50.w,
                                                  height: 20.h,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xff48ADE5),
                                                        Color(0xff76CB68)
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Text(
                                                    "편도",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Container(
                                                  width: 50.w,
                                                  height: 20.h,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xffDCCB37),
                                                        Color(0xff44EB29)
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Text(
                                                    "왕복",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        floatingActionButton: null,
      ),
    );
  }

  void _showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message, style: TextStyle(fontSize: 15.sp)),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendLeaveUser(int leavedUserId, String leavedUserNickname,
      ChatMessageType messageType, int roomId) async {
    Room currentRoom = await futureRooms
        .then((rooms) => rooms.firstWhere((room) => room.id == roomId));
    final now = DateTime.now();

    Message message = Message(
        id: null,
        roomId: currentRoom.id,
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

  Future<void> deleteRoom(int roomId, int leaderId) async {
    final response = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("정말 방을 나가시겠습니까?", style: TextStyle(fontSize: 15.sp)),
          content:
              leaderId.toString() == userId ? Text("방장이 나가면 방이 삭제됩니다.") : null,
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
      sendLeaveUser(int.parse(userId), userName, ChatMessageType.LEAVE, roomId);
      setState(() {
        futureRooms = fetchRooms();
      });
    }
  }

  String createLatestChatMessage(Room room) {
    if (room.latestMessageType == ChatMessageType.LEAVE) {
      return "${room.latestMessageNickname}님이 채팅방을 떠났습니다.";
    }

    if (room.latestMessageType == ChatMessageType.JOIN) {
      return "${room.latestMessageNickname}님이 채팅방에 참가했습니다.";
    }
    if (room.latestMessageType == ChatMessageType.KICK) {
      return "${room.latestMessageNickname}님이 채팅방에서 강제 퇴장당하였습니다.";
    }

    return "${room.latestMessageNickname} : ${room.latestMessageContent}";
  }
}
