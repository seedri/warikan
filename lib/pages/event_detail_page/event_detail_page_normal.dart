import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warikan/ads/ad_manager.dart';
import 'package:warikan/models/event_normal.dart';
import 'package:warikan/pages/normal_calculate_page/normal_calculate_page_controller.dart';

class EventDetailPageNormal extends StatefulWidget {
  const EventDetailPageNormal(
      {super.key, required this.event, required this.isar});
  final EventNormal event;
  final Isar isar;

  @override
  State<EventDetailPageNormal> createState() => _EventDetailPageNormalState();
}

class _EventDetailPageNormalState extends State<EventDetailPageNormal> {
  late List<TextEditingController> _nameControllers;
  late List<bool> _payList;
  bool _isChanged = false;
  late InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    interstitialAdJudge();
    _initializeControllers();
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

  void _initializeControllers() {
    _nameControllers = List.generate(
      widget.event.remainPeople,
      (index) => TextEditingController(text: widget.event.nameList[index]),
    );
    _payList = widget.event.payList;
  }

  Future<void> _updateEventData() async {
    widget.event.nameList
        .setAll(0, _nameControllers.map((controller) => controller.text));
    widget.event.payList.setAll(0, _payList);

    await widget.isar.writeTxn(() async {
      await widget.isar.eventNormals.put(widget.event);
    });
    setState(() => _isChanged = false);
  }

  void _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('イベントの削除'),
        content: const Text('本当に削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await widget.isar.writeTxn(() async {
                await widget.isar.eventNormals.delete(widget.event.id);
              });
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('イベントが削除されました')),
                );
              }
            },
            child: const Text(
              '削除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (result == true) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _onListChanged() {
    setState(() => _isChanged = true);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy/MM/dd').format(widget.event.date);
    final fractionText = _getFractionText(widget.event.fraction);
    final differenceText =
        _getDifferenceText(widget.event.difference, widget.event.fraction);
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            'ノーマル割り勘詳細',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _showDeleteDialog,
              icon:
                  const Icon(Icons.delete_forever, color: Colors.red, size: 35),
            ),
          ],
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventInfo('イベント名', widget.event.eventName, 24),
                _buildEventInfo(
                  '1人あたり',
                  widget.event.remainPerPerson % 1 == 0
                      ? '${widget.event.remainPerPerson.toStringAsFixed(0)}円'
                      : '${widget.event.remainPerPerson.toStringAsFixed(3)}円',
                ),
                _buildEventInfo('人数', '${widget.event.remainPeople}人'),
                _buildEventInfo('端数', fractionText),
                if (widget.event.difference != 0)
                  _buildEventInfo('過不足', differenceText),
                _buildEventInfo('日付', formattedDate, 16),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('・回収チェックリスト', style: TextStyle(fontSize: 18)),
                    ElevatedButton(
                      onPressed: _isChanged ? _updateEventData : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        '保存',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.event.remainPeople,
                  itemBuilder: (context, index) => _buildChecklistItem(index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventInfo(String title, String value, [double fontSize = 18]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Text('$title: $value', style: TextStyle(fontSize: fontSize)),
    );
  }

  Widget _buildChecklistItem(int index) {
    return Row(
      children: [
        Checkbox(
          value: _payList[index],
          onChanged: (value) {
            setState(() => _payList[index] = value ?? false);
            _onListChanged();
          },
        ),
        Expanded(
          child: TextFormField(
            controller: _nameControllers[index],
            decoration: InputDecoration(labelText: '名前 ${index + 1}'),
            onChanged: (_) => _onListChanged(),
          ),
        ),
      ],
    );
  }

  String _getFractionText(FractionRound fraction) {
    switch (fraction) {
      case FractionRound.none:
        return '処理なし';
      case FractionRound.roundDown:
        return '切り下げ';
      case FractionRound.roundUp:
        return '切り上げ';
    }
  }

  String _getDifferenceText(double difference, FractionRound fraction) {
    if (difference == 0) return 'なし';
    final type = fraction == FractionRound.roundDown ? '不足' : '余り';
    return difference % 1 == 0
        ? '${difference.toStringAsFixed(0)}円$type'
        : '${difference.toStringAsFixed(3)}円$type';
  }
}
