import 'dart:convert';

import 'package:flutter/foundation.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
abstract class Failures {}

class ForbiddenFailure extends Failures {
  final String message;
  ForbiddenFailure({
    required this.message,
  });
}

class OfflineFailure extends Failures {}

class ServerFailure extends Failures {
  final String message;
  ServerFailure({
    required this.message,
  });
}

class NoDataFailure implements Failures {
  final String message;
  NoDataFailure({
    required this.message,
  });
}

class LoginFailure implements Failures {
  final String message;
  LoginFailure({
    required this.message,
  });
}

class AddNewAdminFailure implements Failures {
  final List<String> messages;
  AddNewAdminFailure({
    required this.messages,
  });

  AddNewAdminFailure copyWith({
    List<String>? messages,
  }) {
    return AddNewAdminFailure(
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'messages': messages,
    };
  }

  factory AddNewAdminFailure.fromMap(Map<String, dynamic> map) {
    print("shit fromMap");
    return AddNewAdminFailure(
      messages: List<String>.from(
        (map['messages'] as List<String>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory AddNewAdminFailure.fromJson(String source) =>
      AddNewAdminFailure.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AddNewAdminFailure(messages: $messages)';

  @override
  bool operator ==(covariant AddNewAdminFailure other) {
    if (identical(this, other)) return true;

    return listEquals(other.messages, messages);
  }

  @override
  int get hashCode => messages.hashCode;
}
