import 'dart:io';

import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatchVacancyUseCase {
  final Repository repository;

  PatchVacancyUseCase({required this.repository});

  Future<ResultModel> call(
      {String? id,
      String? title,
      String? categoriId,
      String? salary,
      String? locationId,
      String? typevacancyId,
      String? desc,
      Object? requirements,
      String? linkexternal,
      File? file,
      String? oldFile,
      String? status}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.patchvancancy(
        token: ref.getString('token') ?? '',
        id: id,
        title: title,
        categoriId: categoriId,
        salary: salary,
        locationId: locationId,
        typevacancyId: typevacancyId,
        desc: desc,
        linkexternal: linkexternal,
        requirements: requirements,
        oldFile: oldFile,
        file: file,
        status: status);
  }
}
