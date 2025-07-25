import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isar/isar.dart';
import 'package:warikan/ads/ad_banner.dart';
import 'package:warikan/pages/keisha_calculate_page/keisha_calculate_page.dart';
import 'package:warikan/pages/normal_calculate_page/normal_calculate_page.dart';
import 'package:warikan/pages/widgets/un_focus.dart';

class CalculatePage extends StatefulWidget {
  const CalculatePage({super.key, required this.isar});

  final Isar isar;

  @override
  _CalculatePageState createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BannerAd bannerAd;

  @override
  void initState() {
    super.initState();
    bannerAd = AdBanner.createBannerAd();
    bannerAd.load();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdWidget bannerAdWidget = AdWidget(ad: bannerAd);
    return UnFocus(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '傾斜割り勘'),
              Tab(text: 'ノーマル割り勘'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            KeishaCalculatePage(isar: widget.isar),
            NormalCalculatePage(isar: widget.isar),
          ],
        ),
        bottomNavigationBar: SizedBox(
            height: bannerAd.size.height.toDouble(),
            width: bannerAd.size.width.toDouble(),
            child: bannerAdWidget),
      ),
    );
  }
}
