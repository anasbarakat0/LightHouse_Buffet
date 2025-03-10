// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';

class Service {
  Dio dio;
  late Response response;
  Service({
    required this.dio,
  });

  options(bool auth) {
    Options options;
    if (auth) {
      // print(storage.get<SharedPreferences>().getString("token"));
      options = Options(
        headers: {
          'Accept': '*/*',
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzb21lRW1haWxAZ21haWwuY29tIiwiaWF0IjoxNzQxMTc1OTA2LCJleHAiOjE3NDM3Njc5MDZ9.z9bPpCjqat1h7AHhBXY_tID39-LZTrhOqKdtDKQ8qD4 ',
        },
      );
      //${storage.get<SharedPreferences>().getString("token")}
      return options;
    } else {
      options = Options(
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      );
    }
  }
}
