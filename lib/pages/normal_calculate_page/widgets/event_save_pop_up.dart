import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:warikan/models/event_normal.dart';

class EventSavePopUp extends StatefulWidget {
  const EventSavePopUp({super.key, required this.isar, required this.event});
  final Isar isar;
  final EventNormal event;

  @override
  State<EventSavePopUp> createState() => _EventSavePopUpState();
}

class _EventSavePopUpState extends State<EventSavePopUp> {
  final TextEditingController eventNameController = TextEditingController();

  @override
  void dispose() {
    eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('イベントを保存'),
      icon: const Icon(
        Icons.event_available,
        size: 36,
        color: Colors.green,
      ),
      content: TextField(
        controller: eventNameController,
        decoration: const InputDecoration(
          hintText: 'イベント名を入力してください',
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300, // ボタンの背景色
            foregroundColor: Colors.black, // テキストの色
            side: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 1.5),
            foregroundColor: Colors.white, // ボタンの背景色
            backgroundColor: Colors.green,
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold), // テキストのスタイル
          ),
          onPressed: () async {
            String eventName = eventNameController.text;
            if (eventName.isNotEmpty) {
              widget.event.eventName = eventName;
            }
            widget.event.nameList =
                List<String>.generate(widget.event.remainPeople, (_) => '');
            widget.event.payList =
                List<bool>.generate(widget.event.remainPeople, (_) => false);
            await widget.isar.writeTxn(() async {
              await widget.isar.eventNormals.put(widget.event);
            });

            if (context.mounted) {
              // グループ追加完了のメッセージを表示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('イベントが保存されました')),
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('保存'),
        ),
      ],
      contentPadding: const EdgeInsets.all(40),
    );
  }
}
