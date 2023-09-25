import 'package:jobless/data/model/tips.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TipsUseCase {
  final Repository repository;

  TipsUseCase({required this.repository});

  Future<TipsModel> call(int page, String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.tips(ref.getString('token') ?? '', page, params);
  }
}
