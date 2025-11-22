// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'get_all_products_bloc.dart';

@immutable
abstract class GetAllProductsEvent {}

class GetAllProducts extends GetAllProductsEvent {
  GetAllProducts();
}
