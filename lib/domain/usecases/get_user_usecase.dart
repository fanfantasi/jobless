import 'package:jobless/data/model/user.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserUseCase {
  final Repository repository;

  UserUseCase({required this.repository});

  Future<UserModel> call() async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.isSignIn(ref.getString('token') ?? '');
  }
}
