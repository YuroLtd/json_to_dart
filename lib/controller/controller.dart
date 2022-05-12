import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:flutter/services.dart';
import 'package:json_to_dart/export.dart';

class JsonToDartController {
  // ignore_for_file: constant_identifier_names
  static const String FILE_HEADER = 'file_header';
  static const String JSON_KEY = 'json_key';
  static const String COPY_METHOD = 'copy_method';
  static const String CAMEL_CASE = 'camel_case';
  static const String FINAL_FIELD = 'final_field';
  static const String NAMED_CONSTRUCTOR = 'named_constructor';
  static const String EQUATABLE = 'equatable';

  final enableFileHeader = ValueNotifier<bool>(true);
  final enableJsonKey = ValueNotifier<bool>(true);
  final enableFinalField = ValueNotifier<bool>(true);
  final enableNamedConstructor = ValueNotifier<bool>(false);
  final enableCopyMethod = ValueNotifier<bool>(false);
  final enableCamelCase = ValueNotifier<bool>(true);
  final enableEquatable = ValueNotifier<bool>(false);

  final nameController = TextEditingController();

  final inputController = TextEditingController();
  final output = ValueNotifier<String>('');

  final clazzList = <Clazz>[];

  void onCheckBoxValueChanged(String key, bool value) {
    switch (key) {
      case FILE_HEADER:
        enableFileHeader.value = value;
        break;
      case JSON_KEY:
        enableJsonKey.value = value;
        break;
      case FINAL_FIELD:
        enableFinalField.value = value;
        break;
      case NAMED_CONSTRUCTOR:
        enableNamedConstructor.value = value;
        break;
      case COPY_METHOD:
        enableCopyMethod.value = value;
        break;
      case CAMEL_CASE:
        enableCamelCase.value = value;
        break;
      case EQUATABLE:
        enableEquatable.value = value;
        break;
      default:
        break;
    }
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
      addClazz(clazz);
    }
    // json 以List开始
    else if (jsonObject is List) {
      _parseList(jsonObject, key);
    }
    // 生成代码
    if (clazzList.isNotEmpty) _generateCode();
  }

  void addClazz(Clazz clazz) {
    final containsList = clazzList.where((e) => e.key == clazz.key);
    if (containsList.isNotEmpty) {
      containsList.first.merge(clazz);
    } else {
      clazzList.add(clazz);
    }
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
        addClazz(subClazz);
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
          addClazz(subClazz);
        }
        return Field(key: key, type: 'List<${subClazz.name}>');
      }
    }
    return Field(key: key, type: list.runtimeType.toString());
  }

  void _generateCode() {
    final list = clazzList.reversed;
    final sb = StringBuffer();

    if (enableFileHeader.value) {
      sb.writeln("import 'package:json_annotation/json_annotation.dart';");
      if (enableEquatable.value) {
        sb.writeln("import 'package:equatable/equatable.dart';");
      }
      sb.writeln();
      sb.writeln("part '${list.first.fileName}.g.dart';");
      sb.writeln();
    }

    // ignore_for_file: avoid_function_literals_in_foreach_calls
    list.forEach((element) => _generateClazz(sb, element));
    output.value = DartFormatter(pageWidth: 120).format(sb.toString());
  }

  void _generateClazz(StringBuffer sb, Clazz clazz) {
    sb.writeln('@JsonSerializable()');
    sb.write('class ${clazz.name} extends Object ');
    if (enableEquatable.value) {
      sb.writeln('with EquatableMixin');
    }
    sb.write('{');
    sb.writeln();

    final camelCase = enableCamelCase.value;
    clazz.fields.forEach((element) => _generateField(sb, element, camelCase));

    sb
      ..write('${clazz.name}(')
      ..write((enableNamedConstructor.value && clazz.fields.isNotEmpty) ? '{' : '')
      ..write('\n');
    for (final field in clazz.fields) {
      sb
        ..write((enableNamedConstructor.value && field.type != 'dynamic' && !field.nullable) ? 'required ' : '')
        ..write('this.${field.getName(camelCase)}')
        ..write(',\n');
    }
    sb
      ..write((enableNamedConstructor.value && clazz.fields.isNotEmpty) ? '}' : '')
      ..write(');\n')
      ..writeln()
      ..writeln('factory ${clazz.name}.fromJson(Map<String, dynamic> srcJson) => _\$${clazz.name}FromJson(srcJson);')
      ..writeln()
      ..writeln('Map<String, dynamic> toJson() => _\$${clazz.name}ToJson(this);');

    if (enableEquatable.value) {
      sb
        ..writeln()
        ..writeln('@override')
        ..writeln('List<Object> get props =>')
        ..writeln('${clazz.fields.map((e) => e.getName(camelCase)).toList()};');
    }

    if (enableCopyMethod.value) _generateCopyWith(sb, clazz, camelCase);

    sb.writeln('}');
    sb.writeln();
  }

  void _generateField(StringBuffer sb, Field field, bool camelCase) {
    if (enableJsonKey.value) {
      sb.writeln("@JsonKey(name: '${field.key}')");
    }
    sb
      ..write(enableFinalField.value ? 'final ' : '')
      ..write(field.type)
      ..write(!field.isDynamic && field.nullable ? '? ' : ' ')
      ..write(field.getName(camelCase))
      ..write(';\n');
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
