import 'package:campride/Constants.dart';
import 'package:campride/chat_rooms.dart';
import 'package:campride/main_list.dart';
import 'package:campride/mypage.dart';
import 'package:campride/secure_storage.dart';
import 'package:campride/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

import 'community.dart';
import 'env_config.dart';
import 'firebase_options.dart';
import 'login.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(  options: DefaultFirebaseOptions.currentPlatform,
  );

  Constants.setEnvironment(Environment.PROD);
  await ScreenUtil.ensureScreenSize();
  await dotenv.load(fileName: "assets/env/.env");
  var key = dotenv.env['APP_KEY'];
  await EnvConfig().loadEnv();
  final secureStroageService = SecureStroageService();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);






  AuthRepository.initialize(appKey: key!);

  runApp(
    ProviderScope(
      child: DevicePreview(
        // enabled: !kReleaseMode,
        enabled: false,
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
          child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: MaterialApp(
                navigatorKey: navigatorKey,
                home: SplashScreen(
                  secureStroageService: secureStroageService,
                ),
                routes: {
                  '/login': (context) => const LoginPage(),
                  '/main': (context) => const MainPage(),
                  '/chatRooms': (context) => const ChatRoomsPage(),
                }),
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

  final List<Widget> _widgetOptions = <Widget>[
    const ChatRoomsPage(),
    const CampRiderPage(),
    const CommunityPage(),
    const MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        selectedItemColor: const Color(0xFF365B51),
        unselectedItemColor: Colors.black54,
        onTap: _onItemTapped,
      ),
    );
  }
}
