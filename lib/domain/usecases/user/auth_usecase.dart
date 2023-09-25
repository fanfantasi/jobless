import 'package:jobless/data/model/auth.dart';
import 'package:jobless/domain/repositories/repository.dart';

class AuthUseCase {
  final Repository repository;

  AuthUseCase({required this.repository});

  Future<AuthModel> call(String email, String password) async {
    return await repository.authUser(email, password);
  }
}
