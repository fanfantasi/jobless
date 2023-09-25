import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'bell_state.dart';

class BellCubit extends Cubit<BellState> {
  BellCubit() : super(BellState(bell: false)) {
    initialBell();
  }

  void initialBell() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getBool('notif') ?? false;
    emit(BellState(bell: result));
  }

  void postBell(bool bell) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('bell', bell);
    emit(BellState(bell: bell));
  }
}
