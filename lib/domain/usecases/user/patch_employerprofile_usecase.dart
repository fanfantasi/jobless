import 'dart:io';

import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployersProfileUseCase {
  final Repository repository;

  EmployersProfileUseCase({required this.repository});

  Future<ResultModel> call(
      {String? email,
      String? companyname,
      String? address,
      String? officelocation,
      String? industryId,
      String? industrytypeId,
      String? companySize,
      String? website,
      String? desc,
      File? file,
      String? oldFile}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.pathEmployerProfile(
        token: ref.getString('token') ?? '',
        email: email,
        companyname: companyname,
        officelocation: officelocation,
        address: address,
        industryId: industryId,
        industrytypeId: industrytypeId,
        companySize: companySize,
        website: website,
        desc: desc,
        oldFile: oldFile,
        file: file);
  }
}
