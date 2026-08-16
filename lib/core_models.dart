import 'package:sqlite_async/sqlite_async.dart';

class DictionaryEntry {
  final String hanziSimplified;
  final String piyin;
  final String pinyinNumeric;
  final int? hsk;
  final List<Translation> translations;

  DictionaryEntry({
    required this.hanziSimplified,
    required this.piyin,
    required this.pinyinNumeric,
    required this.hsk,
    required this.translations,
  });

  // Query formats: "你好", "nihao", "ni hao", "ni3hao3", "estudar", "eStUdAr", "agua", "água ", "我很喜欢学习", "我很 喜欢 学习 中文", "ni3好", "yidianr"/"yidianer"
  static Future<List<DictionaryEntry>> search(
    SqliteConnection db,
    String query,
  ) async {
    query = query.trim();

    if (query == "") {
      return [];
    }

    final sqlResults = await db.getAll(
      """
        SELECT de.dictionary_entry_id, de.hanzi_simplified, de.pinyin, de.pinyin_numeric, de.hsk, t.portuguese_translation, t.grammatical_class
        FROM dictionary_entries de
        INNER JOIN translations t ON de.dictionary_entry_id = t.dictionary_entry_id
        INNER JOIN dictionary_entry_translation_fts fts ON de.dictionary_entry_id = fts.rowid
        WHERE dictionary_entry_translation_fts MATCH ?
        ORDER BY rank
        LIMIT 100;
      """,
      ["$query*"],
    );

    final List<DictionaryEntry> results = [];
    final dictionaryEntries = <int, DictionaryEntry>{};

    for (final row in sqlResults) {
      final int id = row['dictionary_entry_id'];

      if (!dictionaryEntries.containsKey(id)) {
        final entry = DictionaryEntry(
          hanziSimplified: row['hanzi_simplified'],
          piyin: row['pinyin'],
          pinyinNumeric: row['pinyin_numeric'],
          hsk: row['hsk'],
          translations: [],
        );
        dictionaryEntries[id] = entry;
        results.add(entry);
      }
      dictionaryEntries[id]!.translations.add(
        Translation(
          portuguese: row['portuguese_translation'],
          grammaticalClass: GrammaticalClass.values.byName(
            row['grammatical_class'],
          ),
        ),
      );
    }

    return results;
  }
}

class Translation {
  final String portuguese;
  final GrammaticalClass grammaticalClass;

  Translation({required this.portuguese, required this.grammaticalClass});
}

enum GrammaticalClass {
  adjective,
  adverb,
  expression,
  noun,
  particle,
  verb;

  String getStylishCharacter() {
    switch (this) {
      case GrammaticalClass.adjective:
        return "形";
      case GrammaticalClass.adverb:
        return "副";
      case GrammaticalClass.expression:
        return "语";
      case GrammaticalClass.noun:
        return "名";
      case GrammaticalClass.particle:
        return "助";
      case GrammaticalClass.verb:
        return "动";
    }
  }
}
