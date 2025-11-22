import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/get_product_by_barcode_response_model.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_product_by_barcode_service.dart';

class GetProductByBarcodeRepo {
  final GetProductByBarcodeService getProductByBarcodeService;
  final NetworkConnection networkConnection;

  GetProductByBarcodeRepo({
    required this.getProductByBarcodeService,
    required this.networkConnection,
  });

  Future<Either<Failures, GetProductByBarcodeResponseModel>> getProductByBarcode(
      String barcode) async {
    if (await networkConnection.isConnected) {
      try {
        var data = await getProductByBarcodeService.getProductByBarcode(barcode);
        var response = GetProductByBarcodeResponseModel.fromMap(data.data);
        return Right(response);
      } on Forbidden {
        return Left(ForbiddenFailure(message: forbiddenMessage));
      } on BAD_REQUEST catch (e) {
        return Left(ServerFailure(message: e.message));
      } on DioException catch (e) {
        if (e.response != null && e.response!.data != null) {
          return Left(ServerFailure(
              message: e.response!.data.toString()));
        } else {
          return Left(ServerFailure(message: e.toString()));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}

