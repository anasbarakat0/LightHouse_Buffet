import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/app_url.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/utils/service.dart';

class GetProductByBarcodeService extends Service {
  GetProductByBarcodeService({required super.dio});

  Future<Response> getProductByBarcode(String barcode) async {
    try {
      response = await dio.get(
        "$baseUrl/api/products/barcode/$barcode",
        options: options(false),
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        if (e.response!.data is Map) {
          if (e.response!.data["status"] == "BAD_REQUEST") {
            throw BAD_REQUEST.fromMap(e.response!.data);
          } else if (e.response!.data["status"] == 403) {
            throw Forbidden();
          }
        }
      }
      rethrow;
    }
  }
}

