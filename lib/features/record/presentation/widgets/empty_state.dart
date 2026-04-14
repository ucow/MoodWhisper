import 'package:flutter/material.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';

class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({
    super.key,
    this.message = '选择一个表情开始记录吧👋',
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '👋',
            style: TextStyle(
              fontSize: 48,
              color: colorToken.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: TextToken.h3.toStyle(color: colorToken.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '记录你的情绪变化，\n关注心理健康',
            style: TextToken.body2.toStyle(color: colorToken.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
