import 'dart:io';

import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/repositories/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatchApplicantsUseCase {
  final Repository repository;

  PatchApplicantsUseCase({required this.repository});

  Future<ResultModel> call(
      {String? id,
      String? applicantId,
      String? vacancyId,
      String? desc,
      String? status,
      String? interviewdate,
      String? interviewtime,
      String? message,
      File? file,
      String? oldFile}) async {
    SharedPreferences ref = await SharedPreferences.getInstance();
    return await repository.patchApplicants(
        token: ref.getString('token') ?? '',
        id: id,
        applicantId: applicantId,
        vacancyId: vacancyId,
        desc: desc,
        status: status,
        interviewdate: interviewdate,
        interviewtime: interviewtime,
        message: message,
        oldFile: oldFile,
        file: file);
  }
}
