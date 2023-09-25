import 'package:jobless/data/model/applicants.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicantsByMyVacancyUseCase {
  final Repository repository;

  ApplicantsByMyVacancyUseCase({required this.repository});

  Future<ApplicantsModel> call(
    int page,
    String params,
  ) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.getApplicantsByMyVacancies(
        token: ref.getString('token') ?? '', page: page, params: params);
  }
}
