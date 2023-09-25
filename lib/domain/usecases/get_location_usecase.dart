import 'package:jobless/data/model/location.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationUseCase {
  final Repository repository;

  LocationUseCase({required this.repository});

  Future<LocationModel> call(int page, int limit, String params) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.locaton(
        ref.getString('token') ?? '', page, limit, params);
  }
}
