import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostCategoriesUseCase {
  final Repository repository;

  PostCategoriesUseCase({required this.repository});

  Future<ResultModel> call({String? id, String? category}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.postcategories(
        token: ref.getString('token') ?? '', id: id, category: category);
  }
}
