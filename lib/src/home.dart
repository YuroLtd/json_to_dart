import 'package:flutter/material.dart';
import 'components/home_let.dart';
import 'components/home_right.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      body: Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Row(children: [
                const Expanded(flex: 1, child: HomeLeft()),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                const Expanded(flex: 1, child: HomeRight()),
              ]))));
}
