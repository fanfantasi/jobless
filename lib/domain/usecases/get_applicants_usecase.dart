import 'package:jobless/data/model/applicants.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicantsUseCase {
  final Repository repository;

  ApplicantsUseCase({required this.repository});

  Future<ApplicantsModel> call(
    int page,
    String params,
  ) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.getApplicants(
        token: ref.getString('token') ?? '', page: page, params: params);
  }
}
