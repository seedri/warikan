// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:warikan/models/event_keisha.dart';
import 'package:warikan/models/event_normal.dart';

import 'package:warikan/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(
          isar: await Isar.open(
            [EventNormalSchema, EventKeishaSchema],
            directory: '', // テスト用の空のディレクトリ
          ),
        ),
      ),
    );

    // アプリが正常に起動することを確認
    expect(find.text('割り勘'), findsOneWidget);
    expect(find.text('イベント'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}
