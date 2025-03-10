import 'package:bloc/bloc.dart';
import 'package:lighthouse_buffet/core/constants/messages.dart';
import 'package:lighthouse_buffet/core/error/failure.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_request.dart';
import 'package:lighthouse_buffet/features/invoice/data/models/create_invoice_response.dart';
import 'package:lighthouse_buffet/features/invoice/data/repository/create_invoice_repo.dart';
import 'package:meta/meta.dart';
part 'create_invoice_event.dart';
part 'create_invoice_state.dart';

class CreateInvoiceBloc extends Bloc<CreateInvoiceEvent, CreateInvoiceState> {
  final CreateInvoiceRepo repo;
  CreateInvoiceBloc(this.repo) : super(CreateInvoiceInitial()) {
    on<CreateInvoice>((event, emit) async {
      emit(LoadingCreateInvoice());
      final result = await repo.createInvoiceRepo(event.body);
      result.fold(
        (failure) {
          if (failure is OfflineFailure) {
            emit(OfflineFailureCreateInvoice(message: connectionMessage ));
          } else if (failure is ForbiddenFailure) {
            emit(ExceptionCreateInvoice(message: failure.message ));
          } else if (failure is ServerFailure) {
            emit(ExceptionCreateInvoice(message: failure.message ));
          } else {
            emit(ExceptionCreateInvoice(message: "An unknown error occurred"));
          }
        },
        (response) {
          emit(SuccessCreateInvoice(response: response ));
        },
      );
    });
  }
}
