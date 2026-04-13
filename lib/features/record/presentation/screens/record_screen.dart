import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(recordFormProvider);
    final formNotifier = ref.read(recordFormProvider.notifier);
    final colorToken = context.colorToken;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '记录情绪',
          style: TextToken.h2.toStyle(color: colorToken.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今天感觉怎么样？',
                style: TextToken.h3.toStyle(color: colorToken.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              _MoodSelector(
                selectedMood: formState.moodType,
                onSelected: formNotifier.selectMood,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '情绪强度',
                style: TextToken.h3.toStyle(color: colorToken.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${formState.intensity}',
                style: TextToken.h1.toStyle(color: colorToken.primary),
              ),
              Slider(
                value: formState.intensity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: colorToken.primary,
                inactiveColor: colorToken.divider,
                onChanged: (value) => formNotifier.setIntensity(value.round()),
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
              const SizedBox(height: AppSpacing.lg),
              Text(
                '备注（可选）',
                style: TextToken.h3.toStyle(color: colorToken.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '写下今天的心情...',
                  hintStyle: TextToken.body1.toStyle(color: colorToken.textDisabled),
                ),
                style: TextToken.body1.toStyle(color: colorToken.textPrimary),
                onChanged: formNotifier.setNote,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (formState.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    formState.error!,
                    style: TextToken.body2.toStyle(color: colorToken.error),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: formState.isSaving ? null : _handleSave,
                  child: formState.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '保存记录',
                          style: TextToken.body1.toStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final notifier = ref.read(recordFormProvider.notifier);
    final success = await notifier.save();
    if (success && mounted) {
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '记录已保存',
            style: TextToken.body2.toStyle(color: Colors.white),
          ),
          backgroundColor: context.colorToken.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
    }
  }
}

class _MoodSelector extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onSelected;

  const _MoodSelector({
    required this.selectedMood,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: MoodType.values.map((mood) {
        final isSelected = selectedMood == mood;
        return _MoodChip(
          mood: mood,
          isSelected: isSelected,
          onTap: () => onSelected(mood),
        );
      }).toList(),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final moodLevel = _moodToLevel(mood);
    final moodColor = colorToken.mood.forLevel(moodLevel, brightness);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? moodColor.withOpacity(0.2) : colorToken.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? moodColor : colorToken.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              mood.label,
              style: TextToken.body2.toStyle(
                color: isSelected ? moodColor : colorToken.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
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
}
