import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'bookmarks_state.dart';

class BookmarksCubit extends Cubit<BookmarksState> {
  BookmarksCubit() : super(BookmarksState(bookmarks: [])) {
    bookmaksVacancies();
  }

  void bookmaksVacancies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('bookmarks') ?? [];
    emit(BookmarksState(bookmarks: result));
  }

  void postbookmarks(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('bookmarks');
    if (result == null) {
      prefs.setStringList('bookmarks', [id]);
    } else {
      if (result.where((e) => e == id).isEmpty) {
        result.add(id);
        prefs.setStringList('bookmarks', result);
      } else {
        int idx = result.indexWhere((element) => element == id);
        result.removeAt(idx);
        prefs.setStringList('bookmarks', result);
      }
    }
    var res = prefs.getStringList('bookmarks');
    emit(BookmarksState(bookmarks: res));
  }
}
