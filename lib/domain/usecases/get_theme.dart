import 'package:shared_preferences/shared_preferences.dart';

class GetThemeUseCase {
  SharedPreferences? pref;
  GetThemeUseCase({required this.pref});

  final String key = "theme";
  bool? _darkTheme;

  bool? get darkTheme => _darkTheme;

  _initPrefs() async {
    pref ??= await SharedPreferences.getInstance();
  }

  Future<bool> call() async {
    await _initPrefs();
    _darkTheme = pref!.getBool(key) ?? false;
    return _darkTheme!;
  }
}
