import 'package:flutter/material.dart';
import 'package:mandarinho/functionalities/search/view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightGreen)),
      home: Scaffold(
        appBar: AppBar(title: Text("Mandarinho")),
        body: Padding(padding: .all(8), child: SearchView()),
      ),
    );
  }
}
