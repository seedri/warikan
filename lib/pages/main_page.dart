import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:warikan/ads/premium_ad_banner.dart';
import 'package:warikan/pages/calculate_page.dart';
import 'package:warikan/pages/event_page/event_page.dart';
import 'package:warikan/pages/setting_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.isar,
  });

  final Isar isar;
  @override
  State<MainPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> pages;

  // レビュー依頼の設定
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 1, // Show rate popup on first day of install.
    minLaunches:
        2, // Show rate popup after 5 launches of app after minDays is passed.
    remindDays: 5,
    remindLaunches: 5,
  );

  @override
  void initState() {
    super.initState();
    pages = [
      CalculatePage(
        isar: widget.isar,
      ),
      EventPage(
        isar: widget.isar,
      ),
      const SettingPage()
    ];

    rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(child: pages[_selectedIndex]),
          const PremiumAdBanner(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 55,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(
                size: 30,
                Icons.calculate,
              ),
              label: '割り勘'),
          NavigationDestination(
              icon: Icon(size: 30, Icons.event), label: 'イベント'),
          NavigationDestination(
             icon: Icon(size: 30, Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
