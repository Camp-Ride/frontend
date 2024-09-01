import 'dart:convert';

import 'package:campride/community_type.dart';
import 'package:campride/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'auth_dio.dart';
import 'item.dart';

class ReportDialog extends StatefulWidget {
  final Item item;
  final CommunityType type;

  const ReportDialog({super.key, required this.item, required this.type});

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

    var dio = await authDio(context);

    await dio.post(
      '/report',
      data: {
        'itemId': itemId,
        'content': content,
        'communityType': type.toString().split('.').last,
      },
    ).then((response) {
      print('신고가 성공적으로 접수되었습니다.');
    }).catchError((error) {
      print('신고 실패: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('신고하기')),
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
          decoration: const InputDecoration(
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
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _submitReport,
          child: const Text('확인'),
        ),
      ],
    );
  }
}
