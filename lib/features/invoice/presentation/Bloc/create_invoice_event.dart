part of 'create_invoice_bloc.dart';

@immutable
abstract class CreateInvoiceEvent {}

class CreateInvoice extends CreateInvoiceEvent {
  final CreateInvoiceRequest body;
  CreateInvoice({required this.body});
}
