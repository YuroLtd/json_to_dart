// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

// ignore_for_file:avoid_print
void main() {
  test('description', () {
    String str = 'abc__def';
    final sb = StringBuffer();
    final list = str
        .split('_')
        .where((element) => element.isNotEmpty)
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .toList();
    for (int i = 0; i < list.length; i++) {
      sb.write(i == 0 ? list[0].toLowerCase() : list[i]);
    }

    print(sb.toString());
  });
}
