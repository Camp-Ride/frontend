import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementScreen extends StatefulWidget {
  @override
  _AgreementScreenState createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool privacyChecked = false;
  bool termsChecked = false;
  final String privacyPolicyUrl =
      'https://plip.kr/pcc/2f21868a-ec36-4ca8-8be9-dfb265843338/consent/3.html';
  final String termsAndConditionsUrl =
      'https://relic-baboon-412.notion.site/11f766a8bb4680868878f35fcda207fc?pvs=4';

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildCheckboxListTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Text(
                title,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: () => _launchURL(url),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('약관 동의'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildCheckboxListTile(
                  title: '개인정보 처리방침에 동의합니다.',
                  value: privacyChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      privacyChecked = value!;
                    });
                  },
                  url: privacyPolicyUrl,
                ),
                _buildCheckboxListTile(
                    title: '서비스 이용약관에 동의합니다.',
                    value: termsChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        termsChecked = value!;
                      });
                    },
                    url: termsAndConditionsUrl),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    child: Text(
                      '동의',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all<Size>(Size(400, 50)),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.black38; // 비활성화 상태일 때 회색
                          }
                          return Colors.black; // 활성화 상태일 때 검은색
                        },
                      ),
                    ),
                    onPressed: privacyChecked && termsChecked
                        ? () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('동의 완료'),
                                  content:
                                      Text('모든 약관에 동의하셨습니다. 다음 단계로 진행합니다.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('확인'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // 여기에 다음 화면으로 이동하는 코드를 추가할 수 있습니다.
                                        Navigator.pushReplacementNamed(
                                            context, '/login');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
