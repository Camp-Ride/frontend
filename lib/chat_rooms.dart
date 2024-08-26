import 'dart:async';
import 'dart:convert';
import 'package:campride/chat_room.dart';
import 'package:campride/login.dart';
import 'package:campride/main.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'message.dart';

const String minDateTimeString = "-999999999-01-01 00:00";

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  late Future<List<Room>> futureRooms;

  @override
  void initState() {
    super.initState();
    futureRooms = fetchRooms();
    subscribeStomps(futureRooms);
  }

  @override
  void dispose() {
    _stompClient?.deactivate();
    super.dispose();
  }

  void subscribeStomps(Future<List<Room>> futureRooms) async {
    List<Room> rooms = await futureRooms;
    rooms.forEach((room) {
      _connectStomp(room.id);
    });
  }

  StompClient? _stompClient;

  void _connectStomp(int roomId) {
    print("Connecting to STOMP server for room ID: $roomId");

    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws',
        // STOMP WebSocket URL
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
        Map<String, dynamic> jsonMap = jsonDecode(frame.body!);
        Message message = Message.fromJson(jsonMap);

        setState(() {
          futureRooms.then((rooms) => {
                rooms.forEach((room) {
                  if (room.id == roomId) {
                    room.latestMessageSender = message.userId;
                    room.latestMessageContent = message.text;
                    room.latestMessageCreatedAt = message.timestamp.toString();
                    room.unreadMessageCount++;
                  }
                })
              });
        });
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    print('Disconnected from STOMP server');
  }

  Future<List<Room>> fetchRooms() async {
    String jwt = (await SecureStroageService.readAccessToken())!;

    final url = Uri.parse('http://localhost:8080/api/v1/room/joined');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> content = json.decode(utf8.decode(response.bodyBytes));
      print(content);

      return content.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "나의 채팅 목록",
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
        body: Container(
          alignment: Alignment.topCenter,
          color: Colors.white,
          child: FutureBuilder<List<Room>>(
            future: futureRooms,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}')); // 에러 발생 시 표시
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                    child: Text('No rooms available')); // 데이터가 없을 때 표시
              } else {
                List<Room> rooms = snapshot.data!; // 데이터가 존재할 때 처리

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => {
                        navigatorKey.currentState
                            ?.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatRoomPage(room: rooms[index]),
                              ),
                            )
                            .then((value) => setState(() {
                                  futureRooms = fetchRooms();
                                })),
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
                                    offset: Offset(0, 3),
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
                                              : ("최근 대화 " +
                                                  rooms[index]
                                                      .latestMessageCreatedAt)),
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.black54,
                                          ),
                                        )),
                                        Icon(
                                          Icons.close,
                                          size: 14.r,
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
                                            Icon(Icons.people),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "${rooms[index].currentParticipants.length}/${rooms[index].maxParticipants}",
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
                                                  : rooms[index]
                                                          .latestMessageSender +
                                                      " : " +
                                                      rooms[index]
                                                          .latestMessageContent,
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
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xff48ADE5),
                                                        Color(0xff76CB68)
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    "편도",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                )
                                              : Container(
                                                  width: 50.w,
                                                  height: 20.h,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xffDCCB37),
                                                        Color(0xff44EB29)
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
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
}
