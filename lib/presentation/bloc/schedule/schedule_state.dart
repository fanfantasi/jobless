part of 'schedule_cubit.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();
}

class ScheduleInitial extends ScheduleState {
  @override
  List<Object> get props => [];
}

class ScheduleLoading extends ScheduleState {
  @override
  List<Object> get props => [];
}

class ScheduleLoaded extends ScheduleState {
  final ScheduleEntity schedule;

  const ScheduleLoaded(this.schedule);
  @override
  List<Object> get props => [schedule];
}

class ScheduleApplicantsLoaded extends ScheduleState {
  final ApplicantsEntity applicants;

  const ScheduleApplicantsLoaded(this.applicants);
  @override
  List<Object> get props => [applicants];
}

class ScheduleFailure extends ScheduleState {
  @override
  List<Object> get props => [];
}
