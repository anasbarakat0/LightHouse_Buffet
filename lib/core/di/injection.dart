import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:lighthouse_buffet/core/constants/app_url.dart';
import 'package:lighthouse_buffet/core/network/network_connection.dart';
import 'package:lighthouse_buffet/features/client_scan/data/repository/qr_code_verification_repo.dart';
import 'package:lighthouse_buffet/features/client_scan/data/source/remote/qr_code_verification_service.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/create_invoice_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_all_products_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/get_product_by_barcode_repo.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/create_invoice_service.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_all_products_service.dart';
import 'package:lighthouse_buffet/features/invoice/data/source/remote/get_product_by_barcode_service.dart';

final getIt = GetIt.instance;

Future<void> initInjection() async {
  // Dio with baseUrl and timeouts
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
        },
      ),
    );
    return dio;
  });

  // Network
  getIt.registerLazySingleton<InternetConnectionChecker>(() {
    return InternetConnectionChecker.createInstance(
      addresses: [
        AddressCheckOption(
          uri: Uri.parse("https://www.google.com"),
          timeout: const Duration(seconds: 3),
        ),
        AddressCheckOption(
          uri: Uri.parse("https://1.1.1.1"),
          timeout: const Duration(seconds: 3),
        ),
      ],
    );
  });

  getIt.registerLazySingleton<NetworkConnection>(() {
    return NetworkConnection(
      internetConnectionChecker: getIt<InternetConnectionChecker>(),
    );
  });

  // Services
  getIt.registerLazySingleton<QrCodeVerificationService>(() {
    return QrCodeVerificationService(dio: getIt<Dio>());
  });
  getIt.registerLazySingleton<GetAllProductsService>(() {
    return GetAllProductsService(dio: getIt<Dio>());
  });
  getIt.registerLazySingleton<GetProductByBarcodeService>(() {
    return GetProductByBarcodeService(dio: getIt<Dio>());
  });
  getIt.registerLazySingleton<CreateInvoiceService>(() {
    return CreateInvoiceService(dio: getIt<Dio>());
  });

  // Repositories
  getIt.registerLazySingleton<QrCodeVerificationRepo>(() {
    return QrCodeVerificationRepo(
      qrCodeVerificationService: getIt<QrCodeVerificationService>(),
      networkConnection: getIt<NetworkConnection>(),
    );
  });
  getIt.registerLazySingleton<GetAllProductsRepo>(() {
    return GetAllProductsRepo(
      getAllProductsService: getIt<GetAllProductsService>(),
      networkConnection: getIt<NetworkConnection>(),
    );
  });
  getIt.registerLazySingleton<GetProductByBarcodeRepo>(() {
    return GetProductByBarcodeRepo(
      getProductByBarcodeService: getIt<GetProductByBarcodeService>(),
      networkConnection: getIt<NetworkConnection>(),
    );
  });
  getIt.registerLazySingleton<CreateInvoiceRepo>(() {
    return CreateInvoiceRepo(
      createInvoiceService: getIt<CreateInvoiceService>(),
      networkConnection: getIt<NetworkConnection>(),
    );
  });
}
