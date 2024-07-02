import 'dart:async';
import 'package:campride/login.dart';
import 'package:campride/room.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});

  @override
  _ChatRoomsPageState createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  @override
  void initState() {
    super.initState();
  }

  List<Room> rooms = [
    Room(
      id: 1,
      name: "준행행님",
      date: "2024-07-25 07:00",
      durationMinutes: 30,
      title: "상록 예비군 출발하실 분 구해요",
      rideType: "왕복",
      departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
      arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
      currentParticipants: 4,
      maxParticipants: 4,
      unreadMessages: 129,
    ),
    Room(
      id: 2,
      name: "민준님",
      date: "2024-07-20 09:00",
      durationMinutes: 45,
      title: "인천 공항 가실 분",
      rideType: "편도",
      departureLocation: "서울 역삼동 강남구 도복로 103호길",
      arrivalLocation: "인천 국제공항 강남구 도복로 103호길 비행장 123호",
      currentParticipants: 2,
      maxParticipants: 4,
      unreadMessages: 0,
    ),
  ];

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
            child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
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
                                offset:
                                    Offset(0, 3), // changes position of shadow
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
                                            color: Colors.black54),
                                      ),
                                      Text(
                                        "최근 대화 오후 5:33",
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.black54),
                                      ),
                                      Icon(
                                        Icons.close,
                                        size: 14.r,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // 자식들 사이에 최대 공간 배치
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
                                          SizedBox(
                                            width: 8.w,
                                          ),
                                          Text(
                                              "${rooms[index].currentParticipants}/${rooms[index].maxParticipants}"),
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
                                              "준행행님님 : 안녕하세요 레전드네",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.black54)),
                                        ),
                                        Container(
                                          width: 40.w,
                                          height: 25.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color:
                                                rooms[index].unreadMessages == 0
                                                    ? Colors.white
                                                    : Colors.redAccent,
                                          ),
                                          child: Center(
                                              child: Text(
                                            rooms[index]
                                                .unreadMessages
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.white),
                                          )),
                                        )
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
                                                  // 컨테이너 크기
                                                  height: 20.h,
                                                  // 컨테이너 높이
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xff48ADE5),
                                                          Color(0xff76CB68)
                                                        ]), // 컨테이너 색상
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
                                                  // 컨테이너 크기
                                                  height: 20.h,
                                                  // 컨테이너 높이
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xffDCCB37),
                                                          Color(0xff44EB29)
                                                        ]), // 컨테이너 색상
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
                                      ))
                                ],
                              )),
                        ),
                      ),
                    ],
                  );
                }),
          )),
    );
  }
}
