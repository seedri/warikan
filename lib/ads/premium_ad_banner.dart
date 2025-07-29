import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:warikan/ads/ad_banner.dart';
import 'package:warikan/services/premium_service.dart';

/// プレミアムユーザーには広告を表示しないバナー広告ウィジェット
class PremiumAdBanner extends ConsumerStatefulWidget {
  const PremiumAdBanner({super.key});

  @override
  ConsumerState<PremiumAdBanner> createState() => _PremiumAdBannerState();
}

class _PremiumAdBannerState extends ConsumerState<PremiumAdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumAndLoadAd();
  }

  void _checkPremiumAndLoadAd() async {
    final isPremium = await ref.read(premiumServiceProvider).isPremiumUser();
    
    if (!isPremium && mounted) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = AdBanner.createBannerAd();
    _bannerAd!.load().then((_) {
      if (mounted) {
        setState(() {
          _isAdLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(isPremiumProvider).when(
      data: (isPremium) {
        if (isPremium) {
          // プレミアムユーザーの場合は何も表示しない
          return const SizedBox.shrink();
        } else {
          // 無料ユーザーの場合は広告を表示
          if (_bannerAd != null && _isAdLoaded) {
            return SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            );
          } else {
            // 広告が読み込まれていない場合は空のスペースを表示
            return SizedBox(
              width: AdSize.fullBanner.width.toDouble(),
              height: AdSize.fullBanner.height.toDouble(),
              child: Container(
                color: Colors.grey.shade100,
                child: const Center(
                  child: Text(
                    '広告読み込み中...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            );
          }
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) {
        // エラーの場合は通常の広告を表示
        if (_bannerAd != null && _isAdLoaded) {
          return SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}