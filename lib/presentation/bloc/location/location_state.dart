part of 'location_cubit.dart';

abstract class LocationState extends Equatable {
  const LocationState();
}

class LocationInitial extends LocationState {
  @override
  List<Object> get props => [];
}

class LocationLoading extends LocationState {
  @override
  List<Object> get props => [];
}

class LocationLoaded extends LocationState {
  final LocationEntity location;

  const LocationLoaded(this.location);
  @override
  List<Object> get props => [location];
}

class LocationFailure extends LocationState {
  @override
  List<Object> get props => [];
}
