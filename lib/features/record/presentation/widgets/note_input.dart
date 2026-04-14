import 'package:flutter/material.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';

class NoteInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLength;

  const NoteInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.maxLength = 500,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: controller,
          maxLines: 4,
          maxLength: maxLength,
          buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) {
            return null;
          },
          decoration: InputDecoration(
            hintText: '写下今天的心情...',
            hintStyle: TextToken.body1.toStyle(color: colorToken.textDisabled),
          ),
          style: TextToken.body1.toStyle(color: colorToken.textPrimary),
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.xs),
        _NoteCharCount(
          currentLength: controller.text.length,
          maxLength: maxLength,
        ),
      ],
    );
  }
}

class _NoteCharCount extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const _NoteCharCount({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    Color getColor() {
      if (currentLength >= maxLength) {
        return colorToken.error;
      } else if (currentLength >= maxLength * 0.9) {
        return colorToken.warning;
      }
      return colorToken.textSecondary;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: currentLength >= maxLength * 0.8 ? 1.0 : 0.0,
      child: Text(
        '$currentLength/$maxLength',
        style: TextToken.caption.toStyle(color: getColor()),
      ),
    );
  }
}
