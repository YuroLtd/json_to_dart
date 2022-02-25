import 'package:json_to_dart/export.dart';

class HomeLeft extends StatelessWidget {
  const HomeLeft({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(children: [
        const SizedBox(height: 35, child: Text('将json粘贴到左边')),
        Expanded(
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                  controller: context.read<JsonToDartController>().inputController,
                  onChanged: context.read<JsonToDartController>().onInputChanged,
                  keyboardType: TextInputType.multiline,
                  maxLines: 1000,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
                  ))),
        ),
        ElevatedButton(onPressed: context.read<JsonToDartController>().formatJson, child: const Text('格式化'))
      ]);
}
