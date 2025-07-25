import 'package:flutter/material.dart';

class AppThemes {
  // カラーパレット
  static const Color primaryColor = Color(0xFF196B52);
  static const Color primaryVariant = Color(0xFF0E4A36);
  static const Color accentColor = Color(0xFF1EE77B);
  
  // ライトテーマ
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Noto Sans JP',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: accentColor,
    ),
    
    // AppBar テーマ
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto Sans JP',
      ),
      iconTheme: IconThemeData(color: primaryColor),
    ),
    
    // NavigationBar テーマ
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: accentColor.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'Noto Sans JP',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // InputDecoration テーマ
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    
    // ElevatedButton テーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Noto Sans JP',
        ),
      ),
    ),
    
    // Card テーマ
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
    ),
    
    // TabBar テーマ
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 3),
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto Sans JP',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Noto Sans JP',
      ),
    ),
  );
  
  // ダークテーマ
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Noto Sans JP',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accentColor,
      secondary: primaryColor,
      surface: const Color(0xFF1A1A1A),
      onSurface: Colors.white,
    ),
    
    // AppBar テーマ
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto Sans JP',
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    
    // NavigationBar テーマ
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      indicatorColor: accentColor.withOpacity(0.3),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontFamily: 'Noto Sans JP',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    ),
    
    // InputDecoration テーマ
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
    
    // ElevatedButton テーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
        elevation: 2,
        shadowColor: accentColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Noto Sans JP',
        ),
      ),
    ),
    
    // Card テーマ
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF2A2A2A),
    ),
    
    // TabBar テーマ
    tabBarTheme: const TabBarTheme(
      labelColor: accentColor,
      unselectedLabelColor: Colors.white54,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: accentColor, width: 3),
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto Sans JP',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Noto Sans JP',
      ),
    ),
    
    // Scaffold テーマ
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}