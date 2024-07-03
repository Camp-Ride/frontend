import 'dart:async';
import 'package:campride/login.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({super.key});

  @override
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
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
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "글 쓰기",
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
          children: [
            Container(
              height: 50.h,
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      hintText: '제목을 입력해 주세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                color: Colors.white,
                child: TextField(
                  maxLines: null,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                      hintText: '내용을 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none),
                ),
              ),
            ),
            Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black54,
                      ),
                      bottom: BorderSide(
                        color: Colors.black54,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.w,
                            ),
                            Container(
                              width: 85.w,
                              height: 85.h,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Container(
                              width: 85.w,
                              height: 85.h,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Container(
                              width: 85.w,
                              height: 85.h,
                              color: Colors.orange,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black54,
                    ),
                  ),
                  color: Colors.white,
                ),
                height: 50.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                        ),
                        Icon(Icons.camera_alt_outlined),
                        SizedBox(
                          width: 10.w,
                        ),
                        Icon(Icons.image_outlined)
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 25.h,
                          decoration: BoxDecoration(
                              color: Color(0xFF154135),
                              borderRadius: BorderRadius.circular(20).r),
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              "완료",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        floatingActionButton: null,
      ),
    );
  }
}
