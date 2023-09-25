import 'package:jobless/data/model/applicants.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationFindOneUseCase {
  final Repository repository;

  ApplicationFindOneUseCase({required this.repository});

  Future<ResultApplicantsModel> call(
    String params,
  ) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.getApplicationFindOne(
        token: ref.getString('token') ?? '', params: params);
  }
}
