import 'package:flutter/material.dart';

/// MoodWhisper Theme System
/// 基于 UI/UX 设计文档 v1.0 §1.2-1.5

// ============================================================================
// 情绪色值对照表
// ============================================================================

/// 浅色模式情绪色
class MoodColorsLight {
  static const Color happy = Color(0xFFFFD93D);    // 开心 - 明亮暖黄
  static const Color calm = Color(0xFF81C784);     // 平静 - 柔和绿
  static const Color sad = Color(0xFF90CAF9);      // 难过 - 柔和蓝
  static const Color angry = Color(0xFFEF9A9A);    // 生气 - 柔和红
  static const Color anxious = Color(0xFFCE93D8);  // 焦虑 - 柔和紫
}

/// 深色模式情绪色
class MoodColorsDark {
  static const Color happy = Color(0xFFE6C235);   // 开心 - 较浅色调低10%
  static const Color calm = Color(0xFF5AB869);     // 平静 - 较浅色调低10%
  static const Color sad = Color(0xFF3D7BC4);      // 难过 - 较浅色调低10%
  static const Color angry = Color(0xFFE05B5B);    // 生气 - 较浅色调低10%
  static const Color anxious = Color(0xFF8A4CA3);  // 焦虑 - 较浅色调低10%
}

// ============================================================================
// 通用色彩 Token
// ============================================================================

class AppColors {
  // 浅色模式
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF5F5F5);
  static const lightTextPrimary = Color(0xFF212121);
  static const lightTextSecondary = Color(0xFF757575);
  static const lightTextTertiary = Color(0xFFBDBDBD);
  static const lightBorder = Color(0xFFE0E0E0);
  static const lightAccent = Color(0xFFFFD93D);
  static const lightSuccess = Color(0xFF81C784);
  static const lightWarning = Color(0xFFFFD54F);
  static const lightError = Color(0xFFEF9A9A);
  static const lightDangerBg = Color(0xFFFFF0F0);
  static const lightDangerText = Color(0xFFD32F2F);

  // 深色模式
  static const darkBackground = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
  static const darkSurfaceVariant = Color(0xFF2C2C2C);
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFFA0A0A0);
  static const darkTextTertiary = Color(0xFF6B6B6B);
  static const darkBorder = Color(0xFF3A3A3A);
  static const darkAccent = Color(0xFFE6C235);
  static const darkSuccess = Color(0xFF5AB869);
  static const darkWarning = Color(0xFFE6C235);
  static const darkError = Color(0xFFE05B5B);
  static const darkDangerBg = Color(0xFF2A1515);
  static const darkDangerText = Color(0xFFEF5350);
}

// ============================================================================
// 间距系统 (8px 基准网格)
// ============================================================================

class AppSpacing {
  static const double xs = 4.0;   // 图标与文字间距
  static const double sm = 8.0;   // 紧凑元素间距
  static const double md = 16.0;  // 标准组件内边距
  static const double lg = 24.0;  // 卡片内边距、区域间距
  static const double xl = 32.0;  // 区块分隔
  static const double xxl = 48.0; // 页面级分隔
}

// ============================================================================
// 圆角与阴影
// ============================================================================

class AppRadius {
  static const double sm = 8.0;    // 按钮、输入框
  static const double md = 12.0;   // 卡片
  static const double lg = 16.0;   // 底部弹窗、模态框
  static const double full = 999.0; // 头像、圆形按钮、标签

  static BoxShadow cardShadow({bool isDark = false}) {
    return BoxShadow(
      color: isDark 
        ? const Color(0x00000000) 
        : const Color(0x14000000),
      offset: const Offset(0, 2),
      blurRadius: 8,
    );
  }

  static BoxShadow elevatedShadow({bool isDark = false}) {
    return BoxShadow(
      color: isDark 
        ? const Color(0x1F000000) 
        : const Color(0x1F000000),
      offset: const Offset(0, 8),
      blurRadius: 24,
    );
  }
}

// ============================================================================
// 字体系统
// ============================================================================

class AppTypography {
  // H1 - 页面标题（"记录情绪"）
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
  );

  // H2 - 区域标题（"今日记录"）
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  // H3 - 子标题、Tab 标签
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );

  // Body - 正文、备注文字
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  // Small - 辅助信息、时间戳
  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  // Caption - 标签、极小提示
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );
}

// ============================================================================
// ThemeData 生成器
// ============================================================================

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccent,
        secondary: AppColors.lightSuccess,
        surface: AppColors.lightSurface,
        error: AppColors.lightError,
        onPrimary: Color(0xFF212121),
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.lightAccent,
        unselectedLabelColor: AppColors.lightTextSecondary,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.small,
        bodySmall: AppTypography.caption,
      ).apply(
        bodyColor: AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccent,
        secondary: AppColors.darkSuccess,
        surface: AppColors.darkSurface,
        error: AppColors.darkError,
        onPrimary: const Color(0xFF121212),
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.darkAccent,
        unselectedLabelColor: AppColors.darkTextSecondary,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.small,
        bodySmall: AppTypography.caption,
      ).apply(
        bodyColor: AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
    );
  }
}

// ============================================================================
// 情绪色工具类 (MoodType 定义在 data/models/mood_type.dart)
// ============================================================================

class MoodColorHelper {
  /// 根据情绪类型字符串和是否为深色模式获取对应颜色
  static Color getColorByKey(String moodKey, {bool isDark = false}) {
    final colors = isDark ? MoodColorsDark() : MoodColorsLight();
    return colors.getColor(moodKey);
  }
}

extension MoodColorsLightExtension on MoodColorsLight {
  Color getColor(String moodKey) {
    switch (moodKey) {
      case 'happy': return happy;
      case 'calm': return calm;
      case 'sad': return sad;
      case 'angry': return angry;
      case 'anxious': return anxious;
      default: return happy;
    }
  }
}

extension MoodColorsDarkExtension on MoodColorsDark {
  Color getColor(String moodKey) {
    switch (moodKey) {
      case 'happy': return happy;
      case 'calm': return calm;
      case 'sad': return sad;
      case 'angry': return angry;
      case 'anxious': return anxious;
      default: return happy;
    }
  }
}
