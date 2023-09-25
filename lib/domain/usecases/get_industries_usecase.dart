import 'package:jobless/data/model/industries.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IndustriesUseCase {
  final Repository repository;

  IndustriesUseCase({required this.repository});

  Future<IndustriesModel> call(int page, int limit) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.industries(
        ref.getString('token') ?? '', page, limit);
  }
}
