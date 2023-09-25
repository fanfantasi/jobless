import 'dart:io';

import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeProfileUseCase {
  final Repository repository;

  EmployeeProfileUseCase({required this.repository});

  Future<ResultModel> call(
      {Object? jobcategories,
      String? fullname,
      String? dateofbirth,
      String? address,
      String? skill,
      String? gender,
      File? photo,
      String? oldPhoto}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.patchEmployeeProfile(
        token: ref.getString('token') ?? '',
        jobcategories: jobcategories,
        fullname: fullname,
        dateofbirth: dateofbirth,
        address: address,
        gender: gender,
        skill: skill,
        oldPhoto: oldPhoto,
        photo: photo);
  }
}
