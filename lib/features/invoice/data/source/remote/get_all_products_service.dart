import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/app_url.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/utils/service.dart';

class GetAllProductsService extends Service {
  GetAllProductsService({required super.dio});

  Future<Response> getAllProductsService(int page, int size) async {
    try {
      response = await dio.get(
        "$baseUrl/api/v1/products/all?page=$page&size=$size",
        options: options(false),
      );
      if (response.data["body"] == []) {
        print("00000000000000000000000000000000000000000000000000000000000000000000000000000000");
        throw NoData(message: "No product to show");
      } else {
        print("1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111");
        return response;
      }
    } on DioException catch (e) {
        print("22222222222222222222222222222222222222222222222222222222222222222222222");
      print("89 error");
      if (e.response!.data["status"] == "BAD_REQUEST") {
        print("3333333333333333333333333333333333333333333333333333333333333333333333");
        print("186455");
        throw BAD_REQUEST.fromMap(e.response!.data);
      } else if (e.response!.data['status'] == 403) {
        print("4444444444444444444444444444444444444444444444444444444444444444444");
        print("183735");
        throw Forbidden();
      } else {
        print("55555555555555555555555555555555555555555555555555555555555555");
        print("89710");
        rethrow;
      }
    }
  }
}
