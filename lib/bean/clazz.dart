import 'package:json_to_dart/export.dart';

class Clazz {
  String key;

  Clazz({required this.key});

  String? _name;

  List<Field> fields = [];
}

extension ClazzExt on Clazz {
  String get name {
    if (_name != null) return _name!;
    if (key.contains('_')) {
      final sb = StringBuffer();
      key.split('_').where((element) => element.isNotEmpty).forEach((element) {
        sb.write('${element[0].toUpperCase()}${element.substring(1)}');
      });
      _name = sb.toString();
    } else {
      _name = '${key[0].toUpperCase()}${key.substring(1)}';
    }
    return _name!;
  }

  String get fileName {
    final sb = StringBuffer();
    key.split('_').where((element) => element.isNotEmpty).forEach((element) {
      sb.write('${element[0].toUpperCase()}${element.substring(1)}');
    });
    final fileName = sb.toString().splitMapJoin(RegExp(r'[A-Z]'), onMatch: (match) {
      return '_${match[0]?.toLowerCase()}';
    });
    return fileName.replaceFirst('_', '');
  }

  void resetName() => _name = null;

  void merge(Clazz other) {
    for (final field in other.fields) {
      final list = fields.where((e) => e.key == field.key);
      if (list.isNotEmpty) {
        final originField = list.first;
        // 如果字段类型不一致
        if (originField.type != field.type) {
          if (originField.type == 'dynamic' || field.type == 'dynamic') {
            originField.nullable = true;
          }
          if (originField.type == 'int' && field.type == 'double') {
            originField.type = 'double';
          }
        }
      } else {
        // 如果原始字段列表存在该字段,则加入
        fields.add(field);
      }
    }
  }
}
