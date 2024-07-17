import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/login.dart';
import 'package:campride/post.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'comment.dart';
import 'env_config.dart';
import 'image_detail.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  // List<Comment> comments = [
  //   Comment(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     comment:
  //         "08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?08/11일 상록 예비군 출발하실 분 있나요?",
  //     likeCount: 25,
  //   ),
  //   Comment(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     comment: "08/11일 상록 예비군 출발하실 분 있나요?",
  //     likeCount: 12,
  //   ),
  //   Comment(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     comment: "08/11일 상록 예비군 출발하실 분 있나요?",
  //     likeCount: 12,
  //   ),
  //   Comment(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     comment: "08/11일 상록 예비군 출발하실 분 있나요?",
  //     likeCount: 12,
  //   ),
  //   Comment(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     comment: "08/11일 상록 예비군 출발하실 분 있나요?",
  //     likeCount: 12,
  //   ),
  // ];

  String jwt ="";
  late Future<List<Comment>> futureComments;
  String comment = "";
  late TextEditingController _controller;
  String currentNickname = "";

  Future<void> getUserInfo() async {
    String? nickname = await SecureStroageService.readNickname();
    String? token = await SecureStroageService.readAccessToken();
    setState(() {
      currentNickname = nickname!;
      jwt = token!;
    });

    print(currentNickname);
    print(jwt);
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    futureComments = fetchComments(widget.post.id);
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Comment>> fetchComments(int postId) async {
    jwt = (await SecureStroageService.readAccessToken())!;
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/v1/post/$postId'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> commentsJson = data['commentResponses'];
      return commentsJson
          .map((json) => Comment.fromJson(json, currentNickname))
          .toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> postComment(int postId, String content) async {
    jwt = (await SecureStroageService.readAccessToken())!;
    final url = Uri.parse('http://localhost:8080/api/v1/comment');
    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'postId': postId,
      'content': content,
    });

    print(postId);
    print(content);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Comment posted successfully');
      setState(() {
        futureComments = fetchComments(widget.post.id);
        comment = "";
        widget.post.commentCount++;
      });
    } else {
      print('Failed to post comment: ${response.statusCode}');
    }
  }

  Future<void> like(int id, String type, Post post) async {
    jwt = (await SecureStroageService.readAccessToken())!;
    final url = Uri.parse('http://localhost:8080/api/v1/like/$id');
    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'likeType': type,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Post liked successfully');

      setState(() {
        post.isLiked = true;
        post.likeCount += 1;
      });
    } else {
      print('Failed to like post: ${response.statusCode}');
    }
  }

  Future<void> unLike(int id, String type, Post post) async {
    jwt = (await SecureStroageService.readAccessToken())!;
    final url = Uri.parse('http://localhost:8080/api/v1/unlike/$id');
    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'likeType': type,
    });

    final request = http.Request('DELETE', url)
      ..headers.addAll(headers)
      ..body = body;

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Post unliked successfully');
      setState(() {
        post.isLiked = false;
        post.likeCount -= 1;
      });
    } else {
      print('Failed to unlike post: ${response.statusCode}');
    }
  }

  Future<void> likeComment(Comment comment, String type) async {
    jwt = (await SecureStroageService.readAccessToken())!;
    int id = comment.id;
    final url = Uri.parse('http://localhost:8080/api/v1/like/$id');
    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'likeType': type,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Post liked successfully');

      setState(() {
        comment.isLiked = true;
        comment.likeCount += 1;
      });
    } else {
      print('Failed to like post: ${response.statusCode}');
    }
  }

  Future<void> unLikeComment(Comment comment, String type) async {
    jwt = (await SecureStroageService.readAccessToken())!;
    int id = comment.id;
    final url = Uri.parse('http://localhost:8080/api/v1/unlike/$id');
    final headers = {
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'likeType': type,
    });

    final request = http.Request('DELETE', url)
      ..headers.addAll(headers)
      ..body = body;

    final response = await request.send();

    if (response.statusCode == 200) {
      print('Post unliked successfully');
      setState(() {
        comment.isLiked = false;
        comment.likeCount -= 1;
      });
    } else {
      print('Failed to unlike post: ${response.statusCode}');
    }
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
                              Container(
                                height: 100.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.post.images.length,
                                  itemBuilder:
                                      (BuildContext context, int imgIndex) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 8.0.w),
                                      child: GestureDetector(
                                        onTap: () {
                                          navigatorKey.currentState?.push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageDetailPage(
                                                        imageUrl:
                                                            ('${EnvConfig().s3Url}' +
                                                                widget.post
                                                                        .images[
                                                                    imgIndex]),
                                                      )));
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10).r,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: ('${EnvConfig().s3Url}' +
                                                widget.post.images[imgIndex]),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 5.h),
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
                                          child: InkWell(
                                            onTap: () {
                                              if (widget.post.isLiked) {
                                                unLike(widget.post.id, "POST",
                                                    widget.post);
                                              } else {
                                                like(widget.post.id, "POST",
                                                    widget.post);
                                              }
                                            },
                                            child: Icon(
                                                widget.post.isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.red),
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
                    FutureBuilder<List<Comment>>(
                      future: futureComments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(
                            '작성된 댓글이 없습니다.',
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.black54),
                          ));
                        } else {
                          List<Comment> comments = snapshot.data!;
                          return ListView.builder(
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
                                    padding: const EdgeInsets.only(
                                            left: 8.0, top: 8.0)
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
                                            ),
                                          ],
                                        ),
                                        Text(
                                          comments[index].comment,
                                          style: TextStyle(
                                            height: 16 / 11,
                                            fontSize: 13.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                              right: 5.0)
                                                          .w,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (comments[index]
                                                          .isLiked) {
                                                        unLikeComment(
                                                            comments[index],
                                                            "COMMENT");
                                                      } else {
                                                        likeComment(
                                                            comments[index],
                                                            "COMMENT");
                                                      }
                                                    },
                                                    child: Icon(
                                                      comments[index].isLiked
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: Colors.red,
                                                      size: 14.r,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  comments[index]
                                                      .likeCount
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                      left: 8.0)
                                                  .w,
                                              child: Text(
                                                comments[index].date,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
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
                        controller: _controller,
                        style: TextStyle(color: Colors.white),
                        onChanged: (text) {
                          setState(() {
                            comment = text;
                          });
                        },
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
                        _controller.clear();
                        postComment(widget.post.id, comment);
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
