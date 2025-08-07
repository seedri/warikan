import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:warikan/models/calc_slope.dart';
import 'package:warikan/models/event_keisha.dart';
import 'package:warikan/models/keisha_group_for_isar.dart';
import 'package:warikan/pages/keisha_calculate_page/keisha_calculate_page_controller.dart';
import 'package:warikan/pages/keisha_calculate_page/widgets/event_save_pop_up_keisha.dart';
import 'package:warikan/pages/keisha_calculate_page/widgets/result_container_keisha.dart';
import 'package:warikan/pages/new_group_page/new_group_page.dart';
import 'package:warikan/pages/utils/keyboard_config.dart';

class KeishaCalculatePage extends ConsumerStatefulWidget {
  final Isar isar;

  const KeishaCalculatePage({super.key, required this.isar});

  @override
  _KeishaCalculatePageState createState() => _KeishaCalculatePageState();
}

class _KeishaCalculatePageState extends ConsumerState<KeishaCalculatePage> {
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController totalPeopleController = TextEditingController();
  final FocusNode focusNodeAmount = FocusNode();
  final FocusNode focusNodePeople = FocusNode();

  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    totalAmountController.dispose();
    totalPeopleController.dispose();
    focusNodeAmount.dispose();
    focusNodePeople.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keishaGroups =
        ref.watch(keishaCalculatePageControllerProvider).keishaGroups;

    return Scaffold(
      body: KeyboardActions(
        autoScroll: false,
        config: buildKeyboardConfig(
            focusNodeAmount: focusNodeAmount, focusNodePeople: focusNodePeople),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _inputTotalAmount(context, ref),
                        const SizedBox(width: 12),
                        Expanded(child: _inputTotalPeople(context, ref)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                '傾斜グループ一覧',
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  if (keishaGroups.isEmpty) ...[
                    const Center(
                      child: Text('傾斜グループを追加してください'),
                    ),
                  ] else ...[
                    const Text('傾斜グループ一覧'),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 80,
                      ),
                      child: Scrollbar(
                        controller: scrollController,
                        child: ListView.builder(
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: keishaGroups.length,
                          itemBuilder: (context, index) {
                            final group = keishaGroups[index];
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      '${group.groupName}・',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    '${group.totalPeople}名→',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${group.totalAmount}円',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  if (group.calcSlope ==
                                      CalcSlope.discount) ...[
                                    const Text(
                                      '引き',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ] else if (group.calcSlope ==
                                      CalcSlope.premium) ...[
                                    const Text(
                                      '増し',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                  const SizedBox(
                                    width: 20,
                                  )
                                ]);
                          },
                        ),
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const ResultContainerKeisha(),
              const SizedBox(
                height: 20,
              ),
              eventSaveButton(context, ref),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewGroupPage(),
            ),
          );
        },
        label: const Text(
          'グループを追加',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _inputTotalAmount(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 2,
      child: TextFormField(
        focusNode: focusNodeAmount,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        controller: totalAmountController,
        onChanged: (value) {
          if (value.isEmpty) {
            return;
          }
          ref
              .read(keishaCalculatePageControllerProvider.notifier)
              .setInputTotal(int.parse(value));
          if (ref.read(keishaCalculatePageControllerProvider).inputPeople !=
              -1) {
            ref.read(keishaCalculatePageControllerProvider.notifier).divide();
          }
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            prefixIcon: Icon(Icons.monetization_on_outlined,
                color: Theme.of(context).colorScheme.primary),
            labelText: '合計金額',
            suffix: const Text(
              '円',
              style: TextStyle(color: Colors.grey),
            )),
      ),
    );
  }

  Widget _inputTotalPeople(BuildContext context, WidgetRef ref) {
    return TextFormField(
        focusNode: focusNodePeople,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: totalPeopleController,
        onChanged: (value) {
          if (value.isEmpty) {
            return;
          }
          ref
              .read(keishaCalculatePageControllerProvider.notifier)
              .setInputPeople(int.parse(value));
          ref.read(keishaCalculatePageControllerProvider.notifier).divide();
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            prefixIcon:
                Icon(Icons.group, color: Theme.of(context).colorScheme.primary),
            labelText: '人数',
            suffix: const Text(
              '人',
              style: TextStyle(color: Colors.grey),
            )));
  }

  Widget eventSaveButton(BuildContext context, WidgetRef ref) {
    final isEnabled = totalAmountController.text.isNotEmpty &&
        totalPeopleController.text.isNotEmpty;

    return SizedBox(
      width: 250,
      height: 56,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text(
          'イベントとして保存',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          foregroundColor: Colors.white,
          elevation: isEnabled ? 3 : 0,
          shadowColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: !isEnabled
            ? null
            : () async {
                // イベント数が10件を超える場合は保存できない
                final eventCount = await ref
                    .read(keishaCalculatePageControllerProvider.notifier)
                    .getEventCount();
                if (eventCount >= 10) {
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: const Icon(
                              Icons.error,
                              size: 40,
                            ),
                            title: const Text('イベント数が上限に達しました'),
                            content: const Text(
                                'イベント数が10件を超えたため、これ以上保存できません。イベントを削除してください。'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('閉じる'),
                              )
                            ],
                          );
                        });
                  }
                  return;
                }
                final state = ref.read(keishaCalculatePageControllerProvider);
                final List<KeishaGroupForIsar> keishaGroups = [];
                for (final group in state.keishaGroups) {
                  keishaGroups.add(KeishaGroupForIsar(
                      groupName: group.groupName,
                      totalAmount: group.totalAmount,
                      totalPeople: group.totalPeople,
                      calcSlope: group.calcSlope));
                }
                final eventKeisha = EventKeisha(
                    keishaGroups: keishaGroups,
                    remainPerPerson: state.divideResult,
                    remainPeople: state.remainingPeople,
                    allPeople: int.parse(totalPeopleController.text),
                    date: DateTime.now());
                if (context.mounted) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return EventSavePopUpKeisha(
                          isar: widget.isar,
                          event: eventKeisha,
                        );
                      });
                }
              },
      ),
    );
  }
}
