import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:campride/secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'Constants.dart';
import 'env_config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _asyncMethod() async {
    if (await SecureStroageService.readRefreshToken() != null) {
      print(await SecureStroageService.readAccessToken());

      if (!mounted) return;

      String? isNicknameUpdated =
          await SecureStroageService.readIsNicknameUpdated();

      print(isNicknameUpdated);

      if (isNicknameUpdated == "false" || isNicknameUpdated == null) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/nickname', (route) => false);
      } else {
        await Navigator.pushNamedAndRemoveUntil(
            context, '/main', (route) => false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _asyncMethod();
  }

  Future<void> saveUserNicknameAndUserIdFromToken(String accessToken) async {
    final url = Uri.parse(Constants.API + '/api/v1/user');
    print("first");
    print(accessToken);
    print(Constants.API + '/api/v1/user');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      print(data);

      await SecureStroageService.saveUserId(data['userId']);
      await SecureStroageService.saveNickname(data['nickname']);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<void> _extractAndSaveTokens(String url) async {
    Uri uri = Uri.parse(url);
    String? accessToken = uri.queryParameters['accesstoken'];
    String? refreshToken = uri.queryParameters['refreshtoken'];

    if (accessToken != null && refreshToken != null) {
      await SecureStroageService.saveTokens(accessToken, refreshToken);
      await saveUserNicknameAndUserIdFromToken(accessToken);

      String? nickname = await SecureStroageService.readNickname();
      String? userId = await SecureStroageService.readUserId();

      print('Access Token: $accessToken');
      print('Refresh Token: $refreshToken');
      print('nickname: $nickname');
      print('userId: $userId');
    }
  }

  _extractIsNicknameUpdated(String result) {
    Uri uri = Uri.parse(result);
    String? isNicknameUpdated = uri.queryParameters['isNicknameUpdated'];
    SecureStroageService.saveIsNicknameUpdated(isNicknameUpdated);
    print(isNicknameUpdated);
  }

  Future<void> signIn(provider) async {
    final token = await FirebaseMessaging.instance.getToken();

    print("device token is " + token!);

    final prodUrl =
        Uri.parse('${EnvConfig().prodUrl}/oauth2/authorization/$provider');

    final localUrl = Uri.parse(
        Constants.API + '/api/v1/login?provider=$provider&deviceToken=$token');

    // final localUrl = Uri.parse(
    //     "http://localhost:8080/api/v1/login?provider=kakao&deviceToken=aacacca");

    late String status;

    print(localUrl);

    try {
      final result = await FlutterWebAuth.authenticate(
          url: localUrl.toString(), callbackUrlScheme: "campride");

      print("callback result : $result");

      print(await SecureStroageService.readRefreshToken());
      print(await SecureStroageService.readAccessToken());

      setState(() {
        status = 'Got result: $result';
      });

      await _extractAndSaveTokens(result);
      await _extractIsNicknameUpdated(result);

      String? isNicknameUpdated =
          await SecureStroageService.readIsNicknameUpdated();

      print(isNicknameUpdated);

      if (isNicknameUpdated == "false" || isNicknameUpdated == null) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/nickname', (route) => false);
      } else {
        await Navigator.pushNamedAndRemoveUntil(
            context, '/main', (route) => false);
      }
    } catch (e) {
      setState(() {
        status = 'Got error: $e';
      });
      print(status);
    }
  }

  Future<void> appleLogin(String? identityToken) async {
    try {
      // 1. 디바이스 토큰 가져오기
      final deviceToken = await FirebaseMessaging.instance.getToken();

      // 2. API 요청 준비
      final url = Uri.parse('${Constants.API}/api/v1/login/apple');

      print(url);
      var request = http.Request('GET', url);
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode({
        "identityToken": identityToken,
        "deviceToken": deviceToken,
      });

      // 3. API 요청 보내기
      http.StreamedResponse response = await request.send();

      print(identityToken);
      print(deviceToken);
      print(request);

      // 4. 응답 처리
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');
        final result = json.decode(responseBody);

        // 5. 토큰 추출 및 저장
        final accessToken = result['accessToken'];
        final refreshToken = result['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await SecureStroageService.saveTokens(accessToken, refreshToken);
          await saveUserNicknameAndUserIdFromToken(accessToken);
        } else {
          throw Exception(
              'Access token or refresh token is missing from the response');
        }

        // 6. 닉네임 업데이트 상태 확인 및 저장
        final isNicknameUpdated = result['isNicknameUpdated'] ?? false;
        await SecureStroageService.saveIsNicknameUpdated(
            isNicknameUpdated.toString());

        // 7. 네비게이션 처리
        if (!isNicknameUpdated) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/nickname', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        }
      } else {
        throw HttpException('Failed to login: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 에러 처리
      print('Login error: $e');
    }
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
                        const Text(
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
                          width: 200,
                          child: IconButton(
                              onPressed: () => {signIn("google")},
                              icon: Image.asset("assets/images/google.png")),
                        ),
                        SizedBox(
                          width: 200,
                          child: IconButton(
                              onPressed: () async {
                                final credential =
                                    await SignInWithApple.getAppleIDCredential(
                                  scopes: [
                                    AppleIDAuthorizationScopes.email,
                                    AppleIDAuthorizationScopes.fullName,
                                  ],
                                );

                                await appleLogin(credential.identityToken);
                              },
                              icon: Image.asset("assets/images/apple.png")),
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
                      Text("이용약관", style: TextStyle(fontSize: 12)),
                      SizedBox(
                        width: 20.w,
                      ),
                      Text("개인정보처리방침", style: TextStyle(fontSize: 12))
                    ],
                  )),
              Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Copyright © 2024 Camp Ride. All rights reserved.",
                        style: TextStyle(fontSize: 12),
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
