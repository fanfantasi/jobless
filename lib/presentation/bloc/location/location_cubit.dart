import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/location_entity.dart';
import 'package:jobless/domain/usecases/get_location_usecase.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationUseCase locationUseCase;
  LocationCubit({required this.locationUseCase}) : super(LocationInitial());

  Future<void> getLocation(int page, int limit, String params) async {
    try {
      emit(LocationLoading());
      final industriesStreamData =
          await locationUseCase.call(page, limit, params);
      emit(LocationLoaded(industriesStreamData));
    } on SocketException catch (_) {
      emit(LocationFailure());
    } catch (_) {
      emit(LocationFailure());
    }
  }
}
