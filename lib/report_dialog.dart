import 'dart:convert';

import 'package:campride/community_type.dart';
import 'package:campride/post.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'item.dart';

class ReportDialog extends StatefulWidget {
  final Item item;
  final CommunityType type;

  ReportDialog({required this.item, required this.type});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _controller = TextEditingController();

  void _submitReport() {
    final reportText = _controller.text;
    if (reportText.isNotEmpty) {
      sendReport(widget.item.id, reportText, widget.type);
      print('Report submitted: $reportText');
      Navigator.of(context).pop();
    }
  }

  Future<void> sendReport(
      int itemId, String content, CommunityType type) async {
    print(itemId);
    print(content);
    print(type);

    final url = Uri.parse('http://localhost:8080/api/v1/report');
    String jwt = (await SecureStroageService.readAccessToken())!;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({
        'itemId': itemId,
        'content': content,
        'communityType': type.toString().split('.').last,
      }),
    );

    if (response.statusCode == 200) {
      print('신고가 성공적으로 접수되었습니다.');
    } else {
      print(response);
      print('신고 실패: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('신고하기')),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          textAlign: TextAlign.center,
          controller: _controller,
          decoration: InputDecoration(
            hintText: '신고 내용을 입력하세요',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(16),
          ),
          maxLines: 3,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submitReport,
          child: Text('확인'),
        ),
      ],
    );
  }
}
