import 'package:flutter/material.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';

class IntensitySlider extends StatelessWidget {
  final int value;
  final MoodType? moodType;
  final ValueChanged<int> onChanged;

  const IntensitySlider({
    super.key,
    required this.value,
    required this.moodType,
    required this.onChanged,
  });

  Color _getActiveColor(BuildContext context) {
    if (moodType == null) {
      return context.colorToken.primary;
    }
    final brightness = Theme.of(context).brightness;
    final moodLevel = _moodToLevel(moodType!);
    return context.colorToken.mood.forLevel(moodLevel, brightness);
  }

  MoodLevel _moodToLevel(MoodType type) {
    switch (type) {
      case MoodType.great:
        return MoodLevel.veryGood;
      case MoodType.good:
        return MoodLevel.good;
      case MoodType.neutral:
        return MoodLevel.neutral;
      case MoodType.bad:
        return MoodLevel.bad;
      case MoodType.terrible:
        return MoodLevel.veryBad;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final activeColor = _getActiveColor(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final intensity = index + 1;
            final isSelected = value == intensity;
            return GestureDetector(
              onTap: () => onChanged(intensity),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: isSelected ? 48 : 40,
                height: isSelected ? 48 : 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withOpacity(0.2)
                      : colorToken.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: isSelected ? activeColor : colorToken.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$intensity',
                    style: TextStyle(
                      fontSize: isSelected ? 18 : 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? activeColor : colorToken.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: colorToken.divider,
            thumbColor: activeColor,
            overlayColor: activeColor.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '轻微',
              style: TextToken.caption.toStyle(color: colorToken.textSecondary),
            ),
            Text(
              '强烈',
              style: TextToken.caption.toStyle(color: colorToken.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
