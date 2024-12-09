// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Forbidden implements Exception{}

class NoData implements Exception {
  final String message;
  NoData({
    required this.message,
  });
}

class BAD_REQUEST implements Exception {
  final String message;
  final String status;
  final String localDateTime;
  BAD_REQUEST({
    required this.message,
    required this.status,
    required this.localDateTime,
  });

  BAD_REQUEST copyWith({
    String? message,
    String? status,
    String? localDateTime,
  }) {
    return BAD_REQUEST(
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

  factory BAD_REQUEST.fromMap(Map<String, dynamic> map) {
    return BAD_REQUEST(
      message: map['message'] as String,
      status: map['status'] as String,
      localDateTime: map['localDateTime'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BAD_REQUEST.fromJson(String source) => BAD_REQUEST.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BAD_REQUEST(message: $message, status: $status, localDateTime: $localDateTime)';

  @override
  bool operator ==(covariant BAD_REQUEST other) {
    if (identical(this, other)) return true;
  
    return 
      other.message == message &&
      other.status == status &&
      other.localDateTime == localDateTime;
  }

  @override
  int get hashCode => message.hashCode ^ status.hashCode ^ localDateTime.hashCode;
}

