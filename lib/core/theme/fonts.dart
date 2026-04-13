import 'package:flutter/material.dart';

/// 文字 Token 枚举，定义全局文字规范
enum TextToken {
  h1(fontSize: 28, fontWeight: FontWeight.w700, height: 1.3),
  h2(fontSize: 24, fontWeight: FontWeight.w600, height: 1.35),
  h3(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
  body1(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
  body2(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
  caption(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
  overline(fontSize: 10, fontWeight: FontWeight.w500, height: 1.4);

  const TextToken({
    required this.fontSize,
    required this.fontWeight,
    required this.height,
  });

  final double fontSize;
  final FontWeight fontWeight;
  final double height;

  TextStyle toStyle({Color? color}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }
}
