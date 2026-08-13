import 'package:flutter/widgets.dart';
import 'package:mandarinho/core_models.dart';
import 'package:sqlite_async/sqlite_async.dart';

class SearchViewModel extends ChangeNotifier {
  String query = "";
  List<DictionaryEntry> results = [];
  bool searching = false;

  // TODO: Thread safety
  // Query formats: "你好", "nihao", "ni3hao3", "ni3好", "yidianr"/"yidianer"
  void setSearch(String query, SqliteDatabase db) async {
    searching = true;
    this.query = query;
    results = [];
    notifyListeners();

    results = await DictionaryEntry.search(db, query);
    searching = false;
    notifyListeners();
  }
}
