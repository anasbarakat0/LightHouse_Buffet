// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/get_all_products_response_model.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_all_products_service.dart';

class GetAllProductsRepo {
  final GetAllProductsService getAllProductsService;
  final NetworkConnection networkConnection;
  GetAllProductsRepo({
    required this.getAllProductsService,
    required this.networkConnection,
  });

  Future<Either<Failures,GetAllProductsResponseModel>> getAllProductsRepo(int page,int size)async{
    if (await networkConnection.isConnected) {
      try {
        var data = await getAllProductsService.getAllProductsService(page, size);
        var response = GetAllProductsResponseModel.fromMap(data.data);
        
        return Right(response);
      } on Forbidden {
        return Left(ForbiddenFailure(message: forbiddenMessage));
      } on BAD_REQUEST catch (e) {
        return Left(ServerFailure(message: e.message));
      } on NoData catch (e) {
        return Left(NoDataFailure(message: e.message));
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response!.data.toString(),
          ),
        );
      }
    } else {
      return Left(OfflineFailure());
    }
  }
}
