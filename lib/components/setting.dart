import 'package:json_to_dart/export.dart';

class SettingSheet extends StatelessWidget {
  const SettingSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Wrap(spacing: 20, runSpacing: 20, children: [
        CheckBoxItem(
          label: '生成文件头',
          valueKey: const ValueKey(JsonToDartController.FILE_HEADER),
          checked: context.read<JsonToDartController>().enableFileHeader,
        ),
        CheckBoxItem(
          label: '添加@JsonKey注解',
          valueKey: const ValueKey(JsonToDartController.JSON_KEY),
          checked: context.read<JsonToDartController>().enableJsonKey,
        ),
        CheckBoxItem(
          label: '使用final字段',
          valueKey: const ValueKey(JsonToDartController.FINAL_FIELD),
          checked: context.read<JsonToDartController>().enableFinalField,
        ),
        CheckBoxItem(
          label: '使用命名构造函数',
          valueKey: const ValueKey(JsonToDartController.NAMED_CONSTRUCTOR),
          checked: context.read<JsonToDartController>().enableNamedConstructor,
        ),
        CheckBoxItem(
          label: '使用驼峰命名',
          valueKey: const ValueKey(JsonToDartController.CAMEL_CASE),
          checked: context.read<JsonToDartController>().enableCamelCase,
        ),
        CheckBoxItem(
          label: '添加复制方法',
          valueKey: const ValueKey(JsonToDartController.COPY_METHOD),
          checked: context.read<JsonToDartController>().enableCopyMethod,
        ),
        CheckBoxItem(
          label: 'Equatable支持',
          valueKey: const ValueKey(JsonToDartController.EQUATABLE),
          checked: context.read<JsonToDartController>().enableEquatable,
        ),
      ]);
}

class CheckBoxItem extends StatelessWidget {
  final String label;
  final ValueKey<String> valueKey;
  final ValueNotifier<bool> checked;

  const CheckBoxItem({required this.label, required this.valueKey, required this.checked}) : super(key: valueKey);

  void _onChanged(BuildContext context, bool? value) {
    if (value == null) return;
    context.read<JsonToDartController>().onCheckBoxValueChanged(valueKey.value, value);
  }

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        ValueListenableBuilder<bool>(
            valueListenable: checked,
            builder: (context, value, child) => Checkbox(
                  value: value,
                  onChanged: (value) => _onChanged(context, value),
                )),
        Text(label)
      ]));
}
