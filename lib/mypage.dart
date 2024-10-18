import 'dart:async';
import 'dart:convert';
import 'package:campride/auth_dio.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'Constants.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isNotificationEnabled = false;

  bool _isEditing = false;
  String _nickname = "";
  String _token = "";
  final String privacyPolicyUrl =
      'https://plip.kr/pcc/2f21868a-ec36-4ca8-8be9-dfb265843338/privacy/1.html';
  final String termsAndConditionsUrl =
      'https://relic-baboon-412.notion.site/11f766a8bb4680868878f35fcda207fc?pvs=4';

  final TextEditingController _controller = TextEditingController();

  Future<void> deleteUser() async {
    var dio = await authDio(context);

    dio.delete('/user').then((response) {
      if (response.statusCode == 200) {
        print("User deleted");
      } else {
        print("Failed to delete user: ${response.statusCode}");
      }
    }).catchError((e) {
      print("Error: $e");
    });
  }

  Future<void> _loadNotificationSettings() async {
    String? pushPermission = await SecureStroageService.readPushPermission();
    setState(() {
      _isNotificationEnabled = pushPermission == 'true';
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> saveUserNicknameAndUserIdFromToken(String accessToken) async {
    final url = Uri.parse(Constants.API + '/api/v1/user');
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

  Future<void> getUserInfo() async {
    String? token = await SecureStroageService.readAccessToken();
    await saveUserNicknameAndUserIdFromToken(token!);
    String? nickname = await SecureStroageService.readNickname();

    print(nickname);
    print(token);

    setState(() {
      _nickname = nickname!;
      _token = token!;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    _controller.text = _nickname;
    _loadNotificationSettings();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Save the nickname and call the API to update it

        if (_controller.text != "") {
          _nickname = _controller.text;
          print("Nickname: $_nickname");
          _updateNicknameApi(_nickname);
        }
      }
      _isEditing = !_isEditing;

      print("Nickname: $_nickname");
    });
  }

  Future<void> _updateNicknameApi(String nickname) async {
    var dio = await authDio(context);

    dio.put('/user', data: {'nickname': nickname}).then((response) {
      if (response.statusCode == 200) {
        SecureStroageService.saveNickname(nickname);
        print("Nickname updated to: $nickname");
      } else {
        print("Failed to update nickname: ${response.statusCode}");
      }
    }).catchError((e) {
      print("Error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    String tempNickname = _nickname;

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "마이페이지",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF355A50), Color(0xFF154135)],
              ),
            ),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                            top: 20.0, left: 20.0, right: 20.0)
                        .r,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _nickname + "님",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                            color: Colors.black),
                                      ),
                                      Text(
                                        " 환영합니다!",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Text(
                                "CAMPRIDE",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Flexible(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only().r,
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth,
                          height: 0.5.h,
                          color: Colors.black54,
                        ),
                        // SizedBox(
                        //     width: screenWidth,
                        //     child: ElevatedButton(
                        //       onPressed: null,
                        //       style: ButtonStyle(
                        //         backgroundColor:
                        //             WidgetStateProperty.all(Colors.transparent),
                        //         elevation:
                        //             WidgetStateProperty.all(0), // 그림자 없애기
                        //       ),
                        //       child: const Row(
                        //         mainAxisAlignment:
                        //             MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Text(
                        //             "공지사항",
                        //             style: TextStyle(color: Colors.black),
                        //           ),
                        //           Icon(
                        //             Icons.arrow_forward_ios,
                        //             color: Colors.black54,
                        //           )
                        //         ],
                        //       ),
                        //     )),

                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("문의하기"),
                                      content: Text("ggprgrkjh2@gmail.com"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            _toggleEdit();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("닫기"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                elevation:
                                    WidgetStateProperty.all(0), // 그림자 없애기
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "문의하기",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                            )),

                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _launchUrl(termsAndConditionsUrl);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                elevation:
                                    WidgetStateProperty.all(0), // 그림자 없애기
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "서비스 이용약관",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                            )),
                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _launchUrl(privacyPolicyUrl);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                elevation:
                                    WidgetStateProperty.all(0), // 그림자 없애기
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "개인정보처리방침",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                            )),
                        // SizedBox(
                        //   width: screenWidth,
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       // 버튼 전체를 눌렀을 때의 동작을 여기에 추가할 수 있습니다.
                        //     },
                        //     style: ButtonStyle(
                        //       backgroundColor:
                        //           MaterialStateProperty.all(Colors.transparent),
                        //       elevation: MaterialStateProperty.all(0),
                        //       padding: MaterialStateProperty.all(
                        //           EdgeInsets.symmetric(
                        //               horizontal: 16, vertical: 8)),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Padding(
                        //           padding: const EdgeInsets.only(left: 8.5).w,
                        //           child: Text(
                        //             "알림 설정",
                        //             style: TextStyle(color: Colors.black),
                        //           ),
                        //         ),
                        //         Row(
                        //           children: [
                        //             Switch(
                        //               value: _isNotificationEnabled,
                        //               onChanged: (bool value) {
                        //                 setState(() {
                        //                   _isNotificationEnabled = value;
                        //                 });
                        //                 SecureStroageService.savePushPermission(
                        //                     value.toString());
                        //                 // 여기에 알림 설정 변경에 대한 추가 로직을 넣을 수 있습니다.
                        //               },
                        //               activeColor: Colors.blue, // 활성화되었을 때의 색상
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        InkWell(
                          onTap: () async {
                            final response = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("정말 탈퇴하시겠습니까?"),
                                  content: Text("탈퇴 시 모든 정보가 삭제됩니다."),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("확인"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(true); // Yes 선택 시 true 반환
                                      },
                                    ),
                                    TextButton(
                                      child: Text("취소"),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(false); // No 선택 시 false 반환
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (response == true) {
                              await deleteUser();
                              await SecureStroageService.deleteNickname();
                              await SecureStroageService.deleteTokens();

                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/agreement', (route) => false);
                            }


                          },
                          child: SizedBox(
                              width: screenWidth,
                              child: ElevatedButton(
                                onPressed: null,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  elevation:
                                      WidgetStateProperty.all(0), // 그림자 없애기
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "회원탈퇴",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black54,
                                    )
                                  ],
                                ),
                              )),
                        ),
                        InkWell(
                          onTap: () {
                            SecureStroageService.deleteNickname();
                            SecureStroageService.deleteTokens();
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/agreement', (route) => false);
                          },
                          child: SizedBox(
                              width: screenWidth,
                              child: ElevatedButton(
                                onPressed: null,
                                style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  elevation:
                                      WidgetStateProperty.all(0), // 그림자 없애기
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "로그아웃",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black54,
                                    )
                                  ],
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                )),
          ],
        ),
        floatingActionButton: null,
      ),
    );
  }
}
