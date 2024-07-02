import 'package:campride/chat_rooms.dart';
import 'package:campride/main_list.dart';
import 'package:campride/mypage.dart';
import 'package:campride/room.dart';
import 'package:campride/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';

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
  String? selectedValue;

  String startAddress = "";
  String arriveAddress = "";

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
    unreadMessages:129,
  );

  var selectedDate = "";

  List<String> dropDownList = [
    '1명',
    '2명',
    '3명',
    '4명',
    '5명',
    '6명',
    '7명',
    '8명',
    '9명',
    '10명'
  ];

  bool isRoundTrip = false;
  bool isOneWay = false;

  void _onRoundTripChanged(bool? newValue) {
    setState(() {
      isRoundTrip = newValue ?? false;
      if (isRoundTrip) {
        isOneWay = false;
      }
    });
    print(isRoundTrip);
    print(isOneWay);
  }

  void _onOneWayChanged(bool? newValue) {
    setState(() {
      isOneWay = newValue ?? false;
      if (isOneWay) {
        isRoundTrip = false;
      }
    });
    print(isRoundTrip);
    print(isOneWay);
  }

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
        backgroundColor: Colors.white,
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
                                                backgroundColor:
                                                    Color(0xFF355A50),
                                              ),
                                              onPressed: () {},
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
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: '방 제목을 입력해 주세요!',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
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
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .transparent),
                                                      overlayColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .transparent),
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
                                                        tempAddress =
                                                            startAddress,
                                                        startAddress =
                                                            arriveAddress,
                                                        arriveAddress =
                                                            tempAddress,
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
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                        left: 0.0)
                                                    .w,
                                                child: Expanded(
                                                  child: SizedBox(
                                                    height: 50.h,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Scaffold(
                                                                appBar: AppBar(
                                                                  title: Text(
                                                                      "주소 검색"),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
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
                                                                        .pop(
                                                                            model);
                                                                  },
                                                                  options:
                                                                      const DaumPostcodeOptions(
                                                                    animation:
                                                                        true,
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
                                                            MaterialStateProperty
                                                                .all<Color>(Colors
                                                                    .transparent),
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all<Color>(Colors
                                                                    .transparent),
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
                                            color:
                                                Colors.white70.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 3,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: TextButton(
                                          onPressed: () {
                                            DatePicker.showDateTimePicker(
                                                context,
                                                showTitleActions: true,
                                                onChanged: (date) {
                                              print('change $date');
                                            }, onConfirm: (date) {
                                              print('confirm $date');

                                              setState(() {
                                                selectedDate = DateFormat(
                                                        'yyyy-MM-dd HH:mm')
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white70
                                                  .withOpacity(0.5),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Checkbox(
                                          value: isRoundTrip,
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              isRoundTrip = newValue!;
                                              if (isRoundTrip) {
                                                isOneWay = false;
                                              }
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
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                              isOneWay = newValue!;
                                              if (isOneWay) {
                                                isRoundTrip = false;
                                              }
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
                                            borderRadius:
                                                BorderRadius.circular(10),
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
