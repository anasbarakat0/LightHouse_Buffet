import 'dart:convert';

class CreateInvoiceRequest {
  final String qrCode;
  final List<OrderRequest> orders;

  CreateInvoiceRequest({
    required this.qrCode,
    required this.orders,
  });

  CreateInvoiceRequest copyWith({
    String? qrCode,
    List<OrderRequest>? orders,
  }) {
    return CreateInvoiceRequest(
      qrCode: qrCode ?? this.qrCode,
      orders: orders ?? this.orders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qrCode': qrCode,
      'orders': orders.map((x) => x.toMap()).toList(),
    };
  }

  factory CreateInvoiceRequest.fromMap(Map<String, dynamic> map) {
    return CreateInvoiceRequest(
      qrCode: map['qrCode'] as String,
      orders: List<OrderRequest>.from(
        (map['orders'] as List).map((x) => OrderRequest.fromMap(x as Map<String, dynamic>)),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateInvoiceRequest.fromJson(String source) =>
      CreateInvoiceRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CreateInvoiceRequest(qrCode: $qrCode, orders: $orders)';
}

class OrderRequest {
  final String productId;
  final int quantity;

  OrderRequest({
    required this.productId,
    required this.quantity,
  });

  OrderRequest copyWith({
    String? productId,
    int? quantity,
  }) {
    return OrderRequest(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory OrderRequest.fromMap(Map<String, dynamic> map) {
    return OrderRequest(
      productId: map['id'] as String,
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderRequest.fromJson(String source) =>
      OrderRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OrderRequest(productId: $productId, quantity: $quantity)';
}
