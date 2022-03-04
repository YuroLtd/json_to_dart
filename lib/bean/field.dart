class Field {
  final String key;
  String type;
  String? _name;
  bool nullable;

  Field({
    required this.key,
    required this.type,
    this.nullable = false,
  });
}

extension FieldExt on Field {
  String getName(bool camelCase) {
    if (_name != null) return _name!;
    if (camelCase && key.contains('_')) {
      final sb = StringBuffer();
      final list = key
          .split('_')
          .where((element) => element.isNotEmpty)
          .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
          .toList();
      for (int i = 0; i < list.length; i++) {
        sb.write(i == 0 ? list[0].toLowerCase() : list[i]);
      }
      _name = sb.toString();
    }
    return _name ??= key;
  }

  bool get isDynamic => type == 'dynamic';

  bool get isInt => type == 'int';

  bool get isDouble => type == 'double';
}
