import 'package:campride/room.dart';
import 'package:campride/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(), // Wrap your app
    ),
  );
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: SplashScreen(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Text('채팅'),
    Text('캠프라이더 찾기'),
    Text('마이페이지'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0).w,
                                    child: SizedBox(
                                      width: 220.w,
                                      height: 50.h,
                                      child: TextField(
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent)),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent)),
                                            hintText: "Where do you start?",
                                            hintStyle: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 100))),
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
                                onPressed: () {},
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0).w,
                                    child: SizedBox(
                                      width: 220.w,
                                      height: 50.h,
                                      child: TextField(
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent)),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.transparent)),
                                            hintText: "Where are you going?",
                                            hintStyle: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 100))),
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
                                                    width: 220.w,
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
                                                              left: 8.0)
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
                                                IconButton(
                                                    onPressed: null,
                                                    icon: Icon(Icons
                                                        .arrow_circle_left))
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
                  ))
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: '캠프라이더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(color: Color(0xFF365B51)),
        selectedLabelStyle: TextStyle(color: Color(0xFF365B51)),
        unselectedIconTheme: IconThemeData(color: Colors.black54),
        onTap: _onItemTapped,
      ),

      floatingActionButton: SizedBox(
        width: 95.w,
        height: 40.h,
        child: FloatingActionButton(
          onPressed: null,
          child: Padding(
            padding: const EdgeInsets.all(8.0).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "방만들기",
                  style: TextStyle(fontSize: 15.sp, color: Colors.black54),
                ),
                Icon(
                  Icons.add,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
