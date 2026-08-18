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
  static final hanziStyle = TextStyle(fontSize: 64);
  static final pinyinStyle = TextStyle(fontSize: 20);
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
        child: SelectionArea(
          child: ListView(
            children: [
              Center(
                // TODO: Make the whole word selected when the user starts selecting this hanzi
                child: Hanzi(
                  pinyinNumeric: widget.pinyinNumeric,
                  hanzi: widget.hanzi,
                  style: hanziStyle,
                ),
              ),
              Center(
                child: Pinyin(
                  pinyinNumeric: widget.pinyinNumeric,
                  style: pinyinStyle,
                ),
              ),
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
      ),
    );
  }
}

class WordTranslations extends StatelessWidget {
  final DictionaryEntry entry;
  final numberIndicatorStyle = TextStyle(color: Colors.black54);
  final grammarClassStyle = TextStyle(
    color: Colors.black54,
    fontStyle: .italic,
  );
  final translationStyle = TextStyle(fontSize: 20);

  WordTranslations({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 12,
      children: entry.translations.indexed.map((element) {
        final (index, tl) = element;
        return Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              textBaseline: .alphabetic,
              crossAxisAlignment: .baseline,
              spacing: 4,
              children: [
                Text("${index + 1}.", style: numberIndicatorStyle),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        tl.grammaticalClass.getPortugueseName(),
                        style: grammarClassStyle,
                      ),
                      Text(tl.portuguese, style: translationStyle),
                      Examples(examples: tl.examples),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}

class Examples extends StatelessWidget {
  final List<Example> examples;
  final exampleHanziStyle = TextStyle(fontStyle: .italic, fontSize: 16);
  final examplePinyinStyle = TextStyle(fontStyle: .italic, fontSize: 14);
  final examplePortugueseStyle = TextStyle(fontStyle: .italic, fontSize: 14);

  Examples({super.key, required this.examples});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 8,
      children: examples
          .map(
            (e) => Container(
              padding: .only(left: 4),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.black26, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 2,
                children: [
                  Hanzi(
                    hanzi: e.hanziSimplified,
                    pinyinNumeric: e.pinyinNumeric,
                    style: exampleHanziStyle,
                  ),
                  Pinyin(
                    pinyinNumeric: e.pinyinNumeric,
                    style: examplePinyinStyle,
                  ),
                  Text(e.portuguese, style: examplePortugueseStyle),
                ],
              ),
            ),
          )
          .take(2)
          .toList(),
    );
  }
}
