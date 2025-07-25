import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:warikan/models/event_normal.dart';
import 'package:warikan/pages/normal_calculate_page/normal_calculate_page_controller.dart';
import 'package:warikan/pages/normal_calculate_page/widgets/event_save_pop_up.dart';
import 'package:warikan/pages/normal_calculate_page/widgets/result_container.dart';
import 'package:warikan/pages/utils/keyboard_config.dart';

class NormalCalculatePage extends ConsumerStatefulWidget {
  final Isar isar;

  const NormalCalculatePage({super.key, required this.isar});

  @override
  _NormalCalculatePageState createState() => _NormalCalculatePageState();
}

class _NormalCalculatePageState extends ConsumerState<NormalCalculatePage> {
  final int fraction = 1;
  Set<FractionRound> selected = {FractionRound.none};
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController totalPeopleController = TextEditingController();
  final FocusNode focusNodeAmount = FocusNode();
  final FocusNode focusNodePeople = FocusNode();

  @override
  void dispose() {
    totalAmountController.dispose();
    totalPeopleController.dispose();
    focusNodeAmount.dispose();
    focusNodePeople.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = buildKeyboardConfig(
        focusNodeAmount: focusNodeAmount, focusNodePeople: focusNodePeople);
    return KeyboardActions(
      config: config,
      child: SingleChildScrollView(
        child: Column(
          children: [
          Row(
            children: [
              _inputTotalAmount(context, ref),
              Expanded(child: _inputTotalPeople(context, ref)),
            ],
          ),
          const Text(
            '端数処理',
          ),
          SegmentedButton<FractionRound>(
              onSelectionChanged: (value) {
                selected = value;
                ref
                    .read(normalCalculatePageControllerProvider.notifier)
                    .setFraction(selected.contains(FractionRound.none)
                        ? FractionRound.none
                        : selected.first);
                ref
                    .read(normalCalculatePageControllerProvider.notifier)
                    .divide();
              },
              style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.grey[350],
                  selectedBackgroundColor:
                      const Color.fromARGB(255, 104, 245, 172)),
              segments: const [
                ButtonSegment(
                    value: FractionRound.none,
                    label: Text(
                      '処理なし',
                    )),
                ButtonSegment(
                    value: FractionRound.roundUp,
                    label: Text(
                      '切り上げ',
                    )),
                ButtonSegment(
                    value: FractionRound.roundDown,
                    label: Text(
                      '切り下げ',
                    ))
              ],
              selected: selected),
          if (ref.watch(normalCalculatePageControllerProvider).fraction !=
              FractionRound.none)
            _fractionChoiceChips(ref),
          const ResultContainer(),
          const SizedBox(
            height: 10,
          ),
          eventSaveButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _inputTotalAmount(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.55,
      child: TextFormField(
        focusNode: focusNodeAmount,
        keyboardType: TextInputType.number,
        controller: totalAmountController,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.next,
        onChanged: (value) {
          if (value.isEmpty) {
            return;
          }
          ref
              .read(normalCalculatePageControllerProvider.notifier)
              .setInputTotal(int.parse(value));
          if (ref.read(normalCalculatePageControllerProvider).inputPeople !=
              -1) {
            ref.read(normalCalculatePageControllerProvider.notifier).divide();
          }
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            prefixIcon: Icon(Icons.monetization_on_outlined),
            labelText: '合計金額',
            suffix: Text(
              '円',
              style: TextStyle(color: Colors.black),
            )),
      ),
    );
  }

  Widget _inputTotalPeople(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: TextFormField(
        focusNode: focusNodePeople,
        keyboardType: TextInputType.number,
        controller: totalPeopleController,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          if (value.isEmpty) {
            return;
          }
          ref
              .read(normalCalculatePageControllerProvider.notifier)
              .setInputPeople(int.parse(value));
          ref.read(normalCalculatePageControllerProvider.notifier).divide();
        },
        decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            prefixIcon: Icon(Icons.group),
            labelText: '人数',
            suffix: Text(
              '人',
              style: TextStyle(color: Colors.black),
            )),
      ),
    );
  }

  Widget _fractionChoiceChips(WidgetRef ref) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text("1円"),
          selected: ref
                  .watch(normalCalculatePageControllerProvider)
                  .fractionPrice ==
              1,
          onSelected: (_) {
            ref
                .read(normalCalculatePageControllerProvider.notifier)
                .setFractionPrice(1);
            ref.read(normalCalculatePageControllerProvider.notifier).divide();
          },
        ),
        ChoiceChip(
          label: const Text("10円"),
          selected: ref
                  .watch(normalCalculatePageControllerProvider)
                  .fractionPrice ==
              10,
          onSelected: (_) {
            ref
                .read(normalCalculatePageControllerProvider.notifier)
                .setFractionPrice(10);
            ref.read(normalCalculatePageControllerProvider.notifier).divide();
          },
        ),
        ChoiceChip(
          label: const Text("100円"),
          selected: ref
                  .watch(normalCalculatePageControllerProvider)
                  .fractionPrice ==
              100,
          onSelected: (_) {
            ref
                .read(normalCalculatePageControllerProvider.notifier)
                .setFractionPrice(100);
            ref.read(normalCalculatePageControllerProvider.notifier).divide();
          },
        ),
        ChoiceChip(
          label: const Text("1000円"),
          selected: ref
                  .watch(normalCalculatePageControllerProvider)
                  .fractionPrice ==
              1000,
          onSelected: (_) {
            ref
                .read(normalCalculatePageControllerProvider.notifier)
                .setFractionPrice(1000);
            ref.read(normalCalculatePageControllerProvider.notifier).divide();
          },
        ),
      ],
    );
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
          backgroundColor: isEnabled 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
          foregroundColor: Colors.white,
          elevation: isEnabled ? 2 : 0,
        ),
        onPressed: !isEnabled
            ? null
            : () async {
                  // イベント数が10件を超える場合は保存できない
                  final eventCount = await ref
                      .read(normalCalculatePageControllerProvider.notifier)
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

                  final state = ref.read(normalCalculatePageControllerProvider);
                  final eventNormal = EventNormal(
                      remainPerPerson: state.divideResult,
                      remainPeople: state.inputPeople,
                      fraction: state.fraction,
                      difference: state.difference,
                      date: DateTime.now());
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return EventSavePopUp(
                            isar: widget.isar,
                            event: eventNormal,
                          );
                        });
                  }
                },
      ),
    );
  }
}
