import 'dart:async';
import 'package:campride/login.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
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
                              Row(
                                children: [
                                  Text(
                                    "준행행님님",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp),
                                  ),
                                  Text(
                                    " 환영합니다!",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ],
                              ),
                              Text(
                                "CAMPRIDE",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
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
