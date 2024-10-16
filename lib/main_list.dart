import 'dart:async';
import 'dart:convert';
import 'package:campride/auth_dio.dart';
import 'package:campride/chat_room.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'login.dart';

class CampRiderPage extends StatefulWidget {
  const CampRiderPage({super.key});

  @override
  _CampRiderPageState createState() => _CampRiderPageState();
}

class _CampRiderPageState extends State<CampRiderPage> {
  String mainStartAddress = "";
  String mainArriveAddress = "";
  int startOffset = 0;
  ScrollController scrollController = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    start_controller.text = mainStartAddress;
    arrive_controller.text = mainArriveAddress;

    futureRooms = fetchRooms();
  }

  @override
  void dispose() {
    start_controller.dispose();
    arrive_controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  var selectedTitle = "";
  var selectedDate = "";
  String? selectedValue;
  String? selectedTrainingDate;
  var startAddress = "";
  var arriveAddress = "";
  var isOneWay = false;
  var isRoundTrip = true;

  late Future<List<Room>> futureRooms;

  TextEditingController start_controller = TextEditingController();
  TextEditingController arrive_controller = TextEditingController();

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

  List<String> dropDownList2 = ['2', '3', '4', '5', '6', '7', '8', '9', '10'];

  Future<void> postRoomData(
      String selectedTitle,
      String selectedDate,
      String selectedTrainingDate,
      String selectedValue,
      String startAddress,
      String arriveAddress,
      bool isOneWay,
      bool isRoundTrip) async {
    final formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss")
        .format(DateTime.parse(selectedDate));

    String roomType = "";
    if (isOneWay) {
      roomType = "ONE";
    }
    if (isRoundTrip) {
      roomType = "ROUND";
    }

    var dio = await authDio(context);

    try {
      final response = await dio.post('/room', data: {
        'title': selectedTitle,
        'departure': startAddress,
        'destination': arriveAddress,
        'departureTime': formattedDate,
        'trainingDays': int.parse(selectedTrainingDate),
        'maxParticipants': int.parse(selectedValue),
        'roomType': roomType,
      });
      print('Room created successfully');
    } on DioException catch (e) {
      print('Error: $e');
      print('Response: ${e.response}');
    }
  }

  Future<List<Room>> fetchRooms() async {
    var dio = await authDio(context);

    try {
      final response = await dio.get('/room?page=0&size=10');

      Map<String, dynamic> data = response.data;

      List<dynamic> content = data['content'];
      print(content);

      return content.map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      final storage = new FlutterSecureStorage();

      await storage.deleteAll();

      // . . .
      // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
    return [];
  }

  Future<void> joinRoom(Room room) async {
    var dio = await authDio(context);

    int roomId = room.id;

    try {
      final response = await dio.put('/room/$roomId/join');
      print('Room joined successfully');
      sendJoinRequest(roomId).then((value) => {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatRoomPage(initialRoom: room)))
                .then((value) => setState(() {
                      futureRooms = fetchRooms();
                    }))
          });
    } on DioException catch (e) {
      print('Error: $e');
      print('Response: ${e.response}');

      Map<String, dynamic> response = jsonDecode(e.response.toString());
      print(response['code']);

      if (response['code'] == 4005) {
        _showFailureDialog(context, "최대 참여 인원을 초과하였습니다.");
        setState(() {
          futureRooms = fetchRooms();
        });
      } else if (response['code'] == 3007) {
        _showFailureDialog(context, '강제퇴장된 방에 다시 입장할 수 없습니다.');
      } else if (response['code'] == 3006) {
        _showFailureDialog(context, '방에 이미 참여 중입니다.');
      } else {
        _showFailureDialog(context, '알수 없는 에러가 발생했습니다. 잠시 후 다시 시도해 주세요.');
      }
    }
  }

  Future<void> sendJoinRequest(int roomId) async {
    var dio = await authDio(context);

    try {
      final response = await dio.post('/chat/send/join/$roomId', data: {
        'userId': await SecureStroageService.readUserId(),
        'userNickname': await SecureStroageService.readNickname(),
      });
      print('Join request sent successfully.');
      print('Response Data: ${response.data}');
    } on DioException catch (e) {
      print(
          'Failed to send join request. Status code: ${e.response?.statusCode}');
      print('Response body: ${e.response?.data}');
    }
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

  Future<List<Room>> searchRoomsByAddress(String mainStartAddress,
      String mainArriveAddress, int startOffset) async {
    var dio = await authDio(context);

    final response = await dio.get(
        '/room/address?page=$startOffset&size=10&departure=$mainStartAddress&destination=$mainArriveAddress');

    Map<String, dynamic> data = response.data;

    List<dynamic> content = data['content'];

    return content.map((json) => Room.fromJson(json)).toList();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    startOffset++;

    final List<Room> rooms = await futureRooms;
    rooms.addAll(await searchRoomsByAddress(
        mainStartAddress, mainArriveAddress, startOffset));

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Set<Marker> markers = {};
    late KakaoMapController kakaoMapController;

    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                                        child: TextField(
                                          controller: start_controller,
                                          textAlign: TextAlign.center,
                                          onChanged: (text) {
                                            setState(() {
                                              mainStartAddress = text;
                                              start_controller.text =
                                                  mainStartAddress;
                                            });

                                            setState(() {
                                              futureRooms =
                                                  searchRoomsByAddress(
                                                      mainStartAddress,
                                                      mainArriveAddress,
                                                      0);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Where do you start?',
                                            hintStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.sp,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            border: InputBorder
                                                .none, // Removes the default underline border
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.sp,
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

                                      setState(() {
                                        tempAddress = mainStartAddress;
                                        mainStartAddress = mainArriveAddress;
                                        mainArriveAddress = tempAddress;
                                        start_controller.text =
                                            mainStartAddress;
                                        arrive_controller.text =
                                            mainArriveAddress;
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
                                        child: TextField(
                                          controller: arrive_controller,
                                          onChanged: (text) {
                                            setState(() {
                                              mainArriveAddress = text;
                                              arrive_controller.text =
                                                  mainArriveAddress;
                                              futureRooms =
                                                  searchRoomsByAddress(
                                                      mainStartAddress,
                                                      mainArriveAddress,
                                                      0);
                                            });
                                          },
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            hintText: 'Where are you going?',
                                            hintStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.sp,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            border: InputBorder
                                                .none, // Removes the default underline border
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.sp,
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
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('생성된 방이 없습니다.'));
                          } else {
                            final rooms = snapshot.data!;
                            return Scrollbar(
                              controller: scrollController,
                              child: SmartRefresher(
                                enablePullDown: false,
                                enablePullUp: true,
                                onRefresh: _onRefresh,
                                onLoading: _onLoading,
                                controller: _refreshController,
                                header: ClassicHeader(),
                                child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: rooms.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () => {
                                                if (MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom ==
                                                    0)
                                                  {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: ((context) {
                                                        return SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          child: Dialog(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
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
                                                                          child:
                                                                              Text(
                                                                            rooms[index].title,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15.sp,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        // Text 사이에 여유 공간을 추가할 수도 있습니다.
                                                                        Text(
                                                                          rooms[index]
                                                                              .createdAt,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                10.sp,
                                                                            color:
                                                                                Colors.orange,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.only(top: 4.0)
                                                                              .h,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            rooms[index].name,
                                                                            style:
                                                                                TextStyle(fontSize: 12.sp, color: Colors.black54),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                50.w,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text("${rooms[index].currentParticipants.length}/${rooms[index].maxParticipants}"),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          rooms[index].rideType == "편도"
                                                                              ? Container(
                                                                                  width: 50.w,
                                                                                  // 컨테이너 크기
                                                                                  height: 20.h,
                                                                                  // 컨테이너 높이
                                                                                  decoration: BoxDecoration(
                                                                                    gradient: const LinearGradient(colors: [
                                                                                      Color(0xff48ADE5),
                                                                                      Color(0xff76CB68)
                                                                                    ]),
                                                                                    // 컨테이너 색상
                                                                                    borderRadius: BorderRadius.circular(10),
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
                                                                                    gradient: const LinearGradient(colors: [
                                                                                      Color(0xffDCCB37),
                                                                                      Color(0xff44EB29)
                                                                                    ]),
                                                                                    // 컨테이너 색상
                                                                                    borderRadius: BorderRadius.circular(10),
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
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(top: 40.0).h,
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            color:
                                                                                Colors.black12,
                                                                          ),
                                                                          child:
                                                                              KakaoMap(
                                                                            onMapCreated:
                                                                                ((controller) async {
                                                                              kakaoMapController = controller;

                                                                              final departureLocation = LatLng(rooms[index].departureLocation[0] as double, rooms[index].departureLocation[1] as double);
                                                                              final destinationLocation = LatLng(rooms[index].arrivalLocation[0] as double, rooms[index].arrivalLocation[1] as double);

                                                                              // 출발지 마커 추가
                                                                              markers.add(Marker(
                                                                                markerId: UniqueKey().toString(),
                                                                                latLng: departureLocation,
                                                                              ));

                                                                              markers.add(Marker(markerId: UniqueKey().toString(), latLng: destinationLocation));

                                                                              kakaoMapController.panTo(departureLocation);
                                                                              kakaoMapController.addMarker(markers: markers.toList());

                                                                              setState(() {});
                                                                            }),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            const BoxDecoration(color: Colors.transparent),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 40.h,
                                                                            ),
                                                                            Text(
                                                                              overflow: TextOverflow.ellipsis,
                                                                              "${rooms[index].date} 출발, " + rooms[index].trainingDays.toString() + "일",
                                                                              style: TextStyle(fontSize: 13.sp, color: Colors.blue, fontWeight: FontWeight.bold),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 50.h,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(overflow: TextOverflow.ellipsis, rooms[index].departure, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
                                                                                      Text(overflow: TextOverflow.ellipsis, rooms[index].arrival, style: TextStyle(fontSize: 13.sp, color: Colors.black54)),
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
                                                                          style:
                                                                              ElevatedButton.styleFrom(backgroundColor: const Color(0xFF355A50)),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                            joinRoom(rooms[index]);
                                                                          },
                                                                          child: const Text(
                                                                              '참여',
                                                                              style: TextStyle(color: Colors.white)),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10.w,
                                                                        ),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              const Text('닫기'),
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
                                                  }
                                                else
                                                  {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus(),
                                                  }
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
                                                      offset: const Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                                13.0)
                                                            .r,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              rooms[index].name,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      11.sp,
                                                                  color: Colors
                                                                      .black54),
                                                            ),
                                                            Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              "${rooms[index].date} 출발, " +
                                                                  rooms[index]
                                                                      .trainingDays
                                                                      .toString() +
                                                                  "일",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      11.sp,
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                            Text(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              rooms[index]
                                                                  .createdAt,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      11.sp,
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
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              rooms[index]
                                                                  .title,
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
                                                                          const LinearGradient(
                                                                              colors: [
                                                                            Color(0xff48ADE5),
                                                                            Color(0xff76CB68)
                                                                          ]),
                                                                      // 컨테이너 색상
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        const Text(
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
                                                                          const LinearGradient(
                                                                              colors: [
                                                                            Color(0xffDCCB37),
                                                                            Color(0xff44EB29)
                                                                          ]),
                                                                      // 컨테이너 색상
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        const Text(
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
                                                                child:
                                                                    Image.asset(
                                                                  "assets/images/start_end.png",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
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
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          rooms[index]
                                                                              .departure,
                                                                          style: TextStyle(
                                                                              fontSize: 13.sp,
                                                                              color: Colors.black54)),
                                                                      Text(
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          rooms[index]
                                                                              .arrival,
                                                                          style: TextStyle(
                                                                              fontSize: 13.sp,
                                                                              color: Colors.black54)),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
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
                                                                      const Icon(
                                                                        Icons
                                                                            .people,
                                                                        color: Colors
                                                                            .black,
                                                                        size:
                                                                            24.0,
                                                                        semanticLabel:
                                                                            'Text to announce in accessibility modes',
                                                                      ),
                                                                      Text(
                                                                          "${rooms[index].currentParticipants.length}/${rooms[index].maxParticipants}"),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),

                                                              SizedBox(
                                                                width: 40.w,
                                                                height: 40.h,
                                                                child: const IconButton(
                                                                    onPressed:
                                                                        null,
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
                              ),
                            );
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
            backgroundColor: const Color(0xff154236),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: ((context) {
                  return SingleChildScrollView(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          return Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(25.0).r,
                              child: Container(
                                  child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                                  selectedTrainingDate = null;
                                                  startAddress = "";
                                                  arriveAddress = "";
                                                  isOneWay = false;
                                                  isRoundTrip = false;
                                                }),
                                              },
                                          child: const Icon(Icons.close)),
                                      const Text("방만들기"),
                                      Center(
                                        child: SizedBox(
                                          width: 45.w,
                                          height: 27.h,
                                          child: TextButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF355A50),
                                            ),
                                            onPressed: () async {
                                              await postRoomData(
                                                  selectedTitle,
                                                  selectedDate,
                                                  selectedTrainingDate!,
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
                                                selectedTrainingDate = null;
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
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  TextField(
                                    onChanged: (text) {
                                      setState(() {
                                        selectedTitle = text;
                                      });
                                    },
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
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
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        width: 300.w,
                                        height: 51.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF355A50),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                              padding: const EdgeInsets.only(
                                                      left: 8.0)
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
                                                            resizeToAvoidBottomInset:
                                                                false,
                                                            appBar: AppBar(
                                                              title: const Text(
                                                                  "주소 검색"),
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
                                                                hideEngBtn:
                                                                    true,
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
                                                        WidgetStateProperty.all<
                                                                Color>(
                                                            Colors.transparent),
                                                    overlayColor:
                                                        WidgetStateProperty.all<
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
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              if (startAddress != "" &&
                                                  arriveAddress != "") {
                                                String tempAddress = "";

                                                setState(() {
                                                  tempAddress = startAddress;
                                                  startAddress = arriveAddress;
                                                  arriveAddress = tempAddress;
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
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                              padding: const EdgeInsets.only(
                                                      left: 8.0)
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
                                                            resizeToAvoidBottomInset:
                                                                false,
                                                            appBar: AppBar(
                                                              title: const Text(
                                                                  "주소 검색"),
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
                                                                hideEngBtn:
                                                                    true,
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
                                                        WidgetStateProperty.all<
                                                                Color>(
                                                            Colors.transparent),
                                                    overlayColor:
                                                        WidgetStateProperty.all<
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
                                  SizedBox(
                                    height: 20.h,
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
                                          offset: const Offset(0,
                                              3), // changes position of shadow
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
                                  SizedBox(
                                    height: 20.h,
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
                                            offset: const Offset(0,
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
                                          value: selectedTrainingDate,
                                          underline: const SizedBox.shrink(),
                                          icon: const SizedBox.shrink(),
                                          hint: Text(
                                            "며칠 동안 훈련받으시나요?",
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
                                              selectedTrainingDate = value;
                                            });
                                          },
                                        ),
                                      )),
                                  SizedBox(
                                    height: 20.h,
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
                                            offset: const Offset(0,
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
                                          underline: const SizedBox.shrink(),
                                          icon: const SizedBox.shrink(),
                                          hint: Text(
                                            "방 최대 참여 인원을 선택해 주세요!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14.sp),
                                          ),
                                          items: dropDownList2
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
                                  SizedBox(
                                    height: 20.h,
                                  ),
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
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xffDCCB37),
                                                Color(0xff44EB29)
                                              ]), // 컨테이너 색상
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
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
                                          gradient: const LinearGradient(
                                              colors: [
                                                Color(0xff48ADE5),
                                                Color(0xff76CB68)
                                              ]), // 컨테이너 색상
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
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
                        })),
                  );
                }),
              ).then((value) => {
                    setState(() {
                      futureRooms = fetchRooms();
                    })
                  });
            },
            heroTag: "actionButton",
            child: Padding(
              padding: const EdgeInsets.all(8.0).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "방만들기",
                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                  ),
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
