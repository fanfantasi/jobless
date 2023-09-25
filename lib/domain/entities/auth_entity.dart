class AuthEntity {
  final String? error;
  final ResultAuthEntity? data;
  final String message;
  const AuthEntity({this.error, required this.data, required this.message});
}

class ResultAuthEntity {
  final String? accessToken;
  final String? refreshToken;
  const ResultAuthEntity({this.accessToken, this.refreshToken});
}
