import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mandarinho/functionalities/search/viewmodel.dart';
import 'package:provider/provider.dart';

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

    return Column(
      children: [
        for (var entry in searchViewModel.results) Text(entry.hanziSimplified),
      ],
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(context);

    return TextField(
      autofocus: true,
      decoration: InputDecoration(hintText: "Busque por português ou chinês"),
      onChanged: (value) => searchViewModel.setSearch(value),
    );
  }
}
