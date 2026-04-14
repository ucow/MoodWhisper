import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';
import 'package:mood_whisper/features/record/presentation/widgets/emotion_button.dart';
import 'package:mood_whisper/features/record/presentation/widgets/intensity_slider.dart';
import 'package:mood_whisper/features/record/presentation/widgets/note_input.dart';
import 'package:mood_whisper/features/record/presentation/widgets/particle_animation.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen>
    with SingleTickerProviderStateMixin {
  final _noteController = TextEditingController();
  bool _showAnimation = false;
  bool _particleDegraded = false;

  late AnimationController _loadingAnimController;
  late Animation<double> _loadingAnimation1;
  late Animation<double> _loadingAnimation2;
  late Animation<double> _loadingAnimation3;
  late Animation<double> _loadingAnimation4;
  late Animation<double> _loadingAnimation5;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkParticleDegradation();
  }

  void _initAnimations() {
    _loadingAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _loadingAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
    _loadingAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimController,
        curve: const Interval(0.1, 0.3, curve: Curves.easeOut),
      ),
    );
    _loadingAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimController,
        curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
      ),
    );
    _loadingAnimation4 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimController,
        curve: const Interval(0.3, 0.5, curve: Curves.easeOut),
      ),
    );
    _loadingAnimation5 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimController,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _loadingAnimController.forward();
  }

  Future<void> _checkParticleDegradation() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final degraded = await settingsRepo.isParticleAnimationDegraded();
    if (mounted) {
      setState(() {
        _particleDegraded = degraded;
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _loadingAnimController.dispose();
    super.dispose();
  }

  Color _getMoodColor(BuildContext context) {
    final formState = ref.read(recordFormProvider);
    if (formState.moodType == null) {
      return context.colorToken.primary;
    }
    final brightness = Theme.of(context).brightness;
    final moodLevel = _moodToLevel(formState.moodType!);
    return context.colorToken.mood.forLevel(moodLevel, brightness);
  }

  MoodLevel _moodToLevel(moodType) {
    switch (moodType.index) {
      case 0:
        return MoodLevel.veryGood;
      case 1:
        return MoodLevel.good;
      case 2:
        return MoodLevel.neutral;
      case 3:
        return MoodLevel.bad;
      case 4:
        return MoodLevel.veryBad;
      default:
        return MoodLevel.neutral;
    }
  }

  Future<void> _selectDateTime() async {
    final formState = ref.read(recordFormProvider);
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final date = await showDatePicker(
      context: context,
      initialDate: formState.recordedAt ?? now,
      firstDate: sevenDaysAgo,
      lastDate: now,
      selectableDayPredicate: (day) {
        return day.isAfter(sevenDaysAgo.subtract(const Duration(days: 1))) &&
            day.isBefore(now.add(const Duration(days: 1)));
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(formState.recordedAt ?? now),
      );

      if (time != null && mounted) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        ref.read(recordFormProvider.notifier).setRecordedAt(dateTime);
      }
    }
  }

  String _formatRecordedAt(DateTime? dateTime) {
    if (dateTime == null) {
      return '点击选择时间';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (recordDate == today) {
      return '今天 $timeStr';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天 $timeStr';
    } else {
      return '${dateTime.month}/${dateTime.day} $timeStr';
    }
  }

  Future<void> _handleSave() async {
    final formState = ref.read(recordFormProvider);
    if (formState.moodType == null) return;

    setState(() {
      _showAnimation = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final success = await ref.read(recordFormProvider.notifier).save();

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      _noteController.clear();
      setState(() {
        _showAnimation = false;
      });
      ref.invalidate(recentRecordsProvider);
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
    } else if (mounted) {
      setState(() {
        _showAnimation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(recordFormProvider);
    final formNotifier = ref.read(recordFormProvider.notifier);
    final colorToken = context.colorToken;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _selectDateTime,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatRecordedAt(formState.recordedAt),
                style: TextToken.body1.toStyle(color: colorToken.textSecondary),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.edit_calendar,
                size: 16,
                color: colorToken.textSecondary,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今天感觉怎么样？',
                          style:
                              TextToken.h3.toStyle(color: colorToken.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (formState.moodType == null)
                          _buildLoadingMoodIcons()
                        else
                          EmotionButtonBar(
                            selectedMood: formState.moodType,
                            onSelected: formNotifier.selectMood,
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          '情绪强度',
                          style:
                              TextToken.h3.toStyle(color: colorToken.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        IntensitySlider(
                          value: formState.intensity,
                          moodType: formState.moodType,
                          onChanged: formNotifier.setIntensity,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          '备注（可选）',
                          style:
                              TextToken.h3.toStyle(color: colorToken.textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        NoteInput(
                          controller: _noteController,
                          onChanged: formNotifier.setNote,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (formState.error != null)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Text(
                              formState.error!,
                              style: TextToken.body2
                                  .toStyle(color: colorToken.error),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    top: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorToken.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: formState.moodType == null || formState.isSaving
                          ? null
                          : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: formState.moodType != null
                            ? _getMoodColor(context)
                            : colorToken.divider,
                      ),
                      child: formState.isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '保存记录',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showAnimation)
            SaveAnimationOverlay(
              isPlaying: _showAnimation,
              moodType: formState.moodType,
              shouldDegrade: _particleDegraded,
              onComplete: () {
                if (mounted) {
                  setState(() {
                    _showAnimation = false;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoodIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LoadingMoodIcon(animation: _loadingAnimation1, emoji: '😆'),
        _LoadingMoodIcon(animation: _loadingAnimation2, emoji: '😊'),
        _LoadingMoodIcon(animation: _loadingAnimation3, emoji: '😐'),
        _LoadingMoodIcon(animation: _loadingAnimation4, emoji: '😔'),
        _LoadingMoodIcon(animation: _loadingAnimation5, emoji: '😢'),
      ],
    );
  }
}

class _LoadingMoodIcon extends StatelessWidget {
  final Animation<double> animation;
  final String emoji;

  const _LoadingMoodIcon({
    required this.animation,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: context.colorToken.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colorToken.divider,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
