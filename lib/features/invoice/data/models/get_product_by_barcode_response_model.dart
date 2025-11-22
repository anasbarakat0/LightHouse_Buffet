import 'dart:convert';

class GetProductByBarcodeResponseModel {
  final String message;
  final String status;
  final String localDateTime;
  final ProductByBarcodeBody? body;

  GetProductByBarcodeResponseModel({
    required this.message,
    required this.status,
    required this.localDateTime,
    this.body,
  });

  GetProductByBarcodeResponseModel copyWith({
    String? message,
    String? status,
    String? localDateTime,
    ProductByBarcodeBody? body,
  }) {
    return GetProductByBarcodeResponseModel(
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
      'body': body?.toMap(),
    };
  }

  factory GetProductByBarcodeResponseModel.fromMap(Map<String, dynamic> map) {
    return GetProductByBarcodeResponseModel(
      message: map['message'] as String,
      status: map['status'] as String,
      localDateTime: map['localDateTime'] as String,
      body: map['body'] != null
          ? ProductByBarcodeBody.fromMap(map['body'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory GetProductByBarcodeResponseModel.fromJson(String source) =>
      GetProductByBarcodeResponseModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GetProductByBarcodeResponseModel(message: $message, status: $status, localDateTime: $localDateTime, body: $body)';
  }
}

class ProductByBarcodeBody {
  final String id;
  final String name;
  final double costPrice;
  final int quantity;
  final double consumptionPrice;
  final String barCode;
  final String shortCut;

  ProductByBarcodeBody({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.quantity,
    required this.consumptionPrice,
    required this.barCode,
    required this.shortCut,
  });

  ProductByBarcodeBody copyWith({
    String? id,
    String? name,
    double? costPrice,
    int? quantity,
    double? consumptionPrice,
    String? barCode,
    String? shortCut,
  }) {
    return ProductByBarcodeBody(
      id: id ?? this.id,
      name: name ?? this.name,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      consumptionPrice: consumptionPrice ?? this.consumptionPrice,
      barCode: barCode ?? this.barCode,
      shortCut: shortCut ?? this.shortCut,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'costPrice': costPrice,
      'quantity': quantity,
      'consumptionPrice': consumptionPrice,
      'barCode': barCode,
      'shortCut': shortCut,
    };
  }

  factory ProductByBarcodeBody.fromMap(Map<String, dynamic> map) {
    return ProductByBarcodeBody(
      id: map['id'] as String,
      name: map['name'] as String,
      costPrice: (map['costPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      consumptionPrice: (map['consumptionPrice'] as num).toDouble(),
      barCode: map['barCode'] as String,
      shortCut: map['shortCut'] as String? ?? 'false',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductByBarcodeBody.fromJson(String source) =>
      ProductByBarcodeBody.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductByBarcodeBody(id: $id, name: $name, costPrice: $costPrice, quantity: $quantity, consumptionPrice: $consumptionPrice, barCode: $barCode, shortCut: $shortCut)';
  }
}

