part of 'recommendation_cubit.dart';

abstract class RecommendationState extends Equatable {
  const RecommendationState();
}

class RecommendationInitial extends RecommendationState {
  @override
  List<Object> get props => [];
}

class RecommendationLoading extends RecommendationState {
  @override
  List<Object> get props => [];
}

class RecommendationLoaded extends RecommendationState {
  final VacanciesEntity vacancies;

  const RecommendationLoaded(this.vacancies);
  @override
  List<Object> get props => [vacancies];
}

class RecommendationFailure extends RecommendationState {
  @override
  List<Object> get props => [];
}
