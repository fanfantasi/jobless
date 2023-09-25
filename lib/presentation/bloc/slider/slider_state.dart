part of 'slider_cubit.dart';

abstract class SliderState extends Equatable {
  const SliderState();
}

class SliderInitial extends SliderState {
  @override
  List<Object> get props => [];
}

class SliderLoading extends SliderState {
  @override
  List<Object> get props => [];
}

class SliderLoaded extends SliderState {
  final TipsEntity tips;

  const SliderLoaded(this.tips);
  @override
  List<Object> get props => [tips];
}

class SliderFailure extends SliderState {
  @override
  List<Object> get props => [];
}
