import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/exception.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/features/client_scan/data/models/qr_code_verification_response_model.dart';
import 'package:lighthouse_buffet/features/client_scan/data/source/remote/qr_code_verification_service.dart';

class QrCodeVerificationRepo {
  final QrCodeVerificationService qrCodeVerificationService;
  final NetworkConnection networkConnection;

  QrCodeVerificationRepo({
    required this.qrCodeVerificationService,
    required this.networkConnection,
  });

  Future<Either<Failures, QrCodeVerificationResponseModel>> verifyQrCode(
      String qrCode) async {
    if (await networkConnection.isConnected) {
      try {
        var data = await qrCodeVerificationService.verifyQrCode(qrCode);
        var response =
            QrCodeVerificationResponseModel.fromMap(data.data);
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

