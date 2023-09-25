import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/tips_entity.dart';
import 'package:jobless/domain/usecases/get_tips_usecase.dart';

part 'tips_state.dart';

class TipsCubit extends Cubit<TipsState> {
  final TipsUseCase tipsUseCase;
  TipsCubit({required this.tipsUseCase}) : super(TipsInitial());

  Future<void> gettips(int page, String params) async {
    try {
      emit(TipsLoading());
      final tipsStreamData = await tipsUseCase.call(page, params);
      emit(TipsLoaded(tipsStreamData));
    } on SocketException catch (_) {
      emit(TipsFailure());
    } catch (_) {
      emit(TipsFailure());
    }
  }
}
