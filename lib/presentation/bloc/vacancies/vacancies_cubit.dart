import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/domain/usecases/vacancy/get_vancancies_usecase.dart';

part 'vacancies_state.dart';

class VacanciesCubit extends Cubit<VacanciesState> {
  final VacanciesUseCase vacanciesUseCase;
  VacanciesCubit({required this.vacanciesUseCase}) : super(VacanciesInitial());

  Future<void> recommendations(int page, String params) async {
    emit(VacanciesLoading());
    try {
      final vacanciesStreamData = await vacanciesUseCase.call(page, params);
      emit(VacanciesLoaded(vacanciesStreamData));
    } on SocketException catch (_) {
      emit(VacanciesFailure());
    } catch (_) {
      emit(VacanciesFailure());
    }
  }

  Future<void> getvacancies(int page, String params) async {
    emit(VacanciesLoading());
    try {
      final vacanciesStreamData = await vacanciesUseCase.call(page, params);
      emit(VacanciesLoaded(vacanciesStreamData));
    } on SocketException catch (_) {
      emit(VacanciesFailure());
    } catch (_) {
      emit(VacanciesFailure());
    }
  }
}
