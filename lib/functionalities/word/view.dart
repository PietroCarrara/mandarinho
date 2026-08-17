import 'package:flutter/material.dart';
import 'package:mandarinho/components/hanzi.dart';
import 'package:mandarinho/components/pinyin.dart';
import 'package:mandarinho/core_models.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

class WordView extends StatefulWidget {
  const WordView({
    super.key,
    required this.dictionaryEntryId,
    required this.hanzi,
    required this.pinyinNumeric,
  });

  final int dictionaryEntryId;
  final String hanzi;
  final String pinyinNumeric;

  @override
  State<StatefulWidget> createState() {
    return WordViewState();
  }
}

class WordViewState extends State<WordView> {
  static final hanziStyle = TextStyle(fontSize: 64, fontFamily: 'NotoSerifSC');
  bool loading = true;
  DictionaryEntry? dictionaryEntry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final db = Provider.of<SqliteDatabase>(context);

    DictionaryEntry.find(widget.dictionaryEntryId, db).then((dictionaryEntry) {
      setState(() {
        loading = false;
        this.dictionaryEntry = dictionaryEntry;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mandarinho")),
      body: Padding(
        padding: .symmetric(horizontal: 12, vertical: 8),
        child: ListView(
          children: [
            Center(
              child: Hanzi(
                pinyinNumeric: widget.pinyinNumeric,
                hanzi: widget.hanzi,
                style: hanziStyle,
              ),
            ),
            Center(child: Pinyin(pinyinNumeric: widget.pinyinNumeric)),
            Divider(),
            switch (loading) {
              true => Padding(
                padding: .all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              false =>
                dictionaryEntry != null
                    ? WordTranslations(entry: dictionaryEntry!)
                    : throw Exception(
                        'Could not find DictionaryEntry.id == ${widget.dictionaryEntryId}',
                      ),
            },
          ],
        ),
      ),
    );
  }
}

class WordTranslations extends StatelessWidget {
  final DictionaryEntry entry;
  static final grammarClassStyle = TextStyle(fontStyle: .italic);
  static final grammarClassChineseStyle = grammarClassStyle.copyWith(
    fontSize: 18,
  );
  static final translationStyle = TextStyle(fontSize: 18);

  const WordTranslations({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 12,
      children: entry.translations
          .map(
            (tl) => Column(
              crossAxisAlignment: .start,
              children: [
                Wrap(
                  crossAxisAlignment: .end,
                  spacing: 8,
                  children: [
                    Text(
                      tl.grammaticalClass.getStylishCharacter(),
                      style: grammarClassChineseStyle,
                    ),
                    Text(
                      tl.grammaticalClass.getPortugueseName(),
                      style: grammarClassStyle,
                    ),
                  ],
                ),
                Text(tl.portuguese, style: translationStyle),
                Examples(examples: tl.examples),
              ],
            ),
          )
          .toList(),
    );
  }
}

class Examples extends StatelessWidget {
  final List<Example> examples;

  const Examples({super.key, required this.examples});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: examples.map((e) => Text(e.portuguese)).take(2).toList(),
    );
  }
}
