import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/domain/entities/notification_entity.dart';
import 'package:jobless/domain/usecases/get_notification_usecase.dart';
import 'package:jobless/domain/usecases/put_updatereadnotification_usecase.dart';
part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationUseCase notificationUseCase;
  final UpdateReadNotificationUseCase updateReadNotificationUseCase;
  NotificationCubit(
      {required this.notificationUseCase,
      required this.updateReadNotificationUseCase})
      : super(NotificationInitial());

  Future<void> notification(int page, String params) async {
    emit(NotificationLoading());
    try {
      final notifStreamData = await notificationUseCase.call(page, params);
      emit(NotificationLoaded(notifStreamData));
    } on SocketException catch (_) {
      emit(NotificationFailure());
    } catch (_) {
      emit(NotificationFailure());
    }
  }

  Future<bool> updateReadNotification(String params) async {
    try {
      await updateReadNotificationUseCase.call(params).then((value) {
        if (value.error != null) {
          return false;
        }
        return true;
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}
