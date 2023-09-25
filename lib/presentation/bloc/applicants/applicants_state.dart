part of 'applicants_cubit.dart';

abstract class ApplicantsState extends Equatable {
  const ApplicantsState();
}

class ApplicantsInitial extends ApplicantsState {
  @override
  List<Object> get props => [];
}

class ApplicantsLoading extends ApplicantsState {
  @override
  List<Object> get props => [];
}

class ApplicantsLoaded extends ApplicantsState {
  final ApplicantsEntity applicants;

  const ApplicantsLoaded(this.applicants);
  @override
  List<Object> get props => [applicants];
}

class ApplicantionFindOneLoaded extends ApplicantsState {
  final ResultApplicantsEntity applicant;

  const ApplicantionFindOneLoaded(this.applicant);
  @override
  List<Object> get props => [applicant];
}

class ApplicantsFailure extends ApplicantsState {
  @override
  List<Object> get props => [];
}
