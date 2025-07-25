import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:warikan/models/event_keisha.dart';
import 'package:warikan/models/event_normal.dart';
import 'package:warikan/pages/main_page.dart';
import 'package:warikan/providers/theme_provider.dart';
import 'package:warikan/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // アプリのドキュメントディレクトリを取得
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [EventNormalSchema, EventKeishaSchema],
    directory: dir.path,
  );
  runApp(ProviderScope(
      child: MyApp(
    isar: isar,
  )));
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
