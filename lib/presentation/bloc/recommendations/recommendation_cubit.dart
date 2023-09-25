import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/vacancies_entity.dart';
import 'package:jobless/domain/usecases/vacancy/get_vancancies_usecase.dart';

part 'recommendation_state.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  final VacanciesUseCase vacanciesUseCase;
  RecommendationCubit({required this.vacanciesUseCase})
      : super(RecommendationInitial());

  Future<void> recommendations(int page, String params) async {
    emit(RecommendationLoading());
    try {
      final vacanciesStreamData = await vacanciesUseCase.call(page, params);
      emit(RecommendationLoaded(vacanciesStreamData));
    } on SocketException catch (_) {
      emit(RecommendationFailure());
    } catch (_) {
      emit(RecommendationFailure());
    }
  }
}
