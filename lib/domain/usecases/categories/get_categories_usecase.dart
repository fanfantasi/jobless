import 'package:jobless/data/model/categories.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesUseCase {
  final Repository repository;

  CategoriesUseCase({required this.repository});

  Future<CategoriesModel> call(
    int page,
    int limit,
    String params,
  ) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.categories(
        ref.getString('token') ?? '', page, limit, params);
  }
}
