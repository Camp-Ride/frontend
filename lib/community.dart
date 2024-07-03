import 'dart:async';
import 'package:campride/login.dart';
import 'package:campride/post.dart';
import 'package:campride/posting.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:campride/main.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Post> posts = [
    Post(
        id: 1,
        name: "준행행님",
        date: "2024/7/25",
        title: "08/11일 상록 예비군 출발하실 분 있나요?",
        contents: "상록수역에 모여서 출발해요 여기로 와주세요",
        commentCount: 5,
        likeCount: 0),
    Post(
        id: 1,
        name: "준행행님",
        date: "2024/7/25",
        title: "예비군복 어디서 빌리는지 아시는 분 계세요?",
        contents:
            "예비군복이 없는데 빌려야하는데 어떻게 해야할지 모르겠어요예비군복이 없는데 빌려야하는 어떻게 해야할지 모르겠어요예비군복이 없는데 빌려야하는데 어떻게 해야할지 모르겠어요",
        commentCount: 5,
        likeCount: 0),
    Post(
        id: 1,
        name: "준행행님",
        date: "2024/7/25",
        title: "끝나고 같이 버스 타고 걸어가자",
        contents:
            "나는 나라를 지키는 준형이 나는 리치 준형이다. 나는 자르반 할아버지다 나는 나라를 지키는 퉁퉁이 준형이 나는 리치 준형이다.  나는 나는 자르",
        commentCount: 5,
        likeCount: 190),
    Post(
        id: 1,
        name: "준행행님",
        date: "2024/7/25",
        title: "끝나고 같이 버스 타고 걸어가자",
        contents:
            "나는 나라를 지키는 준형이 나는 리치 준형이다. 나는 자르반 할아버지다 나는 나라를 지키는 퉁퉁이 준형이 나는 리치 준형이다.  나는 나는 자르",
        commentCount: 5,
        likeCount: 190),
    Post(
        id: 1,
        name: "준행행님",
        date: "2024/7/25",
        title: "끝나고 같이 버스 타고 걸어가자",
        contents:
            "나는 나라를 지키는 준형이 나는 리치 준형이다. 나는 자르반 할아버지다 나는 나라를 지키는 퉁퉁이 준형이 나는 리치 준형이다.  나는 나는 자르",
        commentCount: 5,
        likeCount: 190),
    Post(
        id: 1,
        name: "준행행님",
        date: "2024/7/25",
        title: "끝나고 같이 버스 타고 걸어가자",
        contents:
            "나는 나라를 지키는 준형이 나는 리치 준형이다. 나는 자르반 할아버지다 나는 나라를 지키는 퉁퉁이 준형이 나는 리치 준형이다.  나는 나는 자르",
        commentCount: 5,
        likeCount: 190)
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
                            child: ListView.builder(
                                itemCount: posts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 150.h,
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
                                            Text(
                                              posts[index].name,
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.black54),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child:
                                                    Text(posts[index].title)),
                                            Expanded(
                                                flex: 3,
                                                child: Text(
                                                    style: TextStyle(
                                                        height: 16 / 11,
                                                        fontSize: 13.sp,
                                                        color: Colors.black54),
                                                    posts[index].contents)),
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
                                                        Text(posts[index]
                                                            .commentCount
                                                            .toString()),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                                            child: Icon(Icons
                                                                .favorite_border),
                                                          ),
                                                          Text(posts[index]
                                                              .likeCount
                                                              .toString()),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ))
                                          ]),
                                    ),
                                  );
                                }),
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
