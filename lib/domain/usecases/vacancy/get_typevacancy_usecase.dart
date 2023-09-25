import 'package:jobless/data/model/typevacancy.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TypeVacancyUseCase {
  final Repository repository;

  TypeVacancyUseCase({required this.repository});

  Future<TypeVacancyModel> call(int page, int limit, String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.typevacancy(
        ref.getString('token') ?? '', page, limit, params);
  }
}
