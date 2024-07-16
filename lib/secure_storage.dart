import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStroageService {
  final _storage = FlutterSecureStorage();

  Future<void> saveNickname(String nickname) async {
    await _storage.write(key: 'nickname', value: nickname);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<String?> readNickname() async {
    return await _storage.read(key: 'nickname');
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
  Future<void> deleteNickname() async {
    await _storage.delete(key: 'nickname');
  }
}
