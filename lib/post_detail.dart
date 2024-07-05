import 'dart:async';
import 'package:campride/login.dart';
import 'package:campride/post.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'comment.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<Comment> comments = [
    Comment(
      id: 1,
      name: "준행행님",
      date: "2024/7/25",
      comment:
          "08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?",
      likeCount: 25,
    ),
    Comment(
      id: 1,
      name: "준행행님",
      date: "2024/7/25",
      comment: "08/11일 상록 예비군 출발하실 분 있나요?",
      likeCount: 12,
    ),
    Comment(
      id: 1,
      name: "준행행님",
      date: "2024/7/25",
      comment: "08/11일 상록 예비군 출발하실 분 있나요?",
      likeCount: 12,
    ),
    Comment(
      id: 1,
      name: "준행행님",
      date: "2024/7/25",
      comment: "08/11일 상록 예비군 출발하실 분 있나요?",
      likeCount: 12,
    ),
    Comment(
      id: 1,
      name: "준행행님",
      date: "2024/7/25",
      comment: "08/11일 상록 예비군 출발하실 분 있나요?",
      likeCount: 12,
    ),
  ];

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
        backgroundColor: Colors.white,
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
            "글 상세",
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF355A50), Color(0xFF154135)],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0).r,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black54, // 밑부분 테두리 색상
                              width: 0.5, // 밑부분 테두리 두께
                            ),
                          ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.post.name,
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.black54),
                                  ),
                                  Icon(
                                    Icons.more_vert,
                                    size: 15.r,
                                  )
                                ],
                              ),
                              Text(
                                widget.post.title,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Text(
                                  style: TextStyle(
                                      height: 16 / 11,
                                      fontSize: 13.sp,
                                      color: Colors.black),
                                  widget.post.contents),
                              SizedBox(
                                height: 10.h,
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5.0).w,
                                        child: Icon(Icons.comment),
                                      ),
                                      Text(
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.black54),
                                          widget.post.commentCount.toString()),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0).w,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0)
                                                  .w,
                                          child: Icon(
                                            Icons.favorite_border,
                                          ),
                                        ),
                                        Text(
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.black54),
                                            widget.post.likeCount.toString()),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0).w,
                                    child: Text(
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.black54),
                                        widget.post.date),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (BuildContext context, int index) {
                          return IntrinsicHeight(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black54, // 밑부분 테두리 색상
                                    width: 0.5, // 밑부분 테두리 두께
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0)
                                        .r,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            comments[index].name,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.black54),
                                          ),
                                          Icon(
                                            Icons.more_vert,
                                            size: 15.r,
                                          )
                                        ],
                                      ),
                                      Text(
                                          style: TextStyle(
                                              height: 16 / 11,
                                              fontSize: 13.sp,
                                              color: Colors.black),
                                          comments[index].comment),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                        right: 5.0)
                                                    .w,
                                                child: Icon(
                                                  Icons.favorite_border,
                                                  size: 14.r,
                                                ),
                                              ),
                                              Text(
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.black54),
                                                  comments[index]
                                                      .likeCount
                                                      .toString()),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8.0)
                                                    .w,
                                            child: Text(
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.black54),
                                                comments[index].date),
                                          ),
                                        ],
                                      )
                                    ]),
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0).r,
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFF355A50),
                    borderRadius: BorderRadius.circular(12).r),
                height: 50.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: '댓글을 입력하세요.',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 13.sp),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.white),
                      onPressed: () {
                        // 댓글 전송 버튼의 동작
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: null,
      ),
    );
  }
}
