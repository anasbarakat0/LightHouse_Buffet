part of 'create_invoice_bloc.dart';

@immutable
abstract class CreateInvoiceState {}

class CreateInvoiceInitial extends CreateInvoiceState {}

class LoadingCreateInvoice extends CreateInvoiceState {}

class SuccessCreateInvoice extends CreateInvoiceState {
  final CreateInvoiceResponse response;
  SuccessCreateInvoice({required this.response});
}

class ExceptionCreateInvoice extends CreateInvoiceState {
  final String message;
  ExceptionCreateInvoice({required this.message});
}

class OfflineFailureCreateInvoice extends CreateInvoiceState {
  final String message;
  OfflineFailureCreateInvoice({required this.message});
}
