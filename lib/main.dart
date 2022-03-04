import 'package:json_to_dart/export.dart';

void main() => runApp(Provider(
      create: (_) => JsonToDartController(),
      child: const MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'json_to_dart',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          Center(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Row(children: [
                    const Expanded(flex: 1, child: HomeLeft()),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    const Expanded(flex: 1, child: HomeRight()),
                  ]))),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(padding: EdgeInsets.all(8), child: Text('Copyright 2022 by YuroLtd.')),
          )
        ]),
      );
}
