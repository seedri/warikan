import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warikan/ads/ad_manager.dart';
import 'package:warikan/models/calc_slope.dart';
import 'package:warikan/models/event_keisha.dart';
import 'package:warikan/models/keisha_group_for_isar.dart';

class EventDetailPageKeisha extends StatefulWidget {
  const EventDetailPageKeisha({
    super.key,
    required this.event,
    required this.isar,
  });

  final EventKeisha event;
  final Isar isar;

  @override
  State<EventDetailPageKeisha> createState() => _EventDetailPageKeishaState();
}

class _EventDetailPageKeishaState extends State<EventDetailPageKeisha> {
  late List<TextEditingController> _nameControllers;
  late List<bool> _payList;
  bool _isChanged = false;
  late InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    interstitialAdJudge();
    _nameControllers = List.generate(
      widget.event.allPeople,
      (index) => TextEditingController(text: widget.event.nameList[index]),
    );
    _payList = List.from(widget.event.payList);
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void interstitialAdJudge() async {
    bool showInterstitial = await _detailPageCheckCounter();
    if (showInterstitial) {
      loadInterstitialAd();
    }
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAd.show();
          debugPrint('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  Future<bool> _detailPageCheckCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int adCount = prefs.getInt('adCount') ?? 0;
    adCount++;
    await prefs.setInt('adCount', adCount);
    if (adCount >= 5) {
      await prefs.remove('adCount'); // カウントをリセット
      return true;
    }
    return false;
  }

  Future<void> _updateEventData() async {
    widget.event.nameList
        .setAll(0, _nameControllers.map((controller) => controller.text));
    widget.event.payList.setAll(0, _payList);

    await widget.isar.writeTxn(() async {
      await widget.isar.eventKeishas.put(widget.event);
    });

    setState(() {
      _isChanged = false;
    });
  }

  void _onListChanged() {
    setState(() {
      _isChanged = true;
    });
  }

  String _formatGroupInfo(KeishaGroupForIsar group) {
    final amount = widget.event.remainPerPerson + (group.totalAmount ?? 0);
    final formattedAmount = widget.event.remainPerPerson % 1 == 0
        ? '${amount.toInt()}円'
        : '${amount.toStringAsFixed(3)}円';

    switch (group.calcSlope) {
      case CalcSlope.fit:
        return '${group.groupName}: ${group.totalPeople}人 金額: ${group.totalAmount}円 (キリよく)';
      case CalcSlope.premium:
        return '${group.groupName}: ${group.totalPeople}人 金額: $formattedAmount (割り増し: ${group.totalAmount}円)';
      case CalcSlope.discount:
        final discountedAmount =
            widget.event.remainPerPerson - (group.totalAmount ?? 0);
        return '${group.groupName}: ${group.totalPeople}人 金額: ${discountedAmount.toStringAsFixed(3)}円 (割り引き: ${group.totalAmount}円)';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('yyyy/MM/dd').format(widget.event.date);
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            '傾斜割り勘詳細',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon:
                  const Icon(Icons.delete_forever, color: Colors.red, size: 35),
            ),
          ],
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventInfo(formattedDate),
                const SizedBox(height: 10),
                _buildCheckList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'イベント名: ${widget.event.eventName}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '1人あたり: ${widget.event.remainPerPerson.toStringAsFixed(widget.event.remainPerPerson % 1 == 0 ? 0 : 3)}円',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        if (widget.event.keishaGroups != null)
          ...widget.event.keishaGroups!.map((group) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: Text(_formatGroupInfo(group),
                  style: const TextStyle(fontSize: 18)),
            );
          }),
        Text(
          widget.event.keishaGroups!.isEmpty
              ? '人数: ${widget.event.allPeople}人'
              : 'その他 ${widget.event.remainPeople}人: ${widget.event.remainPerPerson.toStringAsFixed(widget.event.remainPerPerson % 1 == 0 ? 0 : 3)}円',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text('日付: $formattedDate', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCheckList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('・回収チェックリスト', style: TextStyle(fontSize: 18)),
            ElevatedButton(
              onPressed: _isChanged ? _updateEventData : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('保存',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.event.allPeople,
          itemBuilder: (context, index) {
            return CheckListItem(
              controller: _nameControllers[index],
              isChecked: _payList[index],
              label: '名前 ${index + 1}',
              onCheckChanged: (value) {
                setState(() {
                  _payList[index] = value ?? false;
                  _onListChanged();
                });
              },
              onTextChanged: (value) {
                _onListChanged();
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final isDeleted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('イベントの削除'),
          content: const Text('本当に削除しますか？'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                await widget.isar.writeTxn(() async {
                  await widget.isar.eventKeishas.delete(widget.event.id);
                });
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('イベントが削除されました')),
                  );
                }
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (isDeleted ?? false) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class CheckListItem extends StatelessWidget {
  const CheckListItem({
    super.key,
    required this.controller,
    required this.isChecked,
    required this.label,
    required this.onCheckChanged,
    required this.onTextChanged,
  });

  final TextEditingController controller;
  final bool isChecked;
  final String label;
  final ValueChanged<bool?> onCheckChanged;
  final ValueChanged<String> onTextChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: isChecked, onChanged: onCheckChanged),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            onChanged: onTextChanged,
          ),
        ),
      ],
    );
  }
}
