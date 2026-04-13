import 'package:flutter/material.dart';
import 'package:mood_whisper/core/theme/fonts.dart';

/// 构建 textTheme，平台字体自动适配：iOS SF Pro / Android Roboto
TextTheme buildTextTheme({Color? primaryColor, Color? secondaryColor}) {
  return TextTheme(
    // H1 → displayLarge
    displayLarge: TextToken.h1.toStyle(color: primaryColor),
    // H2 → displayMedium
    displayMedium: TextToken.h2.toStyle(color: primaryColor),
    // H3 → displaySmall
    displaySmall: TextToken.h3.toStyle(color: primaryColor),
    // Body1 → bodyLarge
    bodyLarge: TextToken.body1.toStyle(color: primaryColor),
    // Body2 → bodyMedium
    bodyMedium: TextToken.body2.toStyle(color: secondaryColor),
    // Caption → bodySmall
    bodySmall: TextToken.caption.toStyle(color: secondaryColor),
    // Overline → labelSmall
    labelSmall: TextToken.overline.toStyle(color: secondaryColor),
    // Title mappings
    titleLarge: TextToken.h2.toStyle(color: primaryColor),
    titleMedium: TextToken.h3.toStyle(color: primaryColor),
    titleSmall: TextToken.body1.toStyle(color: primaryColor),
    labelLarge: TextToken.body2.toStyle(color: primaryColor),
    labelMedium: TextToken.caption.toStyle(color: secondaryColor),
  );
}

/// BuildContext 扩展：快速获取 TextToken 对应 TextStyle
extension TextTokenExtension on BuildContext {
  TextStyle textStyle(TextToken token, {Color? color}) {
    return token.toStyle(color: color);
  }
}
