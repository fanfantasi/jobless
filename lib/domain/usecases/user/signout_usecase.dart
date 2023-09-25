import 'package:jobless/data/model/auth.dart';
import 'package:jobless/domain/repositories/repository.dart';

class SignOutUseCase {
  final Repository repository;

  SignOutUseCase({required this.repository});

  Future<AuthModel> call(String email, String password) async {
    return await repository.signOut(email, password);
  }
}
