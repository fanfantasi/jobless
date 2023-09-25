import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/data/model/auth.dart';
import 'package:jobless/data/model/user.dart';
import 'package:jobless/domain/entities/auth_entity.dart';
import 'package:jobless/domain/usecases/user/auth_usecase.dart';
import 'package:jobless/domain/usecases/get_user_usecase.dart';
import 'package:jobless/domain/usecases/user/signout_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthUseCase authUseCase;
  final UserUseCase userUseCase;
  final SignOutUseCase signOutUseCase;

  AuthCubit(
      {required this.authUseCase,
      required this.userUseCase,
      required this.signOutUseCase})
      : super(AuthInitial());

  AuthModel? auth;

  Future<void> isSignIn({bool isSubscribe = false}) async {
    try {
      final userStreamData = await userUseCase.call();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profile', jsonEncode(userStreamData.data));
      if (isSubscribe) {
        await FirebaseMessaging.instance
            .unsubscribeFromTopic(userStreamData.data.id!);
        //
        await FirebaseMessaging.instance
            .subscribeToTopic(userStreamData.data.id!);
      }

      emit(Authenticated(user: userStreamData));
    } on SocketException catch (_) {
      emit(UnAuthenticated());
    } catch (_) {
      emit(UnAuthenticated());
    }
  }

  Future<bool> signOut({String? email, String? password}) async {
    try {
      auth = await signOutUseCase.call(email!, password!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', auth!.data!.accessToken!);
      prefs.setString('refreshtoken', auth!.data!.refreshToken!);
      emit(AuthLoaded(auth!));
      if (auth!.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(AuthFailure());
      return false;
    } catch (_) {
      emit(AuthFailure());
      return false;
    }
  }

  Future<bool> signIn({String? email, String? password}) async {
    try {
      auth = await authUseCase.call(email!, password!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', auth!.data!.accessToken!);
      prefs.setString('refreshtoken', auth!.data!.refreshToken!);
      emit(AuthLoaded(auth!));
      if (auth!.error == null) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      emit(AuthFailure());
      return false;
    } catch (_) {
      emit(AuthFailure());
      return false;
    }
  }
}
