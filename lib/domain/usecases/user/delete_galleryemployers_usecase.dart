import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteGalleryEmployersUseCase {
  final Repository repository;

  DeleteGalleryEmployersUseCase({required this.repository});

  Future<ResultModel> call(
    String id,
  ) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.deletegalleryEmployers(
        token: ref.getString('token') ?? '', id: id);
  }
}
