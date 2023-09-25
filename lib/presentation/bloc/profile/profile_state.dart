part of 'profile_cubit.dart';

abstract class EmployeeProfileState extends Equatable {
  const EmployeeProfileState();
}

class EmployeeProfileInitial extends EmployeeProfileState {
  @override
  List<Object> get props => [];
}

class EmployeeProfileLoading extends EmployeeProfileState {
  @override
  List<Object> get props => [];
}

class EmployeeProfileLoaded extends EmployeeProfileState {
  final ResultEntity result;

  const EmployeeProfileLoaded(this.result);
  @override
  List<Object> get props => [result];
}

class EmployeeProfileFailure extends EmployeeProfileState {
  @override
  List<Object> get props => [];
}
