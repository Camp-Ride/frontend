import 'dart:convert';

import 'package:campride/chat_rooms.dart';
import 'package:campride/main_list.dart';
import 'package:campride/mypage.dart';
import 'package:campride/room.dart';
import 'package:campride/secure_storage.dart';
import 'package:campride/splash.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:daum_postcode_view/daum_postcode_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

import 'community.dart';
import 'env_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await ScreenUtil.ensureScreenSize();
  await dotenv.load(fileName: "assets/env/.env");
  var key = await dotenv.env['APP_KEY'];
  await EnvConfig().loadEnv();
  final secureStroageService = SecureStroageService();

  AuthRepository.initialize(appKey: key!);

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => MyApp(secureStroageService), // Wrap your app
      ),
    ),
  );
  // runApp(MyApp());
}

class MyApp extends ConsumerWidget {
  final SecureStroageService secureStroageService;

  const MyApp(this.secureStroageService, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ProviderScope(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: SplashScreen(
              secureStroageService: secureStroageService,
            ),
          ),
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

  List<Widget> _widgetOptions = <Widget>[
    ChatRoomsPage(),
    CampRiderPage(),
    CommunityPage(),
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
      title: "상록 예비군 출발하실 분 구해요",
      rideType: "왕복",
      departureLocation: "서울 특별시 관악구 신림동 1547-10 101호 천국",
      arrivalLocation: "경기도 안산시 상록구 304동 4003호 121212121222",
      currentParticipants: 4,
      maxParticipants: 4,
      unreadMessages: 129,
      createdAt: "2024-07-25");

  var selectedTitle = "";

  var selectedDate = "";

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

  bool isRoundTrip = true;
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF365B51),
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
}
