part of 'tips_cubit.dart';

abstract class TipsState extends Equatable {
  const TipsState();
}

class TipsInitial extends TipsState {
  @override
  List<Object> get props => [];
}

class TipsLoading extends TipsState {
  @override
  List<Object> get props => [];
}

class TipsLoaded extends TipsState {
  final TipsEntity tips;

  const TipsLoaded(this.tips);
  @override
  List<Object> get props => [tips];
}

class TipsFailure extends TipsState {
  @override
  List<Object> get props => [];
}
