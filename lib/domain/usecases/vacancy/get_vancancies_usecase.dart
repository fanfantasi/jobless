import 'package:jobless/data/model/vacancies.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VacanciesUseCase {
  final Repository repository;

  VacanciesUseCase({required this.repository});

  Future<VacanciesModel> call(int page, String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.vacancies(
        ref.getString('token') ?? '', page, params);
  }
}
