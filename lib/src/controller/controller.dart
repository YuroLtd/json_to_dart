import 'dart:convert';

import 'package:flutter/material.dart';
import '../components/setting.dart';

class JsonToDartController {
  final enableJsonKey = ValueNotifier<bool>(false);
  final enableCopyMethod = ValueNotifier<bool>(false);
  final fileHeaderController = TextEditingController();

  final nameController = TextEditingController();
  final inputController = TextEditingController();
  final output = ValueNotifier<String>('');

  void onCheckBoxValueChanged(String key, bool value) {
    switch (key) {
      case 'JsonKey':
        enableJsonKey.value = value;
        break;
      case 'CopyMethod':
        enableCopyMethod.value = value;
        break;
      default:
        break;
    }
  }

  void formatJson() {
    if (output.value.isNotEmpty) return;
    final map = json.decode(inputController.text);
    inputController.text = JsonEncoder.withIndent(' ' * 2).convert(map);
  }

  void onInputChanged(String str) {
    Map<String, dynamic> map;
    try {
      final text = inputController.text;
      map = json.decode(text);
      output.value = '';
    } on FormatException catch (_) {
      output.value = '这不是一个正确的json';
      return;
    }
    map.entries.forEach((element) {
      print('${element.key} => ${element.value.runtimeType}');
    });
  }

  void copyToClipboard() {}

  void onNameChanged(String str) {}

  /// 显示设置面板
  void showSetting(BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (context) => const SettingSheet(),
      );
}
