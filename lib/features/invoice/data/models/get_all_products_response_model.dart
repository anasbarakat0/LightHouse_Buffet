// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class GetAllProductsResponseModel {
    final String message;
    final String status;
    final String localDateTime;
    final List<Body> body;
    final Pageable pageable;
  GetAllProductsResponseModel({
    required this.message,
    required this.status,
    required this.localDateTime,
    required this.body,
    required this.pageable,
  });

   


  GetAllProductsResponseModel copyWith({
    String? message,
    String? status,
    String? localDateTime,
    List<Body>? body,
    Pageable? pageable,
  }) {
    return GetAllProductsResponseModel(
      message: message ?? this.message,
      status: status ?? this.status,
      localDateTime: localDateTime ?? this.localDateTime,
      body: body ?? this.body,
      pageable: pageable ?? this.pageable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'status': status,
      'localDateTime': localDateTime,
      'body': body.map((x) => x.toMap()).toList(),
      'pageable': pageable.toMap(),
    };
  }

  factory GetAllProductsResponseModel.fromMap(Map<String, dynamic> map) {
    return GetAllProductsResponseModel(
      message: map['message'] as String,
      status: map['status'] as String,
      localDateTime: map['localDateTime'] as String,
      body: List<Body>.from((map['body'] as List<dynamic>).map<Body>((x) => Body.fromMap(x as Map<String,dynamic>),),),
      pageable: Pageable.fromMap(map['pageable'] as Map<String,dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory GetAllProductsResponseModel.fromJson(String source) => GetAllProductsResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'GetAllProductsResponseModel(message: $message, status: $status, localDateTime: $localDateTime, body: $body, pageable: $pageable)';
  }

  @override
  bool operator ==(covariant GetAllProductsResponseModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.message == message &&
      other.status == status &&
      other.localDateTime == localDateTime &&
      listEquals(other.body, body) &&
      other.pageable == pageable;
  }

  @override
  int get hashCode {
    return message.hashCode ^
      status.hashCode ^
      localDateTime.hashCode ^
      body.hashCode ^
      pageable.hashCode;
  }
}

class Body {
    final String id;
    final String name;
    final double costPrice;
    final int quantity;
    final double consumptionPrice;
    final String barCode;
  Body({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.quantity,
    required this.consumptionPrice,
    required this.barCode,
  });


  Body copyWith({
    String? id,
    String? name,
    double? costPrice,
    int? quantity,
    double? consumptionPrice,
    String? barCode,
  }) {
    return Body(
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

  factory Body.fromMap(Map<String, dynamic> map) {
    return Body(
      id: map['id'] as String,
      name: map['name'] as String,
      costPrice: map['costPrice'] as double,
      quantity: map['quantity'] as int,
      consumptionPrice: map['consumptionPrice'] as double,
      barCode: map['barCode'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Body.fromJson(String source) => Body.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Body(id: $id, name: $name, costPrice: $costPrice, quantity: $quantity, consumptionPrice: $consumptionPrice, barCode: $barCode)';
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

class Pageable {
    final int page;
    final int perPage;
    final int total;
  Pageable({
    required this.page,
    required this.perPage,
    required this.total,
  });

    


  Pageable copyWith({
    int? page,
    int? perPage,
    int? total,
  }) {
    return Pageable(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'page': page,
      'perPage': perPage,
      'total': total,
    };
  }

  factory Pageable.fromMap(Map<String, dynamic> map) {
    return Pageable(
      page: map['page'] as int,
      perPage: map['perPage'] as int,
      total: map['total'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Pageable.fromJson(String source) => Pageable.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Pageable(page: $page, perPage: $perPage, total: $total)';

  @override
  bool operator ==(covariant Pageable other) {
    if (identical(this, other)) return true;
  
    return 
      other.page == page &&
      other.perPage == perPage &&
      other.total == total;
  }

  @override
  int get hashCode => page.hashCode ^ perPage.hashCode ^ total.hashCode;
}
