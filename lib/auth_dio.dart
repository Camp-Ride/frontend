import 'package:campride/Constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    hide Options;

import 'login.dart';

Future authDio(BuildContext context) async {
  var dio = Dio();
  final storage = new FlutterSecureStorage();

  dio.interceptors.clear();

  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
    // 기기에 저장된 AccessToken 로드
    final accessToken = await storage.read(key: 'access_token');

    // 매 요청마다 헤더에 AccessToken을 포함
    options.baseUrl = Constants.API + '/api/v1';
    options.headers['Authorization'] = 'Bearer $accessToken';
    return handler.next(options);
  }, onError: (error, handler) async {
    print(error);
    print(error.response);
    print(error.response?.statusCode);

    // 인증 오류가 발생했을 경우: AccessToken의 만료
    if (error.response?.statusCode == 401) {
      print("start refresh token");
      // 기기에 저장된 AccessToken과 RefreshToken 로드
      final accessToken = await storage.read(key: 'access_token');
      final refreshToken = await storage.read(key: 'refresh_token');

      // 토큰 갱신 요청을 담당할 dio 객체 구현 후 그에 따른 interceptor 정의
      var refreshDio = Dio();

      refreshDio.interceptors.clear();

      refreshDio.interceptors
          .add(InterceptorsWrapper( onError: (error, handler) async {

        // 다시 인증 오류가 발생했을 경우: RefreshToken의 만료
        if (error.response?.statusCode == 401) {
          // 기기의 자동 로그인 정보 삭제
          await storage.deleteAll();

          // . . .
          // 로그인 만료 dialog 발생 후 로그인 페이지로 이동
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
          // . . .
        }
        // return handler.next(error);
      }));

      // 토큰 갱신 API 요청 시 AccessToken(만료), RefreshToken 포함
      // refreshDio.options.headers['Authorization'] = 'Bearer $accessToken';
      // refreshDio.options.headers['Refresh'] = 'Bearer $refreshToken';

      print("1");
      // 토큰 갱신 API 요청
      refreshDio.options.baseUrl = Constants.API + '/api/v1';
      final refreshResponse = await refreshDio
          .post('/token/refreshtoken', data: {"refreshToken": refreshToken});

      print(refreshResponse);
      print(refreshResponse.data);

      // response로부터 새로 갱신된 AccessToken과 RefreshToken 파싱
      final newAccessToken = refreshResponse.data['accessToken'];
      final newRefreshToken = refreshResponse.data["refreshToken"];

      // 기기에 저장된 AccessToken과 RefreshToken 갱신
      await storage.write(key: 'access_token', value: newAccessToken);
      await storage.write(key: 'refresh_token', value: newRefreshToken);

      // // AccessToken의 만료로 수행하지 못했던 API 요청에 담겼던 AccessToken 갱신
      error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      // 수행하지 못했던 API 요청 복사본 생성
      final clonedRequest = await dio.request(error.requestOptions.path,
          options: Options(
              method: error.requestOptions.method,
              headers: error.requestOptions.headers),
          data: error.requestOptions.data,
          queryParameters: error.requestOptions.queryParameters);

      // API 복사본으로 재요청
      return handler.resolve(clonedRequest);
    }

    return handler.next(error);
  }));

  return dio;
}
