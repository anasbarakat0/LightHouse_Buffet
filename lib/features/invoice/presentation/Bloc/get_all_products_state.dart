part of 'get_all_products_bloc.dart';

@immutable
abstract class GetAllProductsState {}

class GetAllProductsInitial extends GetAllProductsState {}

class SuccessGettingProducts extends GetAllProductsState {
  final GetAllProductsResponseModel response;
  SuccessGettingProducts({
    required this.response,
  });
}

class NoProductsToShow extends GetAllProductsState {}

class ExceptionGetProducts extends GetAllProductsState {
  final String message;
  ExceptionGetProducts({
    required this.message,
  });
}

class ForbiddenGetProducts extends GetAllProductsState {
  final String message;
  ForbiddenGetProducts({
    required this.message,
  });
}

class LoadingGetProducts extends GetAllProductsState {}
