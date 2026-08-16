import 'package:flutter/material.dart';
import 'package:mandarinho/components/pinyin.dart';
import 'package:mandarinho/database.dart';
import 'package:mandarinho/functionalities/search/view.dart';
import 'package:provider/provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await DbConnection.getConnection();
  runApp(MyApp(db: db));
}

class MyApp extends StatelessWidget {
  final SqliteDatabase db;

  const MyApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (ctx) => db,
      lazy: false,
      dispose: (ctx, db) => db.close(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.white),
          extensions: {
            PinyinStyle(
              tone1Color: Colors.red.shade800,
              tone2Color: Colors.orange.shade800,
              tone3Color: Colors.green.shade800,
              tone4Color: Colors.blue.shade800,
              tone5Color: Colors.grey.shade800,
            ),
          },
        ),
        home: Scaffold(
          appBar: AppBar(title: Text("Mandarinho")),
          body: Padding(
            padding: .symmetric(horizontal: 12, vertical: 8),
            child: SearchView(),
          ),
        ),
      ),
    );
  }
}
