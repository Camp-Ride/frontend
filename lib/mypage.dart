import 'dart:async';
import 'dart:convert';
import 'package:campride/login.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  TextEditingController _controller = TextEditingController();
  bool _isEditing = false;
  String _nickname = "User5555";
  String _token = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJrYWthb18zNjExMjc3OTcyIiwiYXV0aCI6IlJPTEVfVVNFUiIsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3MjEwNTIzMzksImV4cCI6MTcyMTA1NDEzOX0.Pw6nk_VNI3LFLwwEgNtUM42jXt0ajDUhdGRrmg0OVO4";
  @override
  void initState() {
    super.initState();
    _controller.text = _nickname;
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Save the nickname and call the API to update it
        _nickname = _controller.text;
        _updateNicknameApi(_nickname);
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _updateNicknameApi(String nickname) async {
    final url = Uri.parse('http://localhost:8080/api/v1/user');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
    final body = jsonEncode({'nickname': nickname});

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("Nickname updated to: $nickname");
      } else {
        print("Failed to update nickname: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "마이페이지",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: new Container(
            decoration: BoxDecoration(
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
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: TextField(
                                        controller: _controller,
                                        enabled: _isEditing,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: _nickname,
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                          enabled: _isEditing,
                                          border: UnderlineInputBorder(),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        icon: Icon(_isEditing
                                            ? Icons.check
                                            : Icons.edit),
                                        onPressed: _toggleEdit,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        " 환영합니다!",
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                  ],
                                ),
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
                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: null,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "공지사항",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                elevation:
                                    MaterialStateProperty.all(0), // 그림자 없애기
                              ),
                            )),
                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: null,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "자주 묻는 질문",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                elevation:
                                    MaterialStateProperty.all(0), // 그림자 없애기
                              ),
                            )),
                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: null,
                              child: Row(
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
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                elevation:
                                    MaterialStateProperty.all(0), // 그림자 없애기
                              ),
                            )),
                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: null,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "알림 설정",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                  )
                                ],
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                elevation:
                                    MaterialStateProperty.all(0), // 그림자 없애기
                              ),
                            )),
                        SizedBox(
                            width: screenWidth,
                            child: ElevatedButton(
                              onPressed: null,
                              child: Row(
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
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                elevation:
                                    MaterialStateProperty.all(0), // 그림자 없애기
                              ),
                            ))
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
