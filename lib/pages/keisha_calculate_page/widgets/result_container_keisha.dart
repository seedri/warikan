import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warikan/gen/assets.gen.dart';
import 'package:warikan/models/calc_slope.dart';
import 'package:warikan/pages/keisha_calculate_page/keisha_calculate_page_controller.dart';
import 'package:warikan/services/premium_service.dart';
import 'package:warikan/services/share_service.dart';

class ResultContainerKeisha extends ConsumerWidget {
  const ResultContainerKeisha({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(keishaCalculatePageControllerProvider);
    final calcResult = state.divideResult;
    final keishaGroups = state.keishaGroups;
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.width * 0.63,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.bgWarikan3.path),
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.2,
                  ),
                  child: Scrollbar(
                    thickness: 5,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: keishaGroups.length,
                      itemBuilder: (context, index) {
                        final group = keishaGroups[index];
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Text(
                                  '${group.groupName}:',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (group.calcSlope == CalcSlope.fit) ...[
                                Text(
                                  '${group.totalAmount}円',
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ] else if (group.calcSlope == CalcSlope.discount) ...[
                                Text(
                                  calcResult % 1 == 0
                                      ? '${(calcResult - group.totalAmount).toStringAsFixed(0)}円'
                                      : '${(calcResult - group.totalAmount).toStringAsFixed(3)}円',
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ] else if (group.calcSlope == CalcSlope.premium) ...[
                                Text(
                                  calcResult % 1 == 0
                                      ? '${(calcResult + group.totalAmount).toStringAsFixed(0)}円'
                                      : '${(calcResult + group.totalAmount).toStringAsFixed(3)}円',
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ]
                            ]);
                      },
                    ),
                  ),
                ),
                AutoSizeText(
                  calcResult == 0
                      ? '金額と人数を入力してください'
                      : state.remainingPeople > 0
                          ? '残り${state.remainingPeople}人:${state.divideResult.toStringAsFixed(0)}円'
                          : (calcResult % 1 == 0 // 整数の場合
                              ? '1人:${calcResult.toStringAsFixed(0)}円' // 整数として表示
                              : '1人:${calcResult.toStringAsFixed(3)}円'), // それ以外は小数点以下3桁
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        if (calcResult > 0) // 計算結果がある場合のみ共有ボタンを表示
          const SizedBox(height: 8),
        if (calcResult > 0)
          isPremiumAsync.when(
            data: (isPremium) => ElevatedButton.icon(
              onPressed: () => _showShareDialog(context, ref, state, isPremium),
              icon: Icon(isPremium ? Icons.share : Icons.star),
              label: Text(isPremium ? '結果を共有' : 'Pro機能'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.amber.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
      ],
    );
  }

  void _showShareDialog(BuildContext context, WidgetRef ref, KeishaCalculatePageState state, bool isPremium) {
    // グループ情報を整理
    final groups = state.keishaGroups.map((group) {
      String slope = '';
      switch (group.calcSlope) {
        case CalcSlope.discount:
          slope = '引き';
          break;
        case CalcSlope.premium:
          slope = '増し';
          break;
        case CalcSlope.fit:
          slope = '固定';
          break;
      }
      
      return {
        'name': group.groupName,
        'amount': group.totalAmount,
        'people': group.totalPeople,
        'slope': slope,
      };
    }).toList();

    final shareText = ShareService.formatKeishaResult(
      totalAmount: state.inputTotal,
      totalPeople: state.inputPeople,
      perPersonAmount: state.divideResult.round(),
      remainingPeople: state.remainingPeople,
      groups: groups,
    );

    ShareService.showShareDialog(
      context: context,
      shareText: shareText,
      isPremium: isPremium,
      onPremiumRequired: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プレミアム機能です。設定画面からアップグレードしてください。'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }
}
