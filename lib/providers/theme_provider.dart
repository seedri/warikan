import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

enum AppTheme {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppTheme.light:
        return 'ライト';
      case AppTheme.dark:
        return 'ダーク';
      case AppTheme.system:
        return 'システム設定に従う';
    }
  }
}

@riverpod
class ThemeController extends _$ThemeController {
  static const String _themeKey = 'app_theme';

  @override
  AppTheme build() {
    _loadTheme();
    return AppTheme.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey);
    if (themeName != null) {
      final theme = AppTheme.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => AppTheme.system,
      );
      state = theme;
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
    state = theme;
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }
}