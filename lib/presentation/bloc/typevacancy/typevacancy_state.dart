part of 'typevacancy_cubit.dart';

abstract class TypeVacancyState extends Equatable {
  const TypeVacancyState();
}

class TypeVacancyInitial extends TypeVacancyState {
  @override
  List<Object> get props => [];
}

class TypeVacancyLoading extends TypeVacancyState {
  @override
  List<Object> get props => [];
}

class TypeVacancyLoaded extends TypeVacancyState {
  final TypeVacancyEntity typevacancy;

  const TypeVacancyLoaded(this.typevacancy);
  @override
  List<Object> get props => [typevacancy];
}

class TypeVacancyFailure extends TypeVacancyState {
  @override
  List<Object> get props => [];
}
