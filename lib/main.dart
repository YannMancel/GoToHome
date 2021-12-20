import 'package:flutter/material.dart';

import 'home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const _kAppName = '2D Game';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _kAppName,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(title: _kAppName),
    );
  }
}
