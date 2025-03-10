import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_request.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_response.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/create_invoice_service.dart';

class CreateInvoiceRepo {
  final CreateInvoiceService createInvoiceService;
  final NetworkConnection networkConnection;

  CreateInvoiceRepo({
    required this.createInvoiceService,
    required this.networkConnection,
  });

  Future<Either<Failures, CreateInvoiceResponse>> createInvoiceRepo(CreateInvoiceRequest body) async {
    if (await networkConnection.isConnected) {
      try {
        var data = await createInvoiceService.createInvoice(body);
        return Right(CreateInvoiceResponse.fromMap(data.data));
      } on Forbidden {
        return Left(ForbiddenFailure(message: forbiddenMessage));
      } on BAD_REQUEST catch (e) {
        print('BAD_REQUEST');
        print(e.message);
        return Left(ServerFailure(message: e.message));
      } on DioException catch (e) {
        print('e.response!.data');
        print(e.response!.data);
        return Left(ServerFailure(message: e.response!.data.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
