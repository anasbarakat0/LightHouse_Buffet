import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/app_url.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/utils/service.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_request.dart';

class CreateInvoiceService extends Service {
  CreateInvoiceService({required super.dio});

  Future<Response> createInvoice(CreateInvoiceRequest body) async {
    try {
      print(body.toMap());
      response = await dio.post(
        "$baseUrl/api/v1/buffet-invoices/new",
        data: body.toMap(),
        options: options(false),
      );
      return response;
    } on DioException catch (e) {
      print("DioException in createInvoice");
      final response = e.response;
      final data = response?.data;
      if (response != null && data != null && data is Map) {
        if (data["status"] == "BAD_REQUEST") {
          print(data);
          throw BAD_REQUEST.fromMap(Map<String, dynamic>.from(data));
        } else if (data["status"] == 403) {
          throw Forbidden();
        }
      }
      rethrow;
    }
  }
}
