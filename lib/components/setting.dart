import 'package:json_to_dart/export.dart';

class SettingSheet extends StatelessWidget {
  const SettingSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      height: MediaQuery.of(context).size.height * 0.3,
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSettings(context),
        Expanded(
          child: Container(
              margin: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
              child: TextField(
                  maxLines: 20,
                  controller: context.read<JsonToDartController>().copyrightController,
                  onChanged: context.read<JsonToDartController>().onCopyrightChanged,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(15),
                      hintText: '添加Copyright信息',
                      hintStyle: TextStyle(color: Colors.grey[400])))),
        )
      ]));

  Widget _buildSettings(BuildContext context) => Wrap(spacing: 20, runSpacing: 20, children: [
        CheckBoxItem(
          label: '添加@JsonKey注解',
          valueKey: const ValueKey('JsonKey'),
          checked: context.read<JsonToDartController>().enableJsonKey,
        ),
        CheckBoxItem(
          label: '使用驼峰命名',
          valueKey: const ValueKey('CamelCase'),
          checked: context.read<JsonToDartController>().enableCamelCase,
        ),
        CheckBoxItem(
          label: '添加复制方法',
          valueKey: const ValueKey('CopyMethod'),
          checked: context.read<JsonToDartController>().enableCopyMethod,
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
