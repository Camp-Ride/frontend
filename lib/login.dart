import 'dart:async';
import 'dart:convert';
import 'package:campride/secure_storage.dart';
import 'package:chatview/chatview.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'env_config.dart';

class LoginPage extends StatefulWidget {
  final SecureStroageService secureStroageService;

  const LoginPage({super.key, required this.secureStroageService});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<String> getUserNicknameFromToken(String accessToken) async {
    final url = Uri.parse('http://localhost:8080/api/v1/user');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return data['nickname'];
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<void> _extractAndSaveTokens(String url) async {
    Uri uri = Uri.parse(url);
    String? accessToken = uri.queryParameters['accesstoken'];
    String? refreshToken = uri.queryParameters['refreshtoken'];

    if (accessToken != null && refreshToken != null) {
      await widget.secureStroageService.saveTokens(accessToken, refreshToken);
      await widget.secureStroageService
          .saveNickname(await getUserNicknameFromToken(accessToken));

      String? nickname = await widget.secureStroageService.readNickname();

      print('Access Token: $accessToken');
      print('Refresh Token: $refreshToken');
      print('nickname: $nickname');
    }
  }

  Future<void> signIn(provider) async {
    final prod_url = Uri.parse(
        '${await EnvConfig().prodUrl}/oauth2/authorization/$provider');

    final local_url =
        Uri.parse('http://localhost:8080/oauth2/authorization/$provider');
    late String _status;

    print(local_url);

    try {
      final result = await FlutterWebAuth.authenticate(
          url: local_url.toString(), callbackUrlScheme: "campride");

      print("callback result : " + result);

      setState(() {
        _status = 'Got result: $result';
      });

      _extractAndSaveTokens(result);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainPage()));
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
                              onPressed: () => {signIn("naver")},
                              icon: Image.asset("assets/images/naver.png")),
                        ),
                        SizedBox(
                          width: 200.w,
                          child: IconButton(
                              // onPressed: () => {signIn("google")},
                              onPressed: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MainPage()))
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
