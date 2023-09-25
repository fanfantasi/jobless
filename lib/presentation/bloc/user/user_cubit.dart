import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jobless/data/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserState(user: null)) {
    initialUser();
  }

  ResultUserModel? user;

  void initialUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = jsonDecode(jsonEncode(prefs.getString('profile').toString()));
    user = ResultUserModel.fromJSON(jsonDecode(result));
    emit(UserState(user: user));
  }
}
