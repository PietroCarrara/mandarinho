import 'package:sqlite_async/sqlite_async.dart';

class DictionaryEntry {
  final String hanziSimplified;
  final String piyin;
  final List<Translation> translations;

  DictionaryEntry({
    required this.hanziSimplified,
    required this.piyin,
    required this.translations,
  });

  static Future<List<DictionaryEntry>> search(
    SqliteConnection db,
    String query,
  ) async {
    final sqlResults = await db.getAll(
      "SELECT dictionary_entry_id, hanzi_simplified, pinyin FROM dictionary_entries WHERE pinyin_ascii LIKE ? OR hanzi_simplified LIKE ?;",
      ['%$query%', '%$query%'],
    );

    final List<DictionaryEntry> results = [];
    final mapping = <int, DictionaryEntry>{};

    for (final row in sqlResults) {
      final int id = row['dictionary_entry_id'];

      if (!mapping.containsKey(id)) {
        final entry = DictionaryEntry(
          hanziSimplified: row['hanzi_simplified'],
          piyin: row['pinyin'],
          translations: [],
        );
        mapping[id] = entry;
        results.add(entry);
      }
    }

    return results;
  }
}

class Translation {
  final List<String> portuguese;

  Translation({required this.portuguese});
}
