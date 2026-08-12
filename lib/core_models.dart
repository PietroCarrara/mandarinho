class DictionaryEntry {
  final String hanziSimplified;
  final String piyin;
  final List<Translation> translations;

  DictionaryEntry({
    required this.hanziSimplified,
    required this.piyin,
    required this.translations,
  });
}

class Translation {
  final List<String> portuguese;

  Translation({required this.portuguese});
}
