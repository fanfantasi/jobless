import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateReadNotificationUseCase {
  final Repository repository;

  UpdateReadNotificationUseCase({required this.repository});

  Future<ResultModel> call(String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.updateReadNotification(
        ref.getString('token') ?? '', params);
  }
}
