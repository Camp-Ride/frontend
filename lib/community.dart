import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/env_config.dart';
import 'package:campride/login.dart';
import 'package:campride/post.dart';
import 'package:campride/post_detail.dart';
import 'package:campride/posting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<File> images = [];
  String jwt =
      "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJrYWthb18zNjExMjc3OTcyIiwiYXV0aCI6IlJPTEVfVVNFUiIsInR5cGUiOiJhY2Nlc3MiLCJpYXQiOjE3MjExNTI3OTEsImV4cCI6MTcyMTE1NDU5MX0.RkoV65zLXTDqJqnIItNvx29otJSkdlpvV8qOKrImL4k";
  String currentNickname = "김준형9560";

  // List<Post> posts = [
  //   Post(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     title: "08/11일 상록 예비군 출발하실 분 있나요?",
  //     contents:
  //         "상록수역에 여기로 와주세요상록수역에 모여서 상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요상록수역에 모여서 출발해요 여기로 와주세요",
  //     commentCount: 5,
  //     likeCount: 0,
  //     images: [
  //       'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RSohHNTfiYSSSIIg4yk%2Fe61243619b73dfcced018a0362a6132e9000e6f8%E1%84%8C%E1%85%A6%E1%84%86%E1%85%A9%E1%86%A8_%E1%84%8B%E1%85%A5%E1%86%B9%E1%84%82%E1%85%B3%E1%86%AB_%E1%84%8B%E1%85%A1%E1%84%90%E1%85%B3%E1%84%8B%E1%85%AF%E1%84%8F%E1%85%B3%202%201.png?alt=media&token=c873dda4-fdbb-41e0-9e14-0302ff6e4521',
  //       "https://via.placeholder.com/200",
  //       "https://via.placeholder.com/250",
  //     ],
  //   ),
  //   Post(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     title: "예비군복 어디서 빌리는지 아시는 분 계세요?",
  //     contents:
  //         "예비군복이 없는데 빌려야하는데 어떻게 해야할지 모르겠어요예비군복이 없는데 빌려야하는 어떻게 해야할지 모르겠어요예비군복이 없는데 빌려야하는데 어떻게 해야할지 모르겠어요",
  //     commentCount: 5,
  //     likeCount: 0,
  //     images: [],
  //   ),
  //   Post(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     title: "끝나고 같이 버스 타고 걸어가자",
  //     contents: "안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요",
  //     commentCount: 5,
  //     likeCount: 190,
  //     images: [
  //       'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RSohHNTfiYSSSIIg4yk%2Fb28a79dab4363dd4ab15f5cc05af1602c5de3b49507f6217ecb1355d4042624fa2f7e5f0-removebg-preview%201.png?alt=media&token=fb86246f-b478-4333-bc88-b9e145ff23ea',
  //     ],
  //   ),
  //   Post(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     title: "끝나고 같이 버스 타고 걸어가자",
  //     contents: "안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요",
  //     commentCount: 5,
  //     likeCount: 190,
  //     images: [
  //       'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0RSohHNTfiYSSSIIg4yk%2F32173d2313520f135a7405471b998dfbdc9ee611507f6217ecb1355d4042624fa2f7e5f0-removebg-preview%201.png?alt=media&token=340a77cf-453f-4b92-90bf-221f8c0140f1',
  //     ],
  //   ),
  //   Post(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     title: "끝나고 같이 버스 타고 걸어가자",
  //     contents: "안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요",
  //     commentCount: 5,
  //     likeCount: 190,
  //     images: [],
  //   ),
  //   Post(
  //     id: 1,
  //     name: "준행행님",
  //     date: "2024/7/25",
  //     title: "끝나고 같이 버스 타고 걸어가자",
  //     contents: "안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요안녕하세요요요 안녕하세요요요안녕하세요요요안녕하세요요요",
  //     commentCount: 5,
  //     likeCount: 190,
  //     images: [],
  //   )
  // ];

  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/v1/post/paging?page=0&size=13'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> content = data['content'];

      return content
          .map((json) => Post.fromJson(json, currentNickname))
          .toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> like(int id, String type, Post post) async {
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "커뮤니티",
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
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: Colors.green, width: 3.0),
                      insets: EdgeInsets.symmetric(
                          horizontal: 30.0.w), // 밑줄 길이를 늘리기 위한 인셋 조정
                    ),
                    tabAlignment: TabAlignment.start,
                    indicatorPadding: EdgeInsets.zero,
                    isScrollable: true,
                    tabs: [
                      Tab(text: '최근'),
                      Tab(text: '인기'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: TabBarView(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<Post>>(
                              future: futurePosts,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(child: Text('작성된 글이 없습니다.'));
                                } else {
                                  List<Post> posts = snapshot.data!;
                                  return ListView.builder(
                                    itemCount: posts.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PostDetailPage(
                                                      post: posts[index]),
                                            ),
                                          ),
                                        },
                                        child: Container(
                                          height: 150.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.black54,
                                                width: 0.5,
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
                                                Text(
                                                  posts[index].name,
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.black54),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    style: TextStyle(
                                                        fontSize: 15.sp),
                                                    posts[index].title,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          style: TextStyle(
                                                            height: 16 / 11,
                                                            fontSize: 13.sp,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          posts[index].contents,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Container(
                                                        width: 65.w,
                                                        height: 65.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: posts[index]
                                                                  .images
                                                                  .isEmpty
                                                              ? Colors
                                                                  .transparent
                                                              : Colors.black12,
                                                          borderRadius:
                                                              BorderRadius
                                                                      .circular(
                                                                          10)
                                                                  .r,
                                                        ),
                                                        child:
                                                            posts[index]
                                                                    .images
                                                                    .isNotEmpty
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(10)
                                                                            .r,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      imageUrl:
                                                                          ('${EnvConfig().s3Url}' +
                                                                              posts[index].images[0]),
                                                                      progressIndicatorBuilder: (context,
                                                                              url,
                                                                              downloadProgress) =>
                                                                          CircularProgressIndicator(
                                                                              value: downloadProgress.progress),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          const Icon(
                                                                              Icons.error),
                                                                    ),
                                                                  )
                                                                : null,
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5.0)
                                                                    .w,
                                                            child: Icon(
                                                                Icons.comment),
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: Colors
                                                                  .black54,
                                                            ),
                                                            posts[index]
                                                                .commentCount
                                                                .toString(),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                    left: 8.0)
                                                                .w,
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              5.0)
                                                                      .w,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  if (posts[
                                                                          index]
                                                                      .isLiked) {
                                                                    unLike(
                                                                        posts[index]
                                                                            .id,
                                                                        "POST",
                                                                        posts[
                                                                            index]);
                                                                  } else {
                                                                    like(
                                                                        posts[index]
                                                                            .id,
                                                                        "POST",
                                                                        posts[
                                                                            index]);
                                                                  }
                                                                },
                                                                child: Icon(
                                                                    posts[index]
                                                                            .isLiked
                                                                        ? Icons
                                                                            .favorite
                                                                        : Icons
                                                                            .favorite_border,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              posts[index]
                                                                  .likeCount
                                                                  .toString(),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                    left: 8.0)
                                                                .w,
                                                        child: Text(
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          posts[index].date,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                          )
                        ],
                      ),
                      Column(
                        children: [Text("인기 콘텐츠")],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          child: SizedBox(
            width: 95.w,
            height: 40.h,
            child: FloatingActionButton(
              backgroundColor: Color(0xff154236),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PostingPage()));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0).r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "글쓰기",
                      style: TextStyle(fontSize: 15.sp, color: Colors.white),
                    ),
                    Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
