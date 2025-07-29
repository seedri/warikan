import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warikan/models/event_keisha.dart';
import 'package:warikan/models/event_normal.dart';
import 'package:warikan/models/premium_user.dart';
import 'package:warikan/pages/main_page.dart';
import 'package:warikan/providers/theme_provider.dart';
import 'package:warikan/services/premium_service.dart';
import 'package:warikan/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Google Mobile Ads 初期化
    MobileAds.instance.initialize();

    // アプリのドキュメントディレクトリを取得
    final dir = await getApplicationDocumentsDirectory();
    debugPrint('Isar directory: ${dir.path}');
    
    final isar = await Isar.open(
      [EventNormalSchema, EventKeishaSchema, PremiumUserSchema],
      directory: dir.path,
    );
    debugPrint('Isar opened successfully');

    // Premium Service 初期化
    final premiumService = PremiumService(isar);
    premiumService.initializePurchaseStream();

    runApp(ProviderScope(
        overrides: [
          premiumServiceProvider.overrideWithValue(premiumService),
        ],
        child: MyApp(
          isar: isar,
        )));
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // エラー時のフォールバックアプリ
    runApp(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('アプリの初期化に失敗しました'),
              const SizedBox(height: 8),
              Text('エラー: $e'),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.isar});

  final Isar isar;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Warikan',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ref.read(themeControllerProvider.notifier).themeMode,
      home: MainPage(isar: isar),
    );
  }
}
