import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  late String prodUrl;
  late String s3Url;

  factory EnvConfig() {
    return _instance;
  }

  EnvConfig._internal();

  Future<void> loadEnv() async {
    await dotenv.load(fileName: "assets/env/.env");
    prodUrl = dotenv.env['PROD_URL'] ?? '';
    s3Url = dotenv.env['S3_URL'] ?? '';
  }
}
