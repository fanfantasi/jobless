part of 'industries_cubit.dart';

abstract class IndustriesState extends Equatable {
  const IndustriesState();
}

class IndustriesInitial extends IndustriesState {
  @override
  List<Object> get props => [];
}

class IndustriesLoading extends IndustriesState {
  @override
  List<Object> get props => [];
}

class IndustriesLoaded extends IndustriesState {
  final IndustriesEntity industries;

  const IndustriesLoaded(this.industries);
  @override
  List<Object> get props => [industries];
}

class IndustriesFailure extends IndustriesState {
  @override
  List<Object> get props => [];
}
