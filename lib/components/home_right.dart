import 'package:json_to_dart/export.dart';

class HomeRight extends StatelessWidget {
  const HomeRight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(children: [
        _buildOptions(context),
        Expanded(
          child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.only(left: 15,top: 15,bottom: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: ValueListenableBuilder<String>(
                    valueListenable: context.read<JsonToDartController>().output,
                    builder: (context, value, child) => SelectableText(value)),
              )),
        ),
        ElevatedButton(onPressed: context.read<JsonToDartController>().copyToClipboard, child: const Text('复制'))
      ]);

  Widget _buildOptions(BuildContext context) => Row(children: [
        const Text('类名称'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
                height: 35,
                child: TextField(
                    controller: context.read<JsonToDartController>().nameController,
                    onChanged: context.read<JsonToDartController>().onNameChanged,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      border: OutlineInputBorder(),
                    ))),
          ),
        ),
        ElevatedButton(
          onPressed: () => context.read<JsonToDartController>().showSetting(context),
          child: const Text('设置'),
        )
      ]);
}
