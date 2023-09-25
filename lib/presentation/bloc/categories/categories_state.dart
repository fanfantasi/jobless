part of 'categories_cubit.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  @override
  List<Object> get props => [];
}

class CategoriesLoading extends CategoriesState {
  @override
  List<Object> get props => [];
}

class CategoriesLoaded extends CategoriesState {
  final CategoriesEntity categories;

  const CategoriesLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoriesFailure extends CategoriesState {
  @override
  List<Object> get props => [];
}
