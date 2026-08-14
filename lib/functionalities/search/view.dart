import 'package:flutter/material.dart';
import 'package:mandarinho/core_models.dart';
import 'package:mandarinho/functionalities/search/viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchViewModel(),
      child: Column(children: [SearchInput(), SearchBody()]),
    );
  }
}

class SearchBody extends StatelessWidget {
  const SearchBody({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(context);

    return switch ((searchViewModel.searching, searchViewModel.query.isEmpty)) {
      (true, _) => Text("Buscando..."),
      (false, true) => Text("Busque alguma palavra!"),
      (false, false) => SearchResults(),
    };
  }
}

class SearchResults extends StatelessWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(context);

    return Expanded(
      child: ListView.separated(
        itemCount: searchViewModel.results.length,
        padding: EdgeInsets.only(top: 8),
        itemBuilder: (context, index) {
          return DictionaryEntryListItem(
            dictionaryEntry: searchViewModel.results[index],
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(context);
    final db = Provider.of<SqliteDatabase>(context);

    return TextField(
      autofocus: true,
      decoration: InputDecoration(hintText: "Busque por português ou chinês"),
      onChanged: (value) => searchViewModel.setSearch(value, db),
    );
  }
}

class DictionaryEntryListItem extends StatelessWidget {
  final DictionaryEntry dictionaryEntry;
  final hanziStyle = TextStyle(fontSize: 28);
  final pinyinStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  final grammarClassStyle = TextStyle(fontSize: 20);

  DictionaryEntryListItem({super.key, required this.dictionaryEntry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(dictionaryEntry.hanziSimplified, style: hanziStyle),
          Text(dictionaryEntry.piyin, style: pinyinStyle),
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
