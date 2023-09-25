import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinInterviewUseCase {
  final Repository repository;

  JoinInterviewUseCase({required this.repository});

  Future<ResultModel> call({String? id, bool? join}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.joinInterview(
        token: ref.getString('token') ?? '', id: id, join: join);
  }
}
