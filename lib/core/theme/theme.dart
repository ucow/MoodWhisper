import 'package:flutter/material.dart';

/// 情绪等级枚举
enum MoodLevel {
  veryBad(0, '极差'),
  bad(1, '差'),
  neutral(2, '一般'),
  good(3, '好'),
  veryGood(4, '极好');

  const MoodLevel(this.value, this.label);
  final int value;
  final String label;
}

/// 情绪色 Token（5组 × 2模式）
class MoodColors {
  final Color lightVeryGood;
  final Color lightGood;
  final Color lightNeutral;
  final Color lightBad;
  final Color lightVeryBad;
  final Color darkVeryGood;
  final Color darkGood;
  final Color darkNeutral;
  final Color darkBad;
  final Color darkVeryBad;

  const MoodColors({
    required this.lightVeryGood,
    required this.lightGood,
    required this.lightNeutral,
    required this.lightBad,
    required this.lightVeryBad,
    required this.darkVeryGood,
    required this.darkGood,
    required this.darkNeutral,
    required this.darkBad,
    required this.darkVeryBad,
  });

  Color forLevel(MoodLevel level, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (level) {
      case MoodLevel.veryGood:
        return isDark ? darkVeryGood : lightVeryGood;
      case MoodLevel.good:
        return isDark ? darkGood : lightGood;
      case MoodLevel.neutral:
        return isDark ? darkNeutral : lightNeutral;
      case MoodLevel.bad:
        return isDark ? darkBad : lightBad;
      case MoodLevel.veryBad:
        return isDark ? darkVeryBad : lightVeryBad;
    }
  }
}

/// 浅色/深色两套完整色值
class ColorToken {
  // 背景色
  final Color background;
  final Color surface;
  final Color card;
  final Color divider;

  // 文字色
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // 功能色
  final Color primary;
  final Color primaryVariant;
  final Color error;
  final Color success;
  final Color warning;

  // 情绪色
  final MoodColors mood;

  const ColorToken({
    required this.background,
    required this.surface,
    required this.card,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.primary,
    required this.primaryVariant,
    required this.error,
    required this.success,
    required this.warning,
    required this.mood,
  });

  static const light = ColorToken(
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    divider: Color(0xFFE0E0E0),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    textDisabled: Color(0xFFBDBDBD),
    primary: Color(0xFF6C63FF),
    primaryVariant: Color(0xFF5A52D5),
    error: Color(0xFFE53935),
    success: Color(0xFF43A047),
    warning: Color(0xFFFFA726),
    mood: MoodColors(
      lightVeryGood: Color(0xFF4CAF50),
      lightGood: Color(0xFF8BC34A),
      lightNeutral: Color(0xFFFFC107),
      lightBad: Color(0xFFFF9800),
      lightVeryBad: Color(0xFFF44336),
      darkVeryGood: Color(0xFF81C784),
      darkGood: Color(0xFFAED581),
      darkNeutral: Color(0xFFFFD54F),
      darkBad: Color(0xFFFFB74D),
      darkVeryBad: Color(0xFFE57373),
    ),
  );

  static const dark = ColorToken(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    card: Color(0xFF2C2C2C),
    divider: Color(0xFF424242),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    textDisabled: Color(0xFF6E6E6E),
    primary: Color(0xFF9D97FF),
    primaryVariant: Color(0xFF7B75FF),
    error: Color(0xFFEF5350),
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    mood: MoodColors(
      lightVeryGood: Color(0xFF4CAF50),
      lightGood: Color(0xFF8BC34A),
      lightNeutral: Color(0xFFFFC107),
      lightBad: Color(0xFFFF9800),
      lightVeryBad: Color(0xFFF44336),
      darkVeryGood: Color(0xFF81C784),
      darkGood: Color(0xFFAED581),
      darkNeutral: Color(0xFFFFD54F),
      darkBad: Color(0xFFFFB74D),
      darkVeryBad: Color(0xFFE57373),
    ),
  );
}

/// 主题扩展
extension ColorTokenExtension on BuildContext {
  ColorToken get colorToken {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? ColorToken.dark : ColorToken.light;
  }

  MoodColors get moodColors => colorToken.mood;
}

/// ThemeData 工厂方法
class AppTheme {
  static ThemeData lightTheme() {
    const token = ColorToken.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: token.primary,
        secondary: token.primaryVariant,
        surface: token.surface,
        error: token.error,
      ),
      scaffoldBackgroundColor: token.background,
      cardColor: token.card,
      dividerColor: token.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: token.surface,
        foregroundColor: token.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: token.card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: token.textPrimary),
        headlineMedium: TextStyle(color: token.textPrimary),
        headlineSmall: TextStyle(color: token.textPrimary),
        titleLarge: TextStyle(color: token.textPrimary),
        titleMedium: TextStyle(color: token.textPrimary),
        titleSmall: TextStyle(color: token.textPrimary),
        bodyLarge: TextStyle(color: token.textPrimary),
        bodyMedium: TextStyle(color: token.textSecondary),
        bodySmall: TextStyle(color: token.textSecondary),
        labelLarge: TextStyle(color: token.textPrimary),
        labelMedium: TextStyle(color: token.textSecondary),
        labelSmall: TextStyle(color: token.textDisabled),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: token.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: token.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: token.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: token.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: token.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: token.surface,
        selectedItemColor: token.primary,
        unselectedItemColor: token.textSecondary,
      ),
    );
  }

  static ThemeData darkTheme() {
    const token = ColorToken.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: token.primary,
        secondary: token.primaryVariant,
        surface: token.surface,
        error: token.error,
      ),
      scaffoldBackgroundColor: token.background,
      cardColor: token.card,
      dividerColor: token.divider,
      appBarTheme: AppBarTheme(
        backgroundColor: token.surface,
        foregroundColor: token.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: token.card,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: token.textPrimary),
        headlineMedium: TextStyle(color: token.textPrimary),
        headlineSmall: TextStyle(color: token.textPrimary),
        titleLarge: TextStyle(color: token.textPrimary),
        titleMedium: TextStyle(color: token.textPrimary),
        titleSmall: TextStyle(color: token.textPrimary),
        bodyLarge: TextStyle(color: token.textPrimary),
        bodyMedium: TextStyle(color: token.textSecondary),
        bodySmall: TextStyle(color: token.textSecondary),
        labelLarge: TextStyle(color: token.textPrimary),
        labelMedium: TextStyle(color: token.textSecondary),
        labelSmall: TextStyle(color: token.textDisabled),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: token.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: token.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: token.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: token.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: token.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: token.surface,
        selectedItemColor: token.primary,
        unselectedItemColor: token.textSecondary,
      ),
    );
  }
}
