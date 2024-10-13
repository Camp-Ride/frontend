import 'dart:async';
import 'dart:convert';
import 'package:campride/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'auth_dio.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({super.key});

  @override
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  String title = "";
  String contents = "";
  List<File> images = [];
  final picker = ImagePicker();
  String jwt = "";

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null && images.length < 3) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  Future<void> post(String title, String contents, List<File> images) async {
    var dio = await authDio(context);
    FormData formData = FormData();

    if (title.isEmpty || contents.isEmpty) {
      print("글을 작성하려면 글 제목이나 내용이 빠지면 안됩니다.");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("글 작성 실패"),
            content: const Text("글을 작성하려면 글 제목이나 내용이 빠지면 안됩니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("확인"),
              ),
            ],
          );
        },
      );
      return;
    }

    for (var image in images) {
      formData.files
          .add(MapEntry('images', await MultipartFile.fromFile(image.path)));
    }

    Map<String, dynamic> postRequestData = {
      'title': title,
      'contents': contents,
    };

    formData.fields.add(MapEntry('postRequest', json.encode(postRequestData)));

    await dio
        .post(
      '/post',
      data: formData,
    )
        .then((response) {
      print('Post created successfully');
      Navigator.pop(context);
    }).catchError((error) {
      print('Failed to create post');
      print('Response status: ${error.response?.statusCode}');
      print('Response body: ${error.response?.data}');
    });
  }

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
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "글 쓰기",
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
          children: [
            Container(
              height: 50,
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    onChanged: (text) {
                      setState(() {
                        title = text;
                      });
                    },
                    textAlign: TextAlign.start,
                    decoration: const InputDecoration(
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
                  onChanged: (text) {
                    setState(() {
                      contents = text;
                    });
                  },
                  maxLines: null,
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요.',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
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
                        children: List.generate(images.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0).r,
                            child: Stack(
                              children: [
                                Container(
                                  width: 85.w,
                                  height: 85.h,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10).r,
                                    image: DecorationImage(
                                      image: FileImage(images[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(),
                    color: Colors.white,
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined),
                            onPressed: () {
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: const Icon(Icons.image_outlined),
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              post(title, contents, images);
                            },
                            child: Container(
                              width: 40,
                              height: 25,
                              decoration: BoxDecoration(
                                color: const Color(0xFF154135),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Center(
                                child: Text(
                                  "완료",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
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
