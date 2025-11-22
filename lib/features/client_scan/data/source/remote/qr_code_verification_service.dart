import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/app_url.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/utils/service.dart';

class QrCodeVerificationService extends Service {
  QrCodeVerificationService({required super.dio});

  Future<Response> verifyQrCode(String qrCode) async {
    try {
      response = await dio.get(
        "$baseUrl/api/qr-code/verify/$qrCode",
        options: options(false),
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data["status"] == "BAD_REQUEST") {
          throw BAD_REQUEST.fromMap(e.response!.data);
        } else if (e.response!.data["status"] == 403) {
          throw Forbidden();
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }
}

