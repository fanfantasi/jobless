import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/industries_entity.dart';
import 'package:jobless/domain/usecases/get_industries_usecase.dart';

part 'industries_state.dart';

class IndustriesCubit extends Cubit<IndustriesState> {
  final IndustriesUseCase industriesUseCase;
  IndustriesCubit({required this.industriesUseCase})
      : super(IndustriesInitial());

  Future<void> getIndustries(int page, int limit) async {
    try {
      emit(IndustriesLoading());
      final industriesStreamData = await industriesUseCase.call(page, limit);
      emit(IndustriesLoaded(industriesStreamData));
    } on SocketException catch (_) {
      emit(IndustriesFailure());
    } catch (_) {
      emit(IndustriesFailure());
    }
  }
}
