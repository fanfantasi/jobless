import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/typevacancy_entity.dart';
import 'package:jobless/domain/usecases/vacancy/get_typevacancy_usecase.dart';

part 'typevacancy_state.dart';

class TypeVacancyCubit extends Cubit<TypeVacancyState> {
  final TypeVacancyUseCase typeVacancyUseCase;
  TypeVacancyCubit({required this.typeVacancyUseCase})
      : super(TypeVacancyInitial());

  Future<void> gettypevacancy(int page, int limit, String params) async {
    try {
      emit(TypeVacancyLoading());
      final industriesStreamData =
          await typeVacancyUseCase.call(page, limit, params);
      emit(TypeVacancyLoaded(industriesStreamData));
    } on SocketException catch (_) {
      emit(TypeVacancyFailure());
    } catch (_) {
      emit(TypeVacancyFailure());
    }
  }
}
