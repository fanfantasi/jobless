part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated({required this.user});
  @override
  List<Object> get props => [];
}

class UnAuthenticated extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoaded extends AuthState {
  final AuthEntity authEntity;

  const AuthLoaded(this.authEntity);
  @override
  List<Object> get props => [authEntity];
}

class AuthFailure extends AuthState {
  @override
  List<Object> get props => [];
}
