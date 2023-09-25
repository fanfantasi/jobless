part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  @override
  List<Object> get props => [];
}

class NotificationLoading extends NotificationState {
  @override
  List<Object> get props => [];
}

class NotificationLoaded extends NotificationState {
  final NotificationEntity notification;

  const NotificationLoaded(this.notification);
  @override
  List<Object> get props => [notification];
}

class NotificationFailure extends NotificationState {
  @override
  List<Object> get props => [];
}
