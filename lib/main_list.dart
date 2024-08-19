import 'dart:async';
import 'dart:convert';
import 'package:campride/login.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class CampRiderPage extends StatefulWidget {
  const CampRiderPage({super.key});

  @override
  _CampRiderPageState createState() => _CampRiderPageState();
}

class _CampRiderPageState extends State<CampRiderPage> {
  @override
  void initState() {
    super.initState();
    futureRooms = fetchRooms();
  }

  var selectedTitle = "";
  var selectedDate = "";
  String? selectedValue;
  var startAddress = "";
  var arriveAddress = "";
  var isOneWay = false;
  var isRoundTrip = true;

  late Future<List<Room>> futureRooms;

  String mainStartAddress = "";
  String mainArriveAddress = "";
  List<String> dropDownList = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  Future<void> postRoomData(
      String selectedTitle,
      String selectedDate,
      String selectedValue,
      String startAddress,
      String arriveAddress,
      bool isOneWay,
      bool isRoundTrip) async {
    String jwt = (await SecureStroageService.readAccessToken())!;

    final formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
        .format(DateTime.parse(selectedDate));

    final url = Uri.parse('http://localhost:8080/api/v1/room');

    String roomType = "";
    if (isOneWay) {
      roomType = "ONE";
    }
    if (isRoundTrip) {
      roomType = "ROUND";
    }

    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "title": selectedTitle,
      "departure": startAddress,
      "destination": arriveAddress,
      "departureTime": formattedDate,
      "maxParticipants": int.parse(selectedValue),
      "roomType": roomType,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('요청 성공: ${response.body}');
      } else {
        print('요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  Future<List<Room>> fetchRooms() async {
    String jwt = (await SecureStroageService.readAccessToken())!;

    final url = Uri.parse('http://localhost:8080/api/v1/room?page=0&size=10');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

      List<dynamic> content = data['content'];

      return content.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Set<Marker> markers = {};
    late KakaoMapController kakaoMapController;

    return Scaffold(
        body: Container(
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
                                      padding:
                                          const EdgeInsets.only(left: 15.0).w,
                                      child: Text(
                                        "출발지",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8.0).w,
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
                                                  builder: (context) =>
                                                      Scaffold(
                                                    appBar: AppBar(
                                                      title: Text("주소 검색"),
                                                      backgroundColor:
                                                          Colors.white,
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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.transparent),
                                            overlayColor: MaterialStateProperty
                                                .all<Color>(Colors.transparent),
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
                                            mainStartAddress =
                                                mainArriveAddress,
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
                                      padding:
                                          const EdgeInsets.only(left: 15.0).w,
                                      child: Text(
                                        "도착지",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 8.0).w,
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
                                                  builder: (context) =>
                                                      Scaffold(
                                                    appBar: AppBar(
                                                      title: Text("주소 검색"),
                                                      backgroundColor:
                                                          Colors.white,
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
                                                MaterialStateProperty.all<
                                                    Color>(Colors.transparent),
                                            overlayColor: MaterialStateProperty
                                                .all<Color>(Colors.transparent),
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
                      child: FutureBuilder<List<Room>>(
                        future: futureRooms,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Center(child: Text('No rooms available'));
                          } else {
                            final rooms = snapshot.data!;
                            return ListView.builder(
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  child: Dialog(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                                  25.0)
                                                              .r,
                                                      child: Container(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    rooms[index]
                                                                        .title+"123123123123123123123123",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15.sp,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                                // Text 사이에 여유 공간을 추가할 수도 있습니다.
                                                                Text(
                                                                  rooms[index]
                                                                      .createdAt,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        10.sp,
                                                                    color: Colors
                                                                        .orange,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              4.0)
                                                                      .h,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    rooms[index]
                                                                        .name,
                                                                    style: TextStyle(
                                                                        fontSize: 12
                                                                            .sp,
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
                                                                          width:
                                                                              50.w,
                                                                          // 컨테이너 크기
                                                                          height:
                                                                              20.h,
                                                                          // 컨테이너 높이
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(colors: [
                                                                              Color(0xff48ADE5),
                                                                              Color(0xff76CB68)
                                                                            ]),
                                                                            // 컨테이너 색상
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            "편도",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          width:
                                                                              50.w,
                                                                          // 컨테이너 크기
                                                                          height:
                                                                              20.h,
                                                                          // 컨테이너 높이
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            gradient:
                                                                                LinearGradient(colors: [
                                                                              Color(0xffDCCB37),
                                                                              Color(0xff44EB29)
                                                                            ]),
                                                                            // 컨테이너 색상
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            "왕복",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            40.0)
                                                                    .h,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    color: Colors
                                                                        .black12,
                                                                  ),
                                                                  child:
                                                                      KakaoMap(
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
                                                                      height:
                                                                          40.h,
                                                                    ),
                                                                    Text(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      rooms[index]
                                                                              .date +
                                                                          " 출발",
                                                                      style: TextStyle(
                                                                          fontSize: 13
                                                                              .sp,
                                                                          color: Colors
                                                                              .blue,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10.h,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          30.h,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              13.33.w,
                                                                          height:
                                                                              46.4.h,
                                                                          child:
                                                                              Image.asset(
                                                                            "assets/images/start_end.png",
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              215.w,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(overflow: TextOverflow.ellipsis, rooms[index].departureLocation, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                                                                              Text(overflow: TextOverflow.ellipsis, rooms[index].arrivalLocation, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
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
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Color(
                                                                              0xFF355A50)),
                                                                  onPressed:
                                                                      () {},
                                                                  child: Text(
                                                                      '참여',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                                SizedBox(
                                                                  width: 10.w,
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      '닫기'),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(13.0)
                                                        .r,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          rooms[index].name,
                                                          style: TextStyle(
                                                              fontSize: 11.sp,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                        Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          rooms[index].date +
                                                              " 출발",
                                                          style: TextStyle(
                                                              fontSize: 11.sp,
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                        Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          rooms[index]
                                                              .createdAt,
                                                          style: TextStyle(
                                                              fontSize: 11.sp,
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      // 자식들 사이에 최대 공간 배치
                                                      children: [
                                                        Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          rooms[index].title,
                                                        ),
                                                        // 왼쪽 텍스트

                                                        rooms[index].rideType ==
                                                                "편도"
                                                            ? Container(
                                                                width: 60
                                                                    .w, // 컨테이너 크기
                                                                height: 20
                                                                    .h, // 컨테이너 높이
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
                                                                width: 60
                                                                    .w, // 컨테이너 크기
                                                                height: 20
                                                                    .h, // 컨테이너 높이
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
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
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
                                                                const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8.0)
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
                                                                          fontSize: 13
                                                                              .sp,
                                                                          color:
                                                                              Colors.black54)),
                                                                  Text(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      rooms[index]
                                                                          .arrivalLocation,
                                                                      style: TextStyle(
                                                                          fontSize: 13
                                                                              .sp,
                                                                          color:
                                                                              Colors.black54)),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            0.0)
                                                                    .w,
                                                            child: SizedBox(
                                                              width: 35.w,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .people,
                                                                    color: Colors
                                                                        .black,
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
                                });
                          }
                        },
                      ),
                    ))
              ],
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 95.w,
          height: 40.h,
          child: FloatingActionButton(
            backgroundColor: Color(0xff154236),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: ((context) {
                  return Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0).r,
                            child: Container(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                        onTap: () => {
                                              Navigator.of(context).pop(),
                                              setState(() {
                                                selectedTitle = "";
                                                selectedDate = "";
                                                selectedValue = null;
                                                startAddress = "";
                                                arriveAddress = "";
                                                isOneWay = false;
                                                isRoundTrip = false;
                                              }),
                                            },
                                        child: Icon(Icons.close)),
                                    Text("방만들기"),
                                    Center(
                                      child: SizedBox(
                                        width: 45.w,
                                        height: 27.h,
                                        child: TextButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF355A50),
                                          ),
                                          onPressed: () async {
                                            await postRoomData(
                                                selectedTitle,
                                                selectedDate,
                                                selectedValue!,
                                                startAddress,
                                                arriveAddress,
                                                isOneWay,
                                                isRoundTrip);
                                            Navigator.of(context).pop();
                                            setState(() {
                                              selectedTitle = "";
                                              selectedDate = "";
                                              selectedValue = null;
                                              startAddress = "";
                                              arriveAddress = "";
                                              isOneWay = false;
                                              isRoundTrip = false;
                                            });
                                          },
                                          child: Text(
                                            '완료',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextField(
                                  onChanged: (text) {
                                    setState(() {
                                      selectedTitle = text;
                                    });
                                  },
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '방 제목을 입력해 주세요!',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black54),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: 300.w,
                                      height: 51.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF355A50),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                    left: 10.0)
                                                .w,
                                            child: Text(
                                              "출발지",
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8.0)
                                                    .w,
                                            child: SizedBox(
                                                width: 16.w,
                                                child: Image.asset(
                                                  "assets/images/location.png",
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: 50.h,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                          appBar: AppBar(
                                                            title:
                                                                Text("주소 검색"),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                          body:
                                                              DaumPostcodeView(
                                                            onComplete:
                                                                (model) {
                                                              setState(() {
                                                                startAddress =
                                                                    model
                                                                        .address;
                                                              });

                                                              Navigator.of(
                                                                      context)
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
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent),
                                                  overlayColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent),
                                                ),
                                                child: Text(
                                                  startAddress == ""
                                                      ? "Where do you start?"
                                                      : startAddress,
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
                                    Center(
                                      child: Container(
                                        width: 40.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            if (startAddress != "" &&
                                                arriveAddress != "") {
                                              String tempAddress = "";

                                              setState(() => {
                                                    tempAddress = startAddress,
                                                    startAddress =
                                                        arriveAddress,
                                                    arriveAddress = tempAddress,
                                                  });
                                            }
                                          },
                                          icon: Image.asset(
                                            "assets/images/change.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 300.w,
                                      height: 51.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF355A50),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                    left: 10.0)
                                                .w,
                                            child: Text(
                                              "도착지",
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8.0)
                                                    .w,
                                            child: SizedBox(
                                                width: 16.w,
                                                child: Image.asset(
                                                  "assets/images/location.png",
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              height: 50.h,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Scaffold(
                                                          appBar: AppBar(
                                                            title:
                                                                Text("주소 검색"),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                          body:
                                                              DaumPostcodeView(
                                                            onComplete:
                                                                (model) {
                                                              setState(() {
                                                                arriveAddress =
                                                                    model
                                                                        .address;
                                                              });

                                                              Navigator.of(
                                                                      context)
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
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent),
                                                  overlayColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent),
                                                ),
                                                child: Text(
                                                  arriveAddress == ""
                                                      ? "Where are you going?"
                                                      : arriveAddress,
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
                                Container(
                                  width: 300.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black54, // 테두리 색상
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white70.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 3,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                      onPressed: () {
                                        DatePicker.showDateTimePicker(context,
                                            showTitleActions: true,
                                            onChanged: (date) {
                                          print('change $date');
                                        }, onConfirm: (date) {
                                          print('confirm $date');

                                          setState(() {
                                            selectedDate =
                                                DateFormat('yyyy-MM-dd HH:mm')
                                                    .format(date)
                                                    .toString();
                                          });

                                          print(selectedDate);
                                        },
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.ko);
                                      },
                                      child: Center(
                                        child: Text(
                                          selectedDate == ""
                                              ? '출발할 날짜와 시간을 선택해 주세요!'
                                              : selectedDate,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14.sp),
                                        ),
                                      )),
                                ),
                                Container(
                                    width: 300.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.black54, // 테두리 색상
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.white70.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 3,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: DropdownButton(
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14.sp),
                                        alignment: Alignment.center,
                                        value: selectedValue,
                                        underline: SizedBox.shrink(),
                                        icon: SizedBox.shrink(),
                                        hint: Text(
                                          "방 최대 참여 인원을 선택해 주세요!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14.sp),
                                        ),
                                        items: dropDownList
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedValue = value;
                                          });
                                        },
                                      ),
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Checkbox(
                                      value: isRoundTrip,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          isRoundTrip = true;
                                          isOneWay = false;
                                        });
                                      },
                                    ),
                                    Container(
                                      width: 50.w,
                                      // 컨테이너 크기
                                      height: 20.h,
                                      // 컨테이너 높이
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Color(0xffDCCB37),
                                          Color(0xff44EB29)
                                        ]), // 컨테이너 색상
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "왕복",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isOneWay,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          isOneWay = true;
                                          isRoundTrip = false;
                                        });
                                      },
                                    ),
                                    Container(
                                      width: 60.w, // 컨테이너 크기
                                      height: 20.h, // 컨테이너 높이
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Color(0xff48ADE5),
                                          Color(0xff76CB68)
                                        ]), // 컨테이너 색상
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        "편도",
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )),
                          ),
                        );
                      }));
                }),
              ).then((value) => {
                    setState(() {
                      futureRooms = fetchRooms();
                    })
                  });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "방만들기",
                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                  ),
                  Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            heroTag: "actionButton",
          ),
        ));
  }
}
