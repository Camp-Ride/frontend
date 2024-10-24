import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:campride/community_type.dart';
import 'package:campride/env_config.dart';
import 'package:campride/post.dart';
import 'package:campride/post_detail.dart';
import 'package:campride/post_modify.dart';
import 'package:campride/posting.dart';
import 'package:campride/report_dialog.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'auth_dio.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  List<File> images = [];
  String jwt = "";
  String currentNickname = "";
  String currentUserId = "";
  late Future<List<Post>> futurePosts;

  List<Post> notifications = [
    Post(
      id: 2,
      authorId: 1002,
      name: "운영자",
      date: "2024-10-14",
      title: "자주 묻는 질문",
      contents: "이것은 첫 번째 리스트의 두 번째 게시물입니다.",
      images: ["image2_1.jpg", "image2_2.jpg"],
      commentCount: 0,
      likeCount: 0,
      isLiked: false,
    ),
    // Post(
    //   id: 3,
    //   authorId: 1003,
    //   name: "운영자",
    //   date: "2024-10-15",
    //   title: "예비군 정보",
    //   contents: "https://opendata.mnd.go.kr/openinf/sheetview2.jsp?infId=OA-9465",
    //   images: ["image3_1.jpg", "image3_2.jpg"],
    //   commentCount: 0,
    //   likeCount: 0,
    //   isLiked: false,
    // ),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        print('Selected tab index: ${_tabController.index}');

        setState(() {
          futurePosts = fetchPosts();
        });
      }
    });
  }

  Future<void> blockUser(int authorId) async {

    if (authorId == int.parse(await SecureStroageService.readUserId() as String)) {
      _showFailureDialog(context, '자신을 차단할 수 없습니다.');
      return;
    }

    var dio = await authDio(context);

    dio
        .post('/block',
            data: jsonEncode({
              'targetUserId': authorId,
            }))
        .then((response) {
      print('User blocked successfully');
      setState(() {
        futurePosts = fetchPosts();
      });
    }).catchError((e) {
      print('Failed to block user: ${e.response?.statusCode}');
    });
  }

  Future<void> deletePost(
    int postId,
  ) async {
    var dio = await authDio(context);

    try {
      await dio.delete('/post/$postId');
      setState(() {
        futurePosts = fetchPosts();
      });
      print('Post deleted successfully');
    } on DioError catch (e) {
      print('Failed to delete post: ${e.response?.statusCode}');
    }
  }

  Future<List<Post>> fetchPosts() async {
    currentNickname = (await SecureStroageService.readNickname())!;

    var dio = await authDio(context);

    try {
      final response = await dio.get(
          '/post/paging?page=0&size=10${_tabController.index == 1 ? '&sortType=like' : null}');
      Map<String, dynamic> data = response.data;
      List<dynamic> content = data['content'];

      return content
          .map((json) => Post.fromJson(json, currentNickname))
          .toList();
    } on DioException catch (e) {
      print('Failed to fetch posts: ${e.response?.statusCode}');
      throw new Exception('Failed to fetch posts');
    }
  }

  Future<void> like(int id, String type, Post post) async {
    var dio = await authDio(context);

    dio
        .post('/like/$id',
            data: jsonEncode({
              'likeType': type,
            }))
        .then((response) {
      print('Post liked successfully');
      setState(() {
        post.isLiked = true;
        post.likeCount += 1;
      });
    }).catchError((e) {
      print('Failed to like post: ${e.response?.statusCode}');
    });
  }

  Future<void> unLike(int id, String type, Post post) async {
    var dio = await authDio(context);

    dio
        .delete('/unlike/$id',
            data: jsonEncode({
              'likeType': type,
            }))
        .then((response) {
      print('Post unliked successfully');
      setState(() {
        post.isLiked = false;
        post.likeCount -= 1;
      });
    }).catchError((e) {
      print('Failed to unlike post: ${e.response?.statusCode}');
    });
  }

  void _showFailureDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message, style: TextStyle(fontSize: 15)),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "커뮤니티",
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
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide:
                          const BorderSide(color: Colors.green, width: 3.0),
                      insets: EdgeInsets.symmetric(
                          horizontal: 30.0), // 밑줄 길이를 늘리기 위한 인셋 조정
                    ),
                    tabAlignment: TabAlignment.start,
                    indicatorPadding: EdgeInsets.zero,
                    isScrollable: true,
                    tabs: const [
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
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<List<Post>>(
                              future: futurePosts,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('작성된 글이 없습니다.'));
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
                                          ).then((value) => setState(() {
                                                futurePosts = fetchPosts();
                                              })),
                                        },
                                        child: Container(
                                          height: 150,
                                          decoration: const BoxDecoration(
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
                                                left: 8.0, top: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      posts[index].name,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                    SizedBox(
                                                      width: 30,
                                                      height: 15,
                                                      child:
                                                          PopupMenuButton<int>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        color: Colors.white,
                                                        child: Icon(
                                                            Icons.more_vert,
                                                            size: 20),
                                                        onSelected:
                                                            (value) async {
                                                          switch (value) {
                                                            case 0:
                                                              print(
                                                                  "Edit selected");
                                                              int authorId = int.parse(
                                                                  (await SecureStroageService
                                                                      .readUserId())!);

                                                              if (posts[index]
                                                                      .authorId ==
                                                                  authorId) {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => PostModifyPage(
                                                                            id: posts[index]
                                                                                .id,
                                                                            title: posts[index]
                                                                                .title,
                                                                            contents: posts[index]
                                                                                .contents,
                                                                            imageNames:
                                                                                posts[index].images))).then(
                                                                    (value) =>
                                                                        setState(
                                                                            () {
                                                                          futurePosts =
                                                                              fetchPosts();
                                                                        }));
                                                              } else {
                                                                _showFailureDialog(
                                                                    context,
                                                                    '글쓴이가 아닙니다.');
                                                              }

                                                              break;
                                                            case 1:
                                                              int authorId = int.parse(
                                                                  (await SecureStroageService
                                                                      .readUserId())!);
                                                              if (posts[index]
                                                                      .authorId ==
                                                                  authorId) {
                                                                deletePost(
                                                                    posts[index]
                                                                        .id);
                                                              } else {
                                                                _showFailureDialog(
                                                                    context,
                                                                    "글쓴이가 아닙니다.");
                                                              }
                                                              print(
                                                                  "Delete selected");
                                                              // Handle delete action
                                                              break;
                                                            case 2:
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return ReportDialog(
                                                                      item: posts[
                                                                          index],
                                                                      type: CommunityType
                                                                          .POST);
                                                                },
                                                              );
                                                              print(
                                                                  "Report selected");
                                                              // Handle report action
                                                              break;
                                                            case 3:
                                                              print(
                                                                  "Block selected");

                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        '차단'),
                                                                    content: Text(
                                                                        '해당 사용자를 차단하시겠습니까?'),
                                                                    actions: <Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: Text(
                                                                            '취소'),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(context)
                                                                              .pop();

                                                                          await blockUser(
                                                                              posts[index].authorId);
                                                                        },
                                                                        child: Text(
                                                                            '확인'),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );

                                                              break;
                                                          }
                                                        },
                                                        itemBuilder:
                                                            (BuildContext
                                                                context) {
                                                          List<
                                                                  PopupMenuEntry<
                                                                      int>>
                                                              menuItems = [
                                                            const PopupMenuItem<
                                                                int>(
                                                              value: 1,
                                                              child: Text('삭제'),
                                                            ),
                                                            const PopupMenuItem<
                                                                int>(
                                                              value: 2,
                                                              child: Text('신고'),
                                                            ),
                                                            const PopupMenuItem<
                                                                int>(
                                                              value: 3,
                                                              child: Text('차단'),
                                                            ),
                                                            const PopupMenuItem<
                                                                int>(
                                                              value: 0,
                                                              child: Text('수정'),
                                                            ),
                                                          ];

                                                          return menuItems;
                                                        },
                                                      ),
                                                    ),
                                                    // Icon(
                                                    //   Icons.more_vert,
                                                    //   size: 15.r,
                                                    // )
                                                  ],
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    style:
                                                        TextStyle(fontSize: 15),
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
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          posts[index].contents,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        width: 65,
                                                        height: 65,
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
                                                                  .circular(10),
                                                        ),
                                                        child:
                                                            posts[index]
                                                                    .images
                                                                    .isNotEmpty
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      imageUrl: (EnvConfig()
                                                                              .s3Url +
                                                                          posts[index]
                                                                              .images[0]),
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
                                                        width: 10,
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
                                                                EdgeInsets.only(
                                                                    right: 5.0),
                                                            child: Icon(
                                                                Icons.comment),
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize: 12,
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
                                                                left: 8.0),
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          5.0),
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
                                                                fontSize: 12,
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
                                                                left: 8.0),
                                                        child: Text(
                                                          style: TextStyle(
                                                            fontSize: 12,
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
                        children: [
                          Expanded(
                            child: FutureBuilder<List<Post>>(
                              future: futurePosts,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('작성된 글이 없습니다.'));
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
                                          ).then((value) => setState(() {
                                                futurePosts = fetchPosts();
                                              })),
                                        },
                                        child: Container(
                                          height: 150,
                                          decoration: const BoxDecoration(
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
                                                left: 8.0, top: 8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      posts[index].name,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                    PopupMenuButton<int>(
                                                      padding: EdgeInsets.zero,
                                                      color: Colors.white,
                                                      child: Icon(
                                                          Icons.more_vert,
                                                          size: 15),
                                                      onSelected:
                                                          (value) async {
                                                        switch (value) {
                                                          case 0:
                                                            print(
                                                                "Edit selected");

                                                            int authorId = int.parse(
                                                                (await SecureStroageService
                                                                    .readUserId())!);

                                                            if (posts[index]
                                                                    .authorId ==
                                                                authorId) {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => PostModifyPage(
                                                                          id: posts[index]
                                                                              .id,
                                                                          title: posts[index]
                                                                              .title,
                                                                          contents: posts[index]
                                                                              .contents,
                                                                          imageNames:
                                                                              posts[index].images))).then(
                                                                  (value) =>
                                                                      setState(
                                                                          () {
                                                                        futurePosts =
                                                                            fetchPosts();
                                                                      }));
                                                            } else {
                                                              _showFailureDialog(
                                                                  context,
                                                                  '글쓴이가 아닙니다.');
                                                            }

                                                            break;
                                                          case 1:
                                                            int authorId = int.parse(
                                                                (await SecureStroageService
                                                                    .readUserId())!);
                                                            if (posts[index]
                                                                    .authorId ==
                                                                authorId) {
                                                              deletePost(
                                                                  posts[index]
                                                                      .id);
                                                            } else {
                                                              _showFailureDialog(
                                                                  context,
                                                                  "글쓴이가 아닙니다.");
                                                            }
                                                            print(
                                                                "Delete selected");
                                                            // Handle delete action
                                                            break;
                                                          case 2:
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return ReportDialog(
                                                                    item: posts[
                                                                        index],
                                                                    type: CommunityType
                                                                        .POST);
                                                              },
                                                            );
                                                            print(
                                                                "Report selected");
                                                            // Handle report action
                                                            break;
                                                          case 3:
                                                            print(
                                                                "Block selected");

                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: Text(
                                                                      '차단'),
                                                                  content: Text(
                                                                      '해당 사용자를 차단하시겠습니까?'),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          '취소'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        await blockUser(
                                                                            posts[index].authorId);
                                                                      },
                                                                      child: Text(
                                                                          '확인'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );

                                                            break;
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        List<
                                                                PopupMenuEntry<
                                                                    int>>
                                                            menuItems = [
                                                          const PopupMenuItem<
                                                              int>(
                                                            value: 1,
                                                            child: Text('삭제'),
                                                          ),
                                                          const PopupMenuItem<
                                                              int>(
                                                            value: 2,
                                                            child: Text('신고'),
                                                          ),
                                                          const PopupMenuItem<
                                                              int>(
                                                            value: 3,
                                                            child: Text('차단'),
                                                          ),
                                                          const PopupMenuItem<
                                                              int>(
                                                            value: 0,
                                                            child: Text('수정'),
                                                          ),
                                                        ];

                                                        return menuItems;
                                                      },
                                                    ),
                                                    // Icon(
                                                    //   Icons.more_vert,
                                                    //   size: 15.r,
                                                    // )
                                                  ],
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    style:
                                                        TextStyle(fontSize: 15),
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
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          posts[index].contents,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                        width: 65,
                                                        height: 65,
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
                                                                  .circular(10),
                                                        ),
                                                        child:
                                                            posts[index]
                                                                    .images
                                                                    .isNotEmpty
                                                                ? ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      imageUrl:
                                                                          ('${EnvConfig().s3Url}${posts[index].images[0]}'),
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
                                                        width: 10,
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
                                                                    right: 5.0),
                                                            child: const Icon(
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
                                                                left: 8.0),
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          5.0),
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
                                                                fontSize: 12,
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
                                                                left: 8.0),
                                                        child: Text(
                                                          style: TextStyle(
                                                            fontSize: 12,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          child: SizedBox(
            width: 95,
            height: 40,
            child: FloatingActionButton(
              backgroundColor: const Color(0xff154236),
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PostingPage()))
                    .then((value) => setState(() {
                          futurePosts = fetchPosts();
                        }));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "글쓰기",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    const Icon(
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
