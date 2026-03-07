// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/utils/shared_prefrences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Service {
  Dio dio;
  late Response response;
  Service({
    required this.dio,
  });

  Options options(bool auth) {
    if (auth) {
      final token = storage.get<SharedPreferences>().getString("token");
      final headers = <String, dynamic>{
        'Accept': '*/*',
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return Options(headers: headers);
    }
    return Options(
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
    );
  }
}
