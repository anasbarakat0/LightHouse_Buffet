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
        "$baseUrl/api/v1/buffet-invoices",
        data: body.toMap(),
        options: options(true),
      );
      return response;
    } on DioException catch (e) {
      print("DioException in createInvoice");
      if (e.response!.data["status"] == "BAD_REQUEST") {
        print(e.response!.data);
        throw BAD_REQUEST.fromMap(e.response!.data);
      } else if (e.response!.data["status"] == 403) {
        throw Forbidden();
      } else {
        rethrow;
      }
    }
  }
}
