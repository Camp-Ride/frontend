import 'dart:async';
import 'package:campride/login.dart';
import 'package:campride/room.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CampRiderPage extends StatefulWidget {
  const CampRiderPage({super.key});

  @override
  _CampRiderPageState createState() => _CampRiderPageState();
}

class _CampRiderPageState extends State<CampRiderPage> {
  @override
  void initState() {
    super.initState();
  }

  String mainStartAddress = "";
  String mainArriveAddress = "";
  List<Room> rooms = [
    Room(
      id: 1,
      name: "준행행님",
      date: "2024-07-25 07:00",
      title: "상록 예비군 출발하실 분 구해요",
      rideType: "왕복",
      departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
      arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
      currentParticipants: 4,
      maxParticipants: 4,
      unreadMessages: 129,
      createdAt: "2024-07-25"
    ),
    Room(
      id: 1,
      name: "준행행님",
      date: "2024-07-25 07:00",
      title: "상록 예비군 출발하실 분 구해요",
      rideType: "왕복",
      departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
      arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
      currentParticipants: 4,
      maxParticipants: 4,
      unreadMessages: 129,
      createdAt: '2024-07-25'
    ),
    Room(
      id: 1,
      name: "준행행님",
      date: "2024-07-25 07:00",
      title: "상록 예비군 출발하실 분 구해요",
      rideType: "왕복",
      departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
      arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
      currentParticipants: 4,
      maxParticipants: 4,
      unreadMessages: 129,
      createdAt: '2024-07-25'
    ),
    Room(
      id: 1,
      name: "준행행님",
      date: "2024-07-25 07:00",
      title: "상록 예비군 출발하실 분 구해요",
      rideType: "왕복",
      departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
      arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
      currentParticipants: 4,
      maxParticipants: 4,
      unreadMessages: 129,
      createdAt: '2024-07-25'
    ),
    Room(
      id: 2,
      name: "민준님",
      date: "2024-07-20 09:00",
      title: "인천 공항 가실 분",
      rideType: "편도",
      departureLocation: "서울 역삼동 강남구 도복로 103호길",
      arrivalLocation: "인천 국제공항 강남구 도복로 103호길 비행장 123호",
      currentParticipants: 2,
      maxParticipants: 4,
      unreadMessages: 129,
      createdAt: '2024-07-25'
    ),
    // 추가 Room 객체를 여기에 선언할 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Set<Marker> markers = {};
    late KakaoMapController kakaoMapController;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF355A50), Color(0xFF154135)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
                flex: 5,
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF355A50), Color(0xFF154135)],
                    ),
                  ),
                  child: DefaultTextStyle(
                    style: GoogleFonts.getFont(
                      'ABeeZee',
                      fontWeight: FontWeight.bold,
                    ),
                    child: Stack(children: [
                      Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 31.w,
                              ),
                              Text(
                                "캠프 라이더 찾기",
                                style: GoogleFonts.getFont(
                                  'ABeeZee',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.35,
                              ),
                              Row(children: [
                                Text(
                                  "CAMPRIDE",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: Colors.black),
                                ),
                              ])
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          Container(
                            width: 296.w,
                            height: 51.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF355A50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0).w,
                                  child: Text(
                                    "출발지",
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0).w,
                                  child: SizedBox(
                                      width: 16.w,
                                      child: Image.asset(
                                        "assets/images/location.png",
                                        fit: BoxFit.fill,
                                      )),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: 215.w,
                                    height: 50.h,
                                    child: TextButton(
                                      onPressed: () async {
                                        var model = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  title: Text("주소 검색"),
                                                  backgroundColor: Colors.white,
                                                ),
                                                body: DaumPostcodeView(
                                                  onComplete: (model) {
                                                    Navigator.of(context)
                                                        .pop(model);
                                                  },
                                                  options:
                                                      const DaumPostcodeOptions(
                                                    animation: true,
                                                    hideEngBtn: true,
                                                    themeType:
                                                        DaumPostcodeThemeType
                                                            .defaultTheme,
                                                  ),
                                                ),
                                              ),
                                            ));

                                        setState(() {
                                          mainStartAddress = model.address;
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                        overlayColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                      ),
                                      child: Text(
                                        mainStartAddress == ""
                                            ? "Where do you start?"
                                            : mainStartAddress,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 40.w,
                            height: 40.h,
                            child: IconButton(
                              onPressed: () {
                                if (mainStartAddress != "" &&
                                    mainArriveAddress != "") {
                                  String tempAddress = "";

                                  setState(() => {
                                        tempAddress = mainStartAddress,
                                        mainStartAddress = mainArriveAddress,
                                        mainArriveAddress = tempAddress,
                                      });
                                }
                              },
                              icon: Image.asset("assets/images/change.png",
                                  fit: BoxFit.fill),
                            ),
                          ),
                          Container(
                            width: 296.w,
                            height: 51.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF355A50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0).w,
                                  child: Text(
                                    "도착지",
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0).w,
                                  child: SizedBox(
                                      width: 16.w,
                                      child: Image.asset(
                                        "assets/images/location.png",
                                        fit: BoxFit.fill,
                                      )),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    width: 215.w,
                                    height: 50.h,
                                    child: TextButton(
                                      onPressed: () async {
                                        var model = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(
                                                  title: Text("주소 검색"),
                                                  backgroundColor: Colors.white,
                                                ),
                                                body: DaumPostcodeView(
                                                  onComplete: (model) {
                                                    Navigator.of(context)
                                                        .pop(model);
                                                  },
                                                  options:
                                                      const DaumPostcodeOptions(
                                                    animation: true,
                                                    hideEngBtn: true,
                                                    themeType:
                                                        DaumPostcodeThemeType
                                                            .defaultTheme,
                                                  ),
                                                ),
                                              ),
                                            ));
                                        setState(() {
                                          mainArriveAddress = model.address;
                                        });
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                        overlayColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                      ),
                                      child: Text(
                                        mainArriveAddress == ""
                                            ? "Where are you going?"
                                            : mainArriveAddress,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                )),
            Flexible(
                flex: 7,
                child: Container(
                  alignment: Alignment.topCenter,
                  color: Colors.white,
                  child: ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: ((context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Dialog(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(25.0).r,
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        rooms[index].title,
                                                        style: TextStyle(
                                                            fontSize: 15.sp),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                                top: 4.0)
                                                            .h,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          rooms[index].name,
                                                          style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                        SizedBox(
                                                          width: 50.w,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  "${rooms[index].currentParticipants}/${rooms[index].maxParticipants}"),
                                                            ],
                                                          ),
                                                        ),
                                                        rooms[index].rideType ==
                                                                "편도"
                                                            ? Container(
                                                                width: 50.w,
                                                                // 컨테이너 크기
                                                                height: 20.h,
                                                                // 컨테이너 높이
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                          colors: [
                                                                        Color(
                                                                            0xff48ADE5),
                                                                        Color(
                                                                            0xff76CB68)
                                                                      ]), // 컨테이너 색상
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child: Text(
                                                                  "편도",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 50.w,
                                                                // 컨테이너 크기
                                                                height: 20.h,
                                                                // 컨테이너 높이
                                                                decoration:
                                                                    BoxDecoration(
                                                                  gradient:
                                                                      LinearGradient(
                                                                          colors: [
                                                                        Color(
                                                                            0xffDCCB37),
                                                                        Color(
                                                                            0xff44EB29)
                                                                      ]), // 컨테이너 색상
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child: Text(
                                                                  "왕복",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                                  top: 40.0)
                                                              .h,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          color: Colors.black12,
                                                        ),
                                                        child: KakaoMap(
                                                          onMapCreated:
                                                              ((controller) {
                                                            kakaoMapController =
                                                                controller;
                                                          }),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .transparent),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 40.h,
                                                          ),
                                                          Text(
                                                            rooms[index].date +
                                                                " 출발",
                                                            style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color:
                                                                    Colors.blue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 10.h,
                                                          ),
                                                          Text(
                                                            rooms[index].createdAt,
                                                            style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color: Colors
                                                                    .orange,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          SizedBox(
                                                            height: 30.h,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceAround,
                                                            children: [
                                                              SizedBox(
                                                                width: 13.33.w,
                                                                height: 46.4.h,
                                                                child:
                                                                    Image.asset(
                                                                  "assets/images/start_end.png",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 215.w,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        rooms[index]
                                                                            .departureLocation,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13.sp,
                                                                            color: Colors.black54)),
                                                                    Text(
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        rooms[index]
                                                                            .arrivalLocation,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13.sp,
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
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Color(
                                                                        0xFF355A50)),
                                                        onPressed: () {},
                                                        child: Text('참여',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('닫기'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  )
                                },
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
                                                rooms[index].createdAt,
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
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              Color(0xff48ADE5),
                                                              Color(0xff76CB68)
                                                            ]), // 컨테이너 색상
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        "편도",
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 60.w, // 컨테이너 크기
                                                      height: 20.h, // 컨테이너 높이
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                                colors: [
                                                              Color(0xffDCCB37),
                                                              Color(0xff44EB29)
                                                            ]), // 컨테이너 색상
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        "왕복",
                                                        textAlign:
                                                            TextAlign.center,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                              left: 8.0)
                                                          .w,
                                                  child: SizedBox(
                                                    width: 210.w,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            rooms[index]
                                                                .departureLocation,
                                                            style: TextStyle(
                                                                fontSize: 13.sp,
                                                                color: Colors
                                                                    .black54)),
                                                        Text(
                                                            overflow:
                                                                TextOverflow
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                              left: 0.0)
                                                          .w,
                                                  child: SizedBox(
                                                    width: 35.w,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
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
                                                      icon: Icon(Icons
                                                          .arrow_circle_left)),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ))
          ],
        ),
      ),
    );
  }
}
