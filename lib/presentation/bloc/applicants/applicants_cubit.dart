import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/domain/usecases/get_applicants_usecase.dart';
import 'package:jobless/domain/usecases/get_applicantsbymyvacancy_usecase.dart';
import 'package:jobless/domain/usecases/get_applicationfindone_usecase.dart';

part 'applicants_state.dart';

class ApplicantsCubit extends Cubit<ApplicantsState> {
  final ApplicationFindOneUseCase applicationFindOneUseCase;
  final ApplicantsUseCase applicantsUseCase;
  final ApplicantsByMyVacancyUseCase applicantsByMyVacancyUseCase;
  ApplicantsCubit(
      {required this.applicantsUseCase,
      required this.applicantsByMyVacancyUseCase,
      required this.applicationFindOneUseCase})
      : super(ApplicantsInitial());

  Future<void> getapplicants(int page, String params) async {
    try {
      emit(ApplicantsLoading());
      final applicantsStreamData = await applicantsUseCase.call(page, params);
      emit(ApplicantsLoaded(applicantsStreamData));
    } on SocketException catch (_) {
      emit(ApplicantsFailure());
    } catch (_) {
      emit(ApplicantsFailure());
    }
  }

  Future<void> getapplicantsByMyVacancy(int page, String params) async {
    try {
      emit(ApplicantsLoading());
      final applicantsStreamData =
          await applicantsByMyVacancyUseCase.call(page, params);
      emit(ApplicantsLoaded(applicantsStreamData));
    } on SocketException catch (_) {
      emit(ApplicantsFailure());
    } catch (_) {
      emit(ApplicantsFailure());
    }
  }

  Future<void> getApplicationFindOne(String params) async {
    emit(ApplicantsLoading());
    try {
      final applicantsStreamData = await applicationFindOneUseCase.call(params);
      emit(ApplicantionFindOneLoaded(applicantsStreamData));
    } on SocketException catch (_) {
      emit(ApplicantsFailure());
    } catch (_) {
      emit(ApplicantsFailure());
    }
  }
}
