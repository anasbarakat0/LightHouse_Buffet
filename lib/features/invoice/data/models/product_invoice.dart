// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:lighthouse_buffet/features/invoice/data/models/product_model.dart';

class ProductInvoice {
  ProductModel product;
  int quantity;
  ProductInvoice({
    required this.product,
    required this.quantity,
  });

  ProductInvoice copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return ProductInvoice(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory ProductInvoice.fromMap(Map<String, dynamic> map) {
    return ProductInvoice(
      product: ProductModel.fromMap(map['product'] as Map<String,dynamic>),
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductInvoice.fromJson(String source) => ProductInvoice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProductInvoice(product: $product, quantity: $quantity)';

  @override
  bool operator ==(covariant ProductInvoice other) {
    if (identical(this, other)) return true;
  
    return 
      other.product == product &&
      other.quantity == quantity;
  }

  @override
  int get hashCode => product.hashCode ^ quantity.hashCode;
}
