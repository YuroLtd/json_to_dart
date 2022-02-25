import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_to_dart/export.dart';
import 'package:dart_style/dart_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JsonToDartController {
  // ignore_for_file: constant_identifier_names
  static const String JSON_KEY = 'json_key';
  static const String COPY_METHOD = 'copy_method';
  static const String CAMEL_CASE = 'camel_case';
  static const String COPYRIGHT = 'copyright';

  final enableJsonKey = ValueNotifier<bool>(false);
  final enableCopyMethod = ValueNotifier<bool>(false);
  final enableCamelCase = ValueNotifier<bool>(false);
  final copyrightController = TextEditingController();

  final nameController = TextEditingController();
  final inputController = TextEditingController();
  final output = ValueNotifier<String>('');

  final clazzList = <Clazz>[];
  late final SharedPreferences prefs;

  JsonToDartController() {
    Future(() async {
      prefs = await SharedPreferences.getInstance();

      enableJsonKey.value = prefs.getBool(JSON_KEY) ?? true;
      enableCopyMethod.value = prefs.getBool(COPY_METHOD) ?? false;
      enableCamelCase.value = prefs.getBool(CAMEL_CASE) ?? true;
      copyrightController.text = prefs.getString(COPYRIGHT) ?? '';
    });
  }

  /// 显示设置面板
  void showSetting(BuildContext context) => showModalBottomSheet(
        context: context,
        builder: (context) => const SettingSheet(),
      );

  void onCheckBoxValueChanged(String key, bool value) {
    switch (key) {
      case 'JsonKey':
        enableJsonKey.value = value;
        prefs.setBool(JSON_KEY, value);
        break;
      case 'CopyMethod':
        enableCopyMethod.value = value;
        prefs.setBool(COPY_METHOD, value);
        break;
      case 'CamelCase':
        enableCamelCase.value = value;
        prefs.setBool(CAMEL_CASE, value);
        break;
      default:
        break;
    }
    if (clazzList.isNotEmpty) _generateCode();
  }

  void onCopyrightChanged(String str) {
    prefs.setString(COPYRIGHT, str);
    if (clazzList.isNotEmpty) _generateCode();
  }

  /// 格式化输入内容
  void formatJson() {
    final text = inputController.text.trim();
    if (text.isEmpty) return;
    try {
      final map = json.decode(text);
      final newValue = JsonEncoder.withIndent(' ' * 2).convert(map);
      inputController.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    } on FormatterException catch (_) {}
  }

  /// 复制输出内容到剪切板
  void copyToClipboard() async => await Clipboard.setData(ClipboardData(text: output.value));

  /// 监听实体类类名的改变
  void onNameChanged(String str) {
    str = str.trim();
    if (clazzList.isNotEmpty) {
      clazzList.last.key = str.isEmpty ? 'entity' : str;
      clazzList.last.resetName();
      _generateCode();
    }
  }

  /// 监听输入内容的改变
  void onInputChanged(String str) {
    // 空的json,清空输出
    if (str.trim().isEmpty) {
      output.value = '';
      return;
    }
    // 移除输入内容中"\t"
    final text = str.replaceAll('\t', '');
    inputController.value = TextEditingValue(text: text, selection: inputController.selection);

    // 尝试解析内容
    Object jsonObject;
    try {
      jsonObject = json.decode(text);
      output.value = '';
    } on FormatException catch (_) {
      output.value = '这不是一个正确的json';
      return;
    }

    // 解析并生成实体类
    clazzList.clear();
    final name = nameController.text.trim();
    final key = name.isNotEmpty ? name : 'entity';
    // json以Map开始
    if (jsonObject is Map) {
      final clazz = _parseMap(Map<String, dynamic>.from(jsonObject), key);
      clazzList.add(clazz);
    }
    // json 以List开始
    else if (jsonObject is List) {
      _parseList(jsonObject, key);
    }
    // 生成代码
    if (clazzList.isNotEmpty) _generateCode();
  }

  Clazz _parseMap(Map<String, dynamic> map, String key) {
    final clazz = Clazz(key: key);
    map.forEach((key, value) {
      // 基本数据类型
      if (value is int || value is bool || value is double || value is String) {
        clazz.fields.add(Field(key: key, type: value.runtimeType.toString()));
      }
      // Map类型
      else if (value is Map) {
        final subClazz = _parseMap(Map<String, dynamic>.from(value), key);
        clazzList.add(subClazz);
        clazz.fields.add(Field(key: key, type: subClazz.name));
      }
      // List类型
      else if (value is List) {
        clazz.fields.add(_parseList(value, key));
      }
      // dynamic
      else {
        clazz.fields.add(Field(key: key, type: 'dynamic'));
      }
    });
    return clazz;
  }

  Field _parseList(List<dynamic> list, String key) {
    if (list.isNotEmpty) {
      final first = list.first;
      // 基本数据类型
      if (first is int || first is bool || first is double || first is String) {
        return Field(key: key, type: 'List<${first.runtimeType.toString()}>');
      }
      // Map类型
      else if (first is Map) {
        late Clazz subClazz;
        for (final element in list) {
          subClazz = _parseMap(Map<String, dynamic>.from(element), key);
          final containsList = clazzList.where((e) => e.key == subClazz.key);
          if (containsList.isNotEmpty) {
            containsList.first.merge(subClazz);
          } else {
            clazzList.add(subClazz);
          }
        }
        return Field(key: key, type: 'List<${subClazz.name}>');
      }
    }
    return Field(key: key, type: list.runtimeType.toString());
  }

  void _generateCode() {
    final list = clazzList.reversed;
    final sb = StringBuffer();

    if (copyrightController.text.trim().isNotEmpty) {
      sb.writeln(copyrightController.text.trim());
    }
    sb.writeln("import 'package:json_annotation/json_annotation.dart';");
    sb.writeln();
    sb.writeln("part '${list.first.fileName}.g.dart';");
    sb.writeln();

    // ignore_for_file: avoid_function_literals_in_foreach_calls
    list.forEach((element) => _generateClazz(sb, element));
    output.value = DartFormatter(pageWidth: 120).format(sb.toString());
  }

  void _generateClazz(StringBuffer sb, Clazz clazz) {
    sb.writeln('@JsonSerializable()');
    sb.writeln('class ${clazz.name} extends Object {');
    sb.writeln();

    final camelCase = enableCamelCase.value;
    clazz.fields.forEach((element) => _generateField(sb, element, camelCase));

    sb.writeln('${clazz.name}({');
    for (final field in clazz.fields) {
      sb.writeln('${field.nullable ? '' : 'required'} this.${field.getName(camelCase)},');
    }
    sb.writeln('});');

    sb.writeln();
    sb.writeln('factory ${clazz.name}.fromJson(Map<String, dynamic> srcJson) => _\$${clazz.name}FromJson(srcJson);');
    sb.writeln();
    sb.writeln('Map<String, dynamic> toJson() => _\$${clazz.name}ToJson(this);');

    if (enableCopyMethod.value) _generateCopyWith(sb, clazz, camelCase);

    sb.writeln('}');
    sb.writeln();
  }

  void _generateField(StringBuffer sb, Field field, bool camelCase) {
    if (enableJsonKey.value) {
      sb.writeln("@JsonKey(name: '${field.key}')");
    }
    sb.writeln('final ${field.type}${field.nullable ? '?' : ''} ${field.getName(camelCase)};');
    sb.writeln();
  }

  void _generateCopyWith(StringBuffer sb, Clazz clazz, bool camelCase) {
    sb.writeln();
    sb.writeln('${clazz.name} copyWith({');
    for (final element in clazz.fields) {
      sb.writeln('${element.type}${element.type != 'dynamic' ? '?' : ''} ${element.getName(camelCase)},');
    }
    sb.writeln('}) => ${clazz.name}(');
    for (final element in clazz.fields) {
      sb.writeln('${element.getName(camelCase)}: ${element.getName(camelCase)} ?? this.${element.getName(camelCase)},');
    }
    sb.writeln(');');
  }
}
