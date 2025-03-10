import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SuccessResponseModel {
  final String message;
  final String status;
  final String localDateTime;
  SuccessResponseModel({
    required this.message,
    required this.status,
    required this.localDateTime,
  });
 

  SuccessResponseModel copyWith({
    String? message,
    String? status,
    String? localDateTime,
  }) {
    return SuccessResponseModel(
      message: message ?? this.message,
      status: status ?? this.status,
      localDateTime: localDateTime ?? this.localDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'status': status,
      'localDateTime': localDateTime,
    };
  }

  factory SuccessResponseModel.fromMap(Map<String, dynamic> map) {
    return SuccessResponseModel(
      message: map['message'] as String,
      status: map['status'] as String,
      localDateTime: map['localDateTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SuccessResponseModel.fromJson(String source) => SuccessResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SuccessResponseModel(message: $message, status: $status, localDateTime: $localDateTime)';

  @override
  bool operator ==(covariant SuccessResponseModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.message == message &&
      other.status == status &&
      other.localDateTime == localDateTime;
  }

  @override
  int get hashCode => message.hashCode ^ status.hashCode ^ localDateTime.hashCode;
}
