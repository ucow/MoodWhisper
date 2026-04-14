import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_whisper/app/router/app_router.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';

class RecentRecordsPreview extends ConsumerWidget {
  const RecentRecordsPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentRecords = ref.watch(recentRecordsProvider);
    final colorToken = context.colorToken;

    return recentRecords.when(
      data: (records) {
        if (records.isEmpty) {
          return const SizedBox.shrink();
        }
        final previewRecords = records.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近记录',
                  style: TextToken.h3.toStyle(color: colorToken.textPrimary),
                ),
                TextButton(
                  onPressed: () => context.go(AppRouter.history),
                  child: Text(
                    '查看全部',
                    style: TextToken.body2.toStyle(color: colorToken.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...previewRecords.map((record) => _RecordListItem(record: record)),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RecordListItem extends StatelessWidget {
  final MoodRecord record;

  const _RecordListItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final moodColor = colorToken.mood.forLevel(_moodToLevel(record.moodType), brightness);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: moodColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Center(
            child: Text(
              record.moodType.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          record.moodType.label,
          style: TextToken.body1.toStyle(color: colorToken.textPrimary),
        ),
        subtitle: Text(
          _formatDateTime(record.recordedAt),
          style: TextToken.caption.toStyle(color: colorToken.textSecondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: moodColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '强度 ${record.intensity}',
            style: TextStyle(
              fontSize: 12,
              color: moodColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => context.go(AppRouter.history),
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recordDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (recordDate == today) {
      return '今天 ${_formatTime(dateTime)}';
    } else if (recordDate == today.subtract(const Duration(days: 1))) {
      return '昨天 ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.month}/${dateTime.day} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
