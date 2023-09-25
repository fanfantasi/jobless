import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/tips_entity.dart';
import 'package:jobless/domain/usecases/get_tips_usecase.dart';

part 'slider_state.dart';

class SliderCubit extends Cubit<SliderState> {
  final TipsUseCase tipsUseCase;
  SliderCubit({required this.tipsUseCase}) : super(SliderInitial());

  Future<void> gettips(int page, String params) async {
    emit(SliderLoading());
    try {
      final tipsStreamData = await tipsUseCase.call(page, params);
      emit(SliderLoaded(tipsStreamData));
    } on SocketException catch (_) {
      emit(SliderFailure());
    } catch (_) {
      emit(SliderFailure());
    }
  }
}
