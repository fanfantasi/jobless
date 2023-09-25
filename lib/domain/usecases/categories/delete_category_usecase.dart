import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteCategoriesUseCase {
  final Repository repository;

  DeleteCategoriesUseCase({required this.repository});

  Future<ResultModel> call({String? id}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.deletecategories(
        token: ref.getString('token') ?? '', id: id);
  }
}
