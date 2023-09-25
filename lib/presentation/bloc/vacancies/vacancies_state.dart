part of 'vacancies_cubit.dart';

abstract class VacanciesState extends Equatable {
  const VacanciesState();
}

class VacanciesInitial extends VacanciesState {
  @override
  List<Object> get props => [];
}

class VacanciesLoading extends VacanciesState {
  @override
  List<Object> get props => [];
}

class VacanciesLoaded extends VacanciesState {
  final VacanciesEntity vacancies;

  const VacanciesLoaded(this.vacancies);
  @override
  List<Object> get props => [vacancies];
}

class VacanciesFailure extends VacanciesState {
  @override
  List<Object> get props => [];
}
