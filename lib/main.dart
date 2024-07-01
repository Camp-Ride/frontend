import 'package:campride/chat_rooms.dart';
import 'package:campride/main_list.dart';
import 'package:campride/mypage.dart';
import 'package:campride/room.dart';
import 'package:campride/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  await dotenv.load(fileName: "assets/env/.env");
  var key = await dotenv.env['APP_KEY'];
  AuthRepository.initialize(appKey: key!);

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
  int _selectedIndex = 1;

  static List<Widget> _widgetOptions = <Widget>[
    ChatRoomsPage(),
    CampRiderPage(),
    MyPage(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var room = Room(
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
  );

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _widgetOptions.elementAt(_selectedIndex),
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
            icon: Icon(Icons.library_books_outlined),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '마이페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF365B51),
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),

      floatingActionButton: _selectedIndex == 1
          ? SizedBox(
              width: 95.w,
              height: 40.h,
              child: FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: ((context) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(25.0).r,
                            child: Container(
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '4/14일 상록 예비군 출발하실 분 구해요',
                                        style: TextStyle(fontSize: 15.sp),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0).h,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '준행행님',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.black54),
                                        ),
                                        SizedBox(
                                          width: 50.w,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  "${room.currentParticipants}/${room.maxParticipants}"),
                                            ],
                                          ),
                                        ),
                                        "편도" == "편도"
                                            ? Container(
                                                width: 50.w, // 컨테이너 크기
                                                height: 20.h, // 컨테이너 높이
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xff48ADE5),
                                                        Color(0xff76CB68)
                                                      ]), // 컨테이너 색상
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  "편도",
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Container(
                                                width: 50.w, // 컨테이너 크기
                                                height: 20.h, // 컨테이너 높이
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xffDCCB37),
                                                        Color(0xff44EB29)
                                                      ]), // 컨테이너 색상
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
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
                                      padding:
                                          const EdgeInsets.only(top: 10.0).h,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent),
                                      child: Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: 40.h,
                                            ),
                                            Text(
                                              room.date + " 출발",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Text(
                                              "약" +
                                                  room.durationMinutes
                                                      .toString() +
                                                  "분 소요",
                                              style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Colors.orange,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 30.h,
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
                                                  width: 240.w,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          room
                                                              .departureLocation,
                                                          style: TextStyle(
                                                              fontSize: 13.sp,
                                                              color: Colors
                                                                  .black54)),
                                                      Text(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          room.arrivalLocation,
                                                          style: TextStyle(
                                                              fontSize: 13.sp,
                                                              color: Colors
                                                                  .black54)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF355A50)),
                                        onPressed: () {},
                                        child: Text('참여',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
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
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0).r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "방만들기",
                        style:
                            TextStyle(fontSize: 15.sp, color: Colors.black54),
                      ),
                      Icon(
                        Icons.add,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
