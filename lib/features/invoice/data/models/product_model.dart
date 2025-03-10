// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProductModel {
  final String id;
    final String name;
    final double costPrice;
    int quantity;
    final double consumptionPrice;
    final String barCode;
  ProductModel({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.quantity,
    required this.consumptionPrice,
    required this.barCode,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? costPrice,
    int? quantity,
    double? consumptionPrice,
    String? barCode,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      consumptionPrice: consumptionPrice ?? this.consumptionPrice,
      barCode: barCode ?? this.barCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'costPrice': costPrice,
      'quantity': quantity,
      'consumptionPrice': consumptionPrice,
      'barCode': barCode,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      costPrice: map['costPrice'] as double,
      quantity: map['quantity'] as int,
      consumptionPrice: map['consumptionPrice'] as double,
      barCode: map['barCode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) => ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProductModel(id: $id ,name: $name, costPrice: $costPrice, quantity: $quantity, consumptionPrice: $consumptionPrice, barCode: $barCode)';
  }

  @override
  bool operator ==(covariant ProductModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.costPrice == costPrice &&
      other.quantity == quantity &&
      other.consumptionPrice == consumptionPrice &&
      other.barCode == barCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
     name.hashCode ^
      costPrice.hashCode ^
      quantity.hashCode ^
      consumptionPrice.hashCode ^
      barCode.hashCode;
  }
}
