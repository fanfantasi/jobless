import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/data/model/result.dart';
import 'package:jobless/domain/entities/result_entity.dart';
import 'package:jobless/domain/usecases/user/patch_employeeprofile_usecase.dart';
import 'package:jobless/domain/usecases/user/patch_employerprofile_usecase.dart';
import 'package:jobless/domain/usecases/user/patch_galleryemployers_usecase.dart';
import 'package:jobless/domain/usecases/user/patch_photoprofile_usecase.dart';

part 'profile_state.dart';

class EmployeeProfileCubit extends Cubit<EmployeeProfileState> {
  final EmployeeProfileUseCase employeeProfileUseCase;
  final EmployersProfileUseCase employersProfileUseCase;
  final PhotoProfileEmployersUseCase photoProfileEmployersUseCase;
  final GalleryEmployersUseCase galleryEmployersUseCase;
  EmployeeProfileCubit(
      {required this.employeeProfileUseCase,
      required this.photoProfileEmployersUseCase,
      required this.galleryEmployersUseCase,
      required this.employersProfileUseCase})
      : super(EmployeeProfileInitial());

  ResultEntity? result;

  Future<bool> patchEmployeeProfile(
      {Object? jobcategories,
      String? fullname,
      String? dateofbirth,
      String? address,
      String? skill,
      String? gender,
      File? photo,
      String? oldPhoto}) async {
    try {
      emit(EmployeeProfileLoading());
      result = await employeeProfileUseCase.call(
          jobcategories: jobcategories,
          fullname: fullname,
          dateofbirth: dateofbirth,
          address: address,
          gender: gender,
          skill: skill,
          oldPhoto: oldPhoto,
          photo: photo);
      emit(EmployeeProfileLoaded(result!));
      if (result!.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(EmployeeProfileFailure());
      return false;
    } catch (_) {
      emit(EmployeeProfileFailure());
      return false;
    }
  }

  Future<bool> patchEmployersProfile(
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
    try {
      emit(EmployeeProfileLoading());
      result = await employersProfileUseCase.call(
          email: email,
          companyname: companyname,
          address: address,
          officelocation: officelocation,
          industryId: industryId,
          industrytypeId: industrytypeId,
          companySize: companySize,
          website: website,
          desc: desc,
          oldFile: oldFile,
          file: file);
      emit(EmployeeProfileLoaded(result!));
      if (result!.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(EmployeeProfileFailure());
      return false;
    } catch (_) {
      emit(EmployeeProfileFailure());
      return false;
    }
  }

  Future<ResultEntity> patchPhotoProfileEmployers(
      {File? file, String? oldFile}) async {
    emit(EmployeeProfileLoading());
    ResultModel? res;
    try {
      res =
          await photoProfileEmployersUseCase.call(oldFile: oldFile, file: file);
      emit(EmployeeProfileLoaded(res));
      return res;
    } on SocketException catch (_) {
      emit(EmployeeProfileFailure());
      return res!;
    } catch (_) {
      emit(EmployeeProfileFailure());
      return res!;
    }
  }

  Future<ResultEntity?> patchGalleryEmployers(
      {String? employersId, File? file, String? oldFile}) async {
    emit(EmployeeProfileLoading());
    ResultModel? res;
    try {
      res = await galleryEmployersUseCase.call(
          employersId: employersId, oldFile: oldFile, file: file);
      emit(EmployeeProfileLoaded(res));
      return res;
    } on SocketException catch (_) {
      emit(EmployeeProfileFailure());
      return res!;
    } catch (_) {
      emit(EmployeeProfileFailure());
      return res!;
    }
  }
}
