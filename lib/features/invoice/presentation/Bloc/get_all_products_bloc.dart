import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/get_all_products_response_model.dart';
import 'package:lighthouse_buffet/features/invoice/domain/usecase/get_all_products_usecase.dart';

part 'get_all_products_event.dart';
part 'get_all_products_state.dart';

class GetAllProductsBloc
    extends Bloc<GetAllProductsEvent, GetAllProductsState> {
  final GetAllProductsUsecase getAllProductsUsecase;
  GetAllProductsBloc(this.getAllProductsUsecase)
      : super(GetAllProductsInitial()) {
    on<GetAllProducts>((event, emit) async {
      emit(LoadingGetProducts());
      var data = await getAllProductsUsecase.call();
      data.fold((failures) {
        switch (failures) {
          case ServerFailure():
            emit(ExceptionGetProducts(message: failures.message));
            break;
          case OfflineFailure():
            emit(ExceptionGetProducts(message: connectionMessage));
            break;
          case ForbiddenFailure():
            emit(ForbiddenGetProducts(message: failures.message));
            break;
          case NoDataFailure():
            emit(NoProductsToShow());
            break;
          default:
            emit(
              ExceptionGetProducts(
                message: "An unexpected error occurred while loading products.",
              ),
            );
        }
      }, (response) {
        emit(SuccessGettingProducts(response: response));
      });
    });
  }
}
