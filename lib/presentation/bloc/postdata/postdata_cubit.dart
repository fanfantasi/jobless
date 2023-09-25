import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/result_entity.dart';
import 'package:jobless/domain/usecases/patch_applicants_usecase.dart';
import 'package:jobless/domain/usecases/vacancy/patch_vacancy_usecase.dart';
import 'package:jobless/domain/usecases/post_joinInterview_usecase.dart';
import 'package:jobless/domain/usecases/vacancy/post_inactive_usecase.dart';

part 'postdata_state.dart';

class PostDataCubit extends Cubit<PostDataState> {
  final PatchVacancyUseCase patchVacancyUseCase;
  final InactiveUseCase inactiveUseCase;
  final PatchApplicantsUseCase patchApplicantsUseCase;
  final JoinInterviewUseCase joinInterviewUseCase;
  PostDataCubit(
      {required this.patchVacancyUseCase,
      required this.patchApplicantsUseCase,
      required this.inactiveUseCase,
      required this.joinInterviewUseCase})
      : super(PostDataInitial());

  Future<bool> patchVacancy(
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
    try {
      emit(PostDataLoading());
      final streamDate = await patchVacancyUseCase.call(
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
      emit(PostDataLoaded(streamDate));
      if (streamDate.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(PostDataFailure());
      return false;
    } catch (_) {
      emit(PostDataFailure());
      return false;
    }
  }

  Future<bool> patchApplicants(
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
    try {
      emit(PostDataLoading());
      final streamDate = await patchApplicantsUseCase.call(
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
      emit(PostDataLoaded(streamDate));
      if (streamDate.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(PostDataFailure());
      return false;
    } catch (_) {
      emit(PostDataFailure());
      return false;
    }
  }

  Future<bool> joinInterview({
    String? id,
    bool? join,
  }) async {
    try {
      emit(PostDataLoading());
      final streamDate = await joinInterviewUseCase.call(id: id, join: join);
      emit(PostDataLoaded(streamDate));
      if (streamDate.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(PostDataFailure());
      return false;
    } catch (_) {
      emit(PostDataFailure());
      return false;
    }
  }

  Future<bool> inactivevacancy({
    String? id,
  }) async {
    try {
      emit(PostDataLoading());
      final streamDate = await inactiveUseCase.call(id: id);
      emit(PostDataLoaded(streamDate));
      if (streamDate.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(PostDataFailure());
      return false;
    } catch (_) {
      emit(PostDataFailure());
      return false;
    }
  }
}
