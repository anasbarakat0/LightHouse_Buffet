// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class GetAllProductsResponseModel {
    final List<Body> body;
  GetAllProductsResponseModel({
    required this.body,
  });

   


  GetAllProductsResponseModel copyWith({
    List<Body>? body,
  }) {
    return GetAllProductsResponseModel(
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'body': body.map((x) => x.toMap()).toList(),
    };
  }

  factory GetAllProductsResponseModel.fromMap(List<dynamic> list) {
    return GetAllProductsResponseModel(
      body: list.map<Body>((x) => Body.fromMap(x as Map<String, dynamic>)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory GetAllProductsResponseModel.fromJson(String source) => GetAllProductsResponseModel.fromMap(json.decode(source) as List<dynamic>);

  @override
  String toString() {
    return 'GetAllProductsResponseModel(body: $body)';
  }

  @override
  bool operator ==(covariant GetAllProductsResponseModel other) {
    if (identical(this, other)) return true;
  
    return listEquals(other.body, body);
  }

  @override
  int get hashCode => body.hashCode;
}

class Body {
    final String? createdAt;
    final String? updatedAt;
    final String? createdBy;
    final String? lastModifiedBy;
    final String id;
    final String name;
    final double costPrice;
    final int quantity;
    final double consumptionPrice;
    final String barCode;
    final bool shortCut;
  Body({
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.lastModifiedBy,
    required this.id,
    required this.name,
    required this.costPrice,
    required this.quantity,
    required this.consumptionPrice,
    required this.barCode,
    required this.shortCut,
  });


  Body copyWith({
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? lastModifiedBy,
    String? id,
    String? name,
    double? costPrice,
    int? quantity,
    double? consumptionPrice,
    String? barCode,
    bool? shortCut,
  }) {
    return Body(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
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
    return <String, dynamic>{
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'lastModifiedBy': lastModifiedBy,
      'id': id,
      'name': name,
      'costPrice': costPrice,
      'quantity': quantity,
      'consumptionPrice': consumptionPrice,
      'barCode': barCode,
      'shortCut': shortCut,
    };
  }

  factory Body.fromMap(Map<String, dynamic> map) {
    return Body(
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
      createdBy: map['createdBy'] as String?,
      lastModifiedBy: map['lastModifiedBy'] as String?,
      id: map['id'] as String,
      name: map['name'] as String,
      costPrice: (map['costPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      consumptionPrice: (map['consumptionPrice'] as num).toDouble(),
      barCode: map['barCode'] as String,
      shortCut: map['shortCut'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Body.fromJson(String source) => Body.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Body(id: $id, name: $name, costPrice: $costPrice, quantity: $quantity, consumptionPrice: $consumptionPrice, barCode: $barCode, shortCut: $shortCut)';
  }

  @override
  bool operator ==(covariant Body other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.costPrice == costPrice &&
      other.quantity == quantity &&
      other.consumptionPrice == consumptionPrice &&
      other.barCode == barCode &&
      other.shortCut == shortCut;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      costPrice.hashCode ^
      quantity.hashCode ^
      consumptionPrice.hashCode ^
      barCode.hashCode ^
      shortCut.hashCode;
  }
}

