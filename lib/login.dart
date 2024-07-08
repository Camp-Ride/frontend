import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => const MyHomePage(
    //               title: "hello",
    //             )),
    //   );
    // });
  }


  Future<void> signIn(provider) async {
    // final url = Uri.parse('http://localhost:8080/oauth2/authorize/google');
    // final url =
    //     Uri.parse('http://localhost:8080/oauth2/authorize/$APP_REDIRECT_URI');
    final url = Uri.parse('http://localhost:8080/oauth2/authorization/$provider');
    late String _status;

    print(url.toString());

    try {
      final result = await FlutterWebAuth.authenticate(
          url: url.toString(), callbackUrlScheme: "campride");

      print("callback result : " + result);

      // // 백엔드에서 redirect한 callback 데이터 파싱
      // final accessToken = Uri.parse(result).queryParameters['access-token'];
      // final refreshToken = Uri.parse(result).queryParameters['refresh-token'];

      // print(accessToken);
      // print(refreshToken);

      setState(() {
        _status = 'Got result: $result';
      });
      print(_status);
    } catch (e) {
      setState(() {
        _status = 'Got error: $e';
      });
      print(_status);
    }

    // . . .
    // FlutterSecureStorage 또는 SharedPreferences 를 통한
    // Token 저장 및 관리
    // . . .
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.white,
                )),
            Expanded(
                flex: 10,
                child: DefaultTextStyle(
                  style: GoogleFonts.getFont(
                    'ABeeZee',
                    color: Colors.black,
                    fontSize: 35.sp,
                    height: 1.5,
                  ),
                  child: Container(
                    width: screenWidth,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CAMPRIDE",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 40.h,
                        ),
                        SizedBox(
                          width: 200.w,
                          child: IconButton(
                              onPressed: () => {
                              signIn("kakao")

                              // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => MainPage()))
                                  },
                              icon: Image.asset("assets/images/kakao.png")),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: IconButton(
                              onPressed: () => {                              signIn("naver")
                              },
                              icon: Image.asset("assets/images/naver.png")),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: IconButton(
                              onPressed: () => {                              signIn("google")
                              },
                              icon: Image.asset("assets/images/google.png")),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("이용약관", style: TextStyle(fontSize: 12.sp)),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text("개인정보처리방침", style: TextStyle(fontSize: 12.sp))
                    ],
                  )),
              Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Copyright © 2024 Camp Ride. All rights reserved.",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
