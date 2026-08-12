import 'package:flutter/foundation.dart';
import 'package:mandarinho/core_models.dart';

class SearchViewModel extends ChangeNotifier {
  String query = "";
  List<DictionaryEntry> results = [];
  bool searching = false;

  // TODO: Thread safety
  void setSearch(String query) async {
    searching = true;
    this.query = query;
    results = [];
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    searching = false;
    results = [
      DictionaryEntry(
        hanziSimplified: "你好",
        piyin: "nǐhǎo",
        translations: [
          Translation(portuguese: ["Olá", "Tudo bem?"]),
        ],
      ),
    ];
    notifyListeners();
  }
}
