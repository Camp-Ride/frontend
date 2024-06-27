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
    ),
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
    ),
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
    ),
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
        maxParticipants: 4),
    // 추가 Room 객체를 여기에 선언할 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Flexible(
        flex: 7,
        child: MaterialApp(
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
                              height: 150.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(13.0).r,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            rooms[index].date + " 출발",
                                            style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.blue),
                                          ),
                                          Text(
                                            "약" +
                                                rooms[index]
                                                    .durationMinutes
                                                    .toString() +
                                                "분 소요",
                                            style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.orange),
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
                                          Text(
                                            overflow: TextOverflow.ellipsis,
                                            rooms[index].title,
                                          ),
// 왼쪽 텍스트

                                          rooms[index].rideType == "편도"
                                              ? Container(
                                                  width: 60.w, // 컨테이너 크기
                                                  height: 20.h, // 컨테이너 높이
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
                                                  width: 60.w, // 컨테이너 크기
                                                  height: 20.h, // 컨테이너 높이
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
                                      ),
                                      Expanded(
                                        child: Row(
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                      left: 8.0)
                                                  .w,
                                              child: SizedBox(
                                                width: 210.w,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        rooms[index]
                                                            .departureLocation,
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: Colors
                                                                .black54)),
                                                    Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        rooms[index]
                                                            .arrivalLocation,
                                                        style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: Colors
                                                                .black54)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                      left: 0.0)
                                                  .w,
                                              child: SizedBox(
                                                width: 35.w,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.people,
                                                      color: Colors.black,
                                                      size: 24.0,
                                                      semanticLabel:
                                                          'Text to announce in accessibility modes',
                                                    ),
                                                    Text(
                                                        "${rooms[index].currentParticipants}/${rooms[index].maxParticipants}"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 40.w,
                                              height: 40.h,
                                              child: IconButton(
                                                  onPressed: null,
                                                  icon: Icon(
                                                      Icons.arrow_circle_left)),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      );
                    }),
              )),
        ));
  }
}
