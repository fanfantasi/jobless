import 'package:shared_preferences/shared_preferences.dart';

class PostThemeUseCase {
  SharedPreferences? pref;
  PostThemeUseCase({required this.pref});

  final String key = "theme";
  bool? _darkTheme;

  _initPrefs() async {
    pref ??= await SharedPreferences.getInstance();
  }

  Future<void> call() async {
    await _initPrefs();
    pref!.setBool(key, _darkTheme!);
  }
}
