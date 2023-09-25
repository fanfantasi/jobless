import 'dart:io';

import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoProfileEmployersUseCase {
  final Repository repository;

  PhotoProfileEmployersUseCase({required this.repository});

  Future<ResultModel> call({File? file, String? oldFile}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.updatePhotoProfileEmployers(
        token: ref.getString('token') ?? '', oldFile: oldFile, file: file);
  }
}
