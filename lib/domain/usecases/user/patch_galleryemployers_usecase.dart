import 'dart:io';

import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryEmployersUseCase {
  final Repository repository;

  GalleryEmployersUseCase({required this.repository});

  Future<ResultModel> call(
      {String? employersId, File? file, String? oldFile}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.uploadGalleryEmployers(
        token: ref.getString('token') ?? '',
        employersId: employersId,
        oldFile: oldFile,
        file: file);
  }
}
