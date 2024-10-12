import 'package:campride/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'auth_dio.dart';

class NicknameUpdatePage extends StatefulWidget {
  const NicknameUpdatePage({super.key});

  @override
  _NicknameUpdatePageState createState() => _NicknameUpdatePageState();
}

class _NicknameUpdatePageState extends State<NicknameUpdatePage> {
  String nickname = "";
  String inputNickname = "";
  String validationMessage = "";
  Color validationColor = Colors.red;

  @override
  void initState() {
    super.initState();
    initializeNickname();
  }

  void initializeNickname() async {
    nickname = (await SecureStroageService.readNickname())!;
    inputNickname = nickname; // inputNickname을 현재 닉네임으로 초기화
    setState(() {});
    print(nickname);
  }

  Future<void> _updateNicknameApi(String nickname) async {
    var dio = await authDio(context);

    dio.put('/user', data: {'nickname': nickname}).then((response) {
      if (response.statusCode == 200) {
        SecureStroageService.saveNickname(nickname);
        print("Nickname updated to: $nickname");
        SecureStroageService.saveIsNicknameUpdated("true");

        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else {
        print("Failed to update nickname: ${response.statusCode}");

        if (response['code'] == 3016) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("닉네임 설정 실패"),
                content: const Text("이미 사용 중인 닉네임입니다. 다른 닉네임을 입력해 주세요."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("확인"),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("알 수 없는 에러"),
                content: const Text("잠시 뒤 다시 시도해 주세요."),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("확인"),
                  ),
                ],
              );
            },
          );
        }
      }
    }).catchError((e) {
      print("Error: $e");
    });
  }

  void updateValidationMessage(String value) {
    setState(() {
      inputNickname = value;
      if (value.isEmpty) {
        // 입력값이 비어있을 때 처리 추가
        validationMessage = "현재 닉네임을 유지합니다.";
        validationColor = Colors.green;
      } else if (value.length < 2) {
        validationMessage = "닉네임은 2자 이상 입력해주세요.";
        validationColor = Colors.red;
      } else if (value.length > 8) {
        validationMessage = "닉네임은 8자 이하로 입력해주세요.";
        validationColor = Colors.red;
      } else {
        validationMessage = "올바른 닉네임 형식입니다.";
        validationColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "닉네임 설정",
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20.h),
          Text(
            "🎉 환영합니다! 🎉",
            style: TextStyle(
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "캠프라이드에서 사용할 닉네임을 설정해주세요",
            style: TextStyle(
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "한번 수정하면 다시 변경할 수 없습니다.",
            style: TextStyle(
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 50.h),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: nickname,
              ),
              onChanged: updateValidationMessage,
              maxLength: 8,
            ),
          ),
          Text(
            validationMessage,
            style: TextStyle(
              fontSize: 13.sp,
              color: validationColor,
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(150.w, 30.h),
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
            ),
            onPressed: (inputNickname.isEmpty || (inputNickname.length >= 2 && inputNickname.length <= 8))
                ? () {
                    _updateNicknameApi(inputNickname);
                  }
                : null,
            child: const Text('완료'),
          ),
          SizedBox(height: 160.h),
        ],
      ),
    );
  }
}
