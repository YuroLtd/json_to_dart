import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/home.dart';
import 'src/controller/controller.dart';

void main() {
  runApp(Provider(create: (_) => JsonToDartController(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'json_to_dart',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
