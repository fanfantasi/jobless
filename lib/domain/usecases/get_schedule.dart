import 'package:jobless/data/model/schedule.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleUseCase {
  final Repository repository;

  ScheduleUseCase({required this.repository});

  Future<ScheduleModel> call(String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.getSchedule(
        token: ref.getString('token') ?? '', params: params);
  }
}
