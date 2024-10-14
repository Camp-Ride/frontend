import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStroageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveUserId(int userId) async {
    await _storage.write(key: 'userId', value: userId.toString());
  }

  static Future<void> saveNickname(String nickname) async {
    await _storage.write(key: 'nickname', value: nickname);
  }

  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }


  static Future<String?> readAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<String?> readNickname() async {
    return await _storage.read(key: 'nickname');
  }

  static Future<String?> readUserId() async {
    return await _storage.read(key: 'userId');
  }

  static Future<String> readPushPermission() async {
    String? pushPermission = await _storage.read(key: 'push_permission');
    return (pushPermission == null || pushPermission == 'true') ? 'true' : 'false';
  }

  static Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<void> deleteNickname() async {
    await _storage.delete(key: 'nickname');
  }

  static Future<void> deletePushPermission() async {
    await _storage.delete(key: 'push_permission');
  }

  static Future<void> savePushPermission(String? pushPermission) async {
    await _storage.write(key: 'push_permission', value: pushPermission);
  }

  static Future<void> saveIsNicknameUpdated(String? isNicknameUpdated) async {
    await _storage.write(key: 'isNicknameUpdated', value: isNicknameUpdated);
  }

  static Future<String?> readIsNicknameUpdated() async {
    return await _storage.read(key: 'isNicknameUpdated');
  }
}
