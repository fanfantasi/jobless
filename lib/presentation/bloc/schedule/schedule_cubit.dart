import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/applicants_entity.dart';
import 'package:jobless/domain/entities/schedule_entity.dart';
import 'package:jobless/domain/usecases/get_applicantsbymyvacancy_usecase.dart';
import 'package:jobless/domain/usecases/get_schedule.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleUseCase scheduleUseCase;
  final ApplicantsByMyVacancyUseCase applicantsUseCase;
  ScheduleCubit(
      {required this.scheduleUseCase, required this.applicantsUseCase})
      : super(ScheduleInitial());

  Future<void> getCalendar(String params) async {
    emit(ScheduleLoading());
    try {
      final notifStreamData = await scheduleUseCase.call(params);
      emit(ScheduleLoaded(notifStreamData));
    } on SocketException catch (_) {
      emit(ScheduleFailure());
    } catch (_) {
      emit(ScheduleFailure());
    }
  }

  Future<void> getapplicants(int page, String params) async {
    emit(ScheduleLoading());
    try {
      final applicantsStreamData = await applicantsUseCase.call(page, params);
      emit(ScheduleApplicantsLoaded(applicantsStreamData));
    } on SocketException catch (_) {
      emit(ScheduleFailure());
    } catch (_) {
      emit(ScheduleFailure());
    }
  }
}
