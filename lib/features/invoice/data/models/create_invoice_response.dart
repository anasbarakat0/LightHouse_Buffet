import 'dart:convert';

class CreateInvoiceResponse {
  final String message;
  final String status;
  final String localDateTime;
  final BuffetInvoice body;

  CreateInvoiceResponse({
    required this.message,
    required this.status,
    required this.localDateTime,
    required this.body,
  });

  CreateInvoiceResponse copyWith({
    String? message,
    String? status,
    String? localDateTime,
    BuffetInvoice? body,
  }) {
    return CreateInvoiceResponse(
      message: message ?? this.message,
      status: status ?? this.status,
      localDateTime: localDateTime ?? this.localDateTime,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'status': status,
      'localDateTime': localDateTime,
      'body': body.toMap(),
    };
  }

  factory CreateInvoiceResponse.fromMap(Map<String, dynamic> map) {
    return CreateInvoiceResponse(
      message: map['message'] as String,
      status: map['status'] as String,
      localDateTime: map['localDateTime'] as String,
      body: BuffetInvoice.fromMap(map['body'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory CreateInvoiceResponse.fromJson(String source) =>
      CreateInvoiceResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CreateInvoiceResponse(message: $message, status: $status, localDateTime: $localDateTime, body: $body)';
  }
}

class BuffetInvoice {
  final String id;
  final String invoiceDate;
  final String invoiceTime;
  final String sessionId;
  final List<Order> orders;
  final double totalPrice;

  BuffetInvoice({
    required this.id,
    required this.invoiceDate,
    required this.invoiceTime,
    required this.sessionId,
    required this.orders,
    required this.totalPrice,
  });

  BuffetInvoice copyWith({
    String? id,
    String? invoiceDate,
    String? invoiceTime,
    String? sessionId,
    List<Order>? orders,
    double? totalPrice,
  }) {
    return BuffetInvoice(
      id: id ?? this.id,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceTime: invoiceTime ?? this.invoiceTime,
      sessionId: sessionId ?? this.sessionId,
      orders: orders ?? this.orders,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceDate': invoiceDate,
      'invoiceTime': invoiceTime,
      'session_id': sessionId,
      'orders': orders.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
    };
  }

  factory BuffetInvoice.fromMap(Map<String, dynamic> map) {
    return BuffetInvoice(
      id: map['id'] as String,
      invoiceDate: map['invoiceDate'] as String,
      invoiceTime: map['invoiceTime'] as String,
      sessionId: map['session_id'] as String,
      orders: List<Order>.from(
          (map['orders'] as List<dynamic>).map((x) => Order.fromMap(x as Map<String, dynamic>))),
      totalPrice: map['totalPrice'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory BuffetInvoice.fromJson(String source) =>
      BuffetInvoice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BuffetInvoice(id: $id, invoiceDate: $invoiceDate, invoiceTime: $invoiceTime, sessionId: $sessionId, orders: $orders, totalPrice: $totalPrice)';
  }
}

class Order {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String buffetInvoice;

  Order({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.buffetInvoice,
  });

  Order copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    String? buffetInvoice,
  }) {
    return Order(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      buffetInvoice: buffetInvoice ?? this.buffetInvoice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'buffetInvoice': buffetInvoice,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      price: map['price'] as double,
      buffetInvoice: map['buffetInvoice'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, productId: $productId, productName: $productName, quantity: $quantity, price: $price, buffetInvoice: $buffetInvoice)';
  }
}
