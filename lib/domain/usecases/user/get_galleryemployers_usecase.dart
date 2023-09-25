import 'package:jobless/data/model/gallery.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetGalleryEmployersUseCase {
  final Repository repository;

  GetGalleryEmployersUseCase({required this.repository});

  Future<GalleryModel> call(
    String id,
  ) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.galleryEmployers(
        token: ref.getString('token') ?? '', id: id);
  }
}
