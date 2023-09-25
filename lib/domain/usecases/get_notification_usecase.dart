import 'package:jobless/data/model/notification.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationUseCase {
  final Repository repository;

  NotificationUseCase({required this.repository});

  Future<NotificationModel> call(int page, String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.getNotification(
        ref.getString('token') ?? '', page, params);
  }
}
