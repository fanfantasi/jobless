import 'package:jobless/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  AuthModel.fromJSON(Map<String, dynamic> json)
      : super(
          error: json['error'],
          message: json['message'],
          data: json['data'] == null
              ? null
              : ResultAuthModel.fromJSON(json['data'] ?? {}),
        );
}

class ResultAuthModel extends ResultAuthEntity {
  ResultAuthModel.fromJSON(Map<String, dynamic> json)
      : super(
            accessToken: json['accessToken'],
            refreshToken: json['refreshToken']);
}
