import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mandarinho/async.dart';
import 'package:mandarinho/components/Text.dart';
import 'package:mandarinho/components/hanzi.dart';
import 'package:mandarinho/components/pinyin.dart';
import 'package:mandarinho/core_models.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

class SearchViewState extends ChangeNotifier {
  final _taskRunner = LatestTaskRunner();

  String query = "";
  List<DictionaryEntry> results = [];
  // Only active for long queries
  bool loading = false;

  void search(String query, SqliteDatabase db) async {
    this.query = query;
    notifyListeners();

    final searchFuture = _taskRunner.run(
      () => DictionaryEntry.search(db, query),
    );
    final timeoutForLoading = Future.delayed(.new(milliseconds: 35));

    final firstToComplete = await Future.any([searchFuture, timeoutForLoading]);
    if (searchFuture != firstToComplete) {
      loading = true;
      notifyListeners();
    }

    final searchFutureResult = await searchFuture;
    if (searchFutureResult.isLatest) {
      results = searchFutureResult.data;
      loading = false;
      notifyListeners();
    }
  }
}

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewState(),
      child: Column(
        children: [
          SearchInput(),
          Expanded(child: SearchBody()),
        ],
      ),
    );
  }
}

class SearchBody extends StatelessWidget {
  const SearchBody({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewState>(context);

    return switch ((searchViewModel.loading, searchViewModel.query.isEmpty)) {
      (true, _) => SearchingMessage(),
      (false, true) => EmptyQueryMessage(poemRandomSeed: Random().nextInt(999)),
      (false, false) => SearchResults(),
    };
  }
}

class SearchingMessage extends StatelessWidget {
  const SearchingMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: LinearProgressIndicator());
  }
}

class EmptyQueryMessage extends StatelessWidget {
  static const List<String> poems = [
    "红豆生南国\n春来发几枝\n愿君多采撷\n此物最相思",
    "少小离家老大回\n乡音无改鬓毛衰\n儿童相见不相识\n笑问客从何处来",
    "葡萄美酒夜光杯\n欲饮琵琶马上催\n醉卧沙场君莫笑\n古来征战几人回",
  ];
  final int poemRandomSeed;
  late final int index;

  EmptyQueryMessage({super.key, required this.poemRandomSeed}) {
    index = poemRandomSeed % poems.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 40,
      children: [
        Text(
          'Vamos começar a estudar?\nTente buscar alguma palavra!',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        GradientText(
          Text(
            poems[index],
            textAlign: .right,
            softWrap: false,
            style: .new(
              fontSize: 48,
              fontFamily: 'LiuJianMaoCao',
              overflow: .fade,
            ),
          ),
          gradient: LinearGradient(
            begin: .topCenter,
            end: .bottomCenter,
            colors: [
              Theme.of(context).textTheme.displayLarge?.color ?? Colors.black,
              Colors.transparent,
            ],
          ),
        ),
      ],
    );
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewState>(context);

    // TODO: Show empty results scheen

    return ListView.separated(
      itemCount: searchViewModel.results.length,
      padding: EdgeInsets.only(top: 8),
      itemBuilder: (context, index) {
        return DictionaryEntryListItem(
          dictionaryEntry: searchViewModel.results[index],
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewState>(context);
    final db = Provider.of<SqliteDatabase>(context);

    return SearchBar(
      leading: Icon(Icons.search),
      hintText: 'Buscar...',
      onChanged: (value) => searchViewModel.search(value, db),
      autoFocus: true,
    );
  }
}

class DictionaryEntryListItem extends StatelessWidget {
  final DictionaryEntry dictionaryEntry;
  final hanziStyle = TextStyle(
    fontSize: 28,
    fontFamily: 'NotoSerifSC',
    fontWeight: .w700,
  );
  final pinyinStyle = TextStyle(fontSize: 16);
  final grammarClassStyle = TextStyle(fontSize: 20);

  DictionaryEntryListItem({super.key, required this.dictionaryEntry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Hanzi(
            hanzi: dictionaryEntry.hanziSimplified,
            pinyinNumeric: dictionaryEntry.pinyinNumeric,
            style: hanziStyle,
          ),
          Pinyin(
            pinyinNumeric: dictionaryEntry.pinyinNumeric,
            style: pinyinStyle,
          ),
        ],
      ),
      subtitle: Text(
        dictionaryEntry.translations.map((tl) => tl.portuguese).join(" / "),
      ),
      trailing: Text(
        dictionaryEntry.translations
            .map((tl) => tl.grammaticalClass.getStylishCharacter())
            .toSet()
            .join("/"),
        style: grammarClassStyle,
      ),
    );
  }
}
