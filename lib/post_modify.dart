import 'dart:async';
import 'dart:convert';
import 'package:campride/env_config.dart';
import 'package:campride/login.dart';
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

class PostModifyPage extends StatefulWidget {
  final int id;
  final String title;
  final String contents;
  final List<String> imageNames;

  const PostModifyPage(
      {super.key,
      required this.id,
      required this.title,
      required this.contents,
      required this.imageNames});

  @override
  _PostingPageState createState() => _PostingPageState();
}

class _PostingPageState extends State<PostModifyPage> {
  String title = "";
  String contents = "";
  List<dynamic> images = [];
  final picker = ImagePicker();
  String jwt = "";

  late TextEditingController _titleController;
  late TextEditingController _contentsController;

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

  Future<void> _updatePost() async {
    jwt = (await SecureStroageService.readAccessToken())!;
    List<String> imageNames = [];

    var uri = Uri.parse('http://localhost:8080/api/v1/post/${widget.id}');

    var request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer ${jwt}';

    for (var image in images) {
      if (image is String) {
        imageNames.add(image);
      } else if (image is File) {
        request.files
            .add(await http.MultipartFile.fromPath('images', image.path));
      }
    }

    Map<String, dynamic> postRequest = {
      'title': _titleController.text,
      'contents': _contentsController.text,
      'imageNames': imageNames,
    };
    request.fields['postRequest'] = json.encode(postRequest);

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Post updated successfully');
      Navigator.pop(context);
    } else {
      print('Failed to update post');
      print('Response status: ${response.statusCode}');
      print('Response body: ${await response.stream.bytesToString()}');
    }
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
    contents = widget.contents;
    images = List<dynamic>.from(widget.imageNames);
    _titleController = TextEditingController(text: title);
    _contentsController = TextEditingController(text: contents);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentsController.dispose();
    super.dispose();
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
            "글 수정",
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
            Container(
              height: 50,
              color: Colors.white,
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    onChanged: (text) {
                      setState(() {
                        title = text;
                      });
                    },
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
                  controller: _contentsController,
                  onChanged: (text) {
                    setState(() {
                      contents = text;
                    });
                  },
                  maxLines: null,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
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
                                      image: images[index] is File
                                          ? FileImage(images[index] as File)
                                          : NetworkImage(
                                                  ('${EnvConfig().s3Url}' +
                                                      images[index]) as String)
                                              as ImageProvider,
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
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
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
                  decoration: BoxDecoration(
                    border: Border(),
                    color: Colors.white,
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt_outlined),
                            onPressed: () {
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: Icon(Icons.image_outlined),
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
                              _updatePost();
                            },
                            child: Container(
                              width: 40,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Color(0xFF154135),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
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
                          SizedBox(
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
