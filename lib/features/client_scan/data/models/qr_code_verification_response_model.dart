import 'dart:convert';

class QrCodeVerificationResponseModel {
  final String message;
  final String status;
  final String localDateTime;
  final QrCodeVerificationBody? body;

  QrCodeVerificationResponseModel({
    required this.message,
    required this.status,
    required this.localDateTime,
    this.body,
  });

  QrCodeVerificationResponseModel copyWith({
    String? message,
    String? status,
    String? localDateTime,
    QrCodeVerificationBody? body,
  }) {
    return QrCodeVerificationResponseModel(
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

  factory QrCodeVerificationResponseModel.fromMap(Map<String, dynamic> map) {
    return QrCodeVerificationResponseModel(
      message: map['message'] as String,
      status: map['status'] as String,
      localDateTime: map['localDateTime'] as String,
      body: map['body'] != null
          ? QrCodeVerificationBody.fromMap(map['body'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory QrCodeVerificationResponseModel.fromJson(String source) =>
      QrCodeVerificationResponseModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'QrCodeVerificationResponseModel(message: $message, status: $status, localDateTime: $localDateTime, body: $body)';
  }
}

class QrCodeVerificationBody {
  final String? uuid;
  final String qrCode;
  final String qrCodeType;
  final String createdAt;

  QrCodeVerificationBody({
    this.uuid,
    required this.qrCode,
    required this.qrCodeType,
    required this.createdAt,
  });

  QrCodeVerificationBody copyWith({
    String? uuid,
    String? qrCode,
    String? qrCodeType,
    String? createdAt,
  }) {
    return QrCodeVerificationBody(
      uuid: uuid ?? this.uuid,
      qrCode: qrCode ?? this.qrCode,
      qrCodeType: qrCodeType ?? this.qrCodeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'qrCode': qrCode,
      'qrCodeType': qrCodeType,
      'createdAt': createdAt,
    };
  }

  factory QrCodeVerificationBody.fromMap(Map<String, dynamic> map) {
    return QrCodeVerificationBody(
      uuid: map['uuid'] as String?,
      qrCode: map['qrCode'] as String,
      qrCodeType: map['qrCodeType'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory QrCodeVerificationBody.fromJson(String source) =>
      QrCodeVerificationBody.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'QrCodeVerificationBody(uuid: $uuid, qrCode: $qrCode, qrCodeType: $qrCodeType, createdAt: $createdAt)';
  }
}

