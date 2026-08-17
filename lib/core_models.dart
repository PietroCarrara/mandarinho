import 'package:sqlite3/common.dart';
import 'package:sqlite_async/sqlite_async.dart';

class DictionaryEntry {
  final int id;
  final String hanziSimplified;
  final String piyin;
  final String pinyinNumeric;
  final int? hsk;
  final List<Translation> translations;

  DictionaryEntry({
    required this.id,
    required this.hanziSimplified,
    required this.piyin,
    required this.pinyinNumeric,
    required this.hsk,
    required this.translations,
  });

  factory DictionaryEntry.fromRow(Row row) {
    return DictionaryEntry(
      id: row['dictionary_entry_id'],
      hanziSimplified: row['hanzi_simplified'],
      piyin: row['pinyin'],
      pinyinNumeric: row['pinyin_numeric'],
      hsk: row['hsk'],
      translations: [],
    );
  }

  DictionaryEntry withTranslations(List<Translation> translations) {
    return DictionaryEntry(
      id: id,
      hanziSimplified: hanziSimplified,
      piyin: piyin,
      pinyinNumeric: pinyinNumeric,
      hsk: hsk,
      translations: translations,
    );
  }

  static Future<DictionaryEntry?> find(int id, SqliteConnection db) async {
    final sqlResults = await db.getOptional(
      """
        SELECT de.dictionary_entry_id, de.hanzi_simplified, de.pinyin, de.pinyin_numeric, de.hsk
        FROM dictionary_entries de
        WHERE de.dictionary_entry_id = ?;
      """,
      [id],
    );

    if (sqlResults == null) {
      return null;
    }

    final dictionaryEntry = DictionaryEntry.fromRow(sqlResults);
    final dictionaryEntryComplete = dictionaryEntry.withTranslations(
      await Translation.search(dictionaryEntry.id, db),
    );

    return dictionaryEntryComplete;
  }

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
        final entry = DictionaryEntry.fromRow(row);
        dictionaryEntries[id] = entry;
        results.add(entry);
      }
      dictionaryEntries[id]!.translations.add(Translation.fromRow(row));
    }

    return results;
  }
}

class Translation {
  final String portuguese;
  final GrammaticalClass grammaticalClass;
  final List<Example> examples;

  Translation({
    required this.portuguese,
    required this.grammaticalClass,
    required this.examples,
  });

  factory Translation.fromRow(Row row) {
    return Translation(
      portuguese: row['portuguese_translation'],
      grammaticalClass: GrammaticalClass.values.byName(
        row['grammatical_class'],
      ),
      examples: [],
    );
  }

  static Future<List<Translation>> search(
    int dictionaryEntryId,
    SqliteConnection db,
  ) async {
    final sqlResults = await db.getAll(
      """
        SELECT t.translation_id, t.portuguese_translation, t.grammatical_class, e.example_portuguese, e.example_hanzi_simplified, e.example_pinyin_numeric
        FROM translations t
        INNER JOIN examples e ON t.translation_id = e.translation_id
        WHERE t.dictionary_entry_id = ?;
      """,
      [dictionaryEntryId],
    );

    final List<Translation> results = [];
    final translations = <int, Translation>{};

    for (final row in sqlResults) {
      final int id = row['translation_id'];

      if (!translations.containsKey(id)) {
        final translation = Translation.fromRow(row);
        translations[id] = translation;
        results.add(translation);
      }
      translations[id]!.examples.add(Example.fromRow(row));
    }

    return results;
  }
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

  String getPortugueseName() {
    switch (this) {
      case GrammaticalClass.adjective:
        return "adjetivo";
      case GrammaticalClass.adverb:
        return "advérbio";
      case GrammaticalClass.expression:
        return "expressão";
      case GrammaticalClass.noun:
        return "substantivo";
      case GrammaticalClass.particle:
        return "partícula";
      case GrammaticalClass.verb:
        return "verbo";
    }
  }
}

class Example {
  final String portuguese;
  final String hanziSimplified;
  final String pinyinNumeric;

  Example({
    required this.portuguese,
    required this.hanziSimplified,
    required this.pinyinNumeric,
  });

  factory Example.fromRow(Row row) {
    return Example(
      portuguese: row['example_portuguese'],
      hanziSimplified: row['example_hanzi_simplified'],
      pinyinNumeric: row['example_pinyin_numeric'],
    );
  }
}
