import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(allRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '历史记录',
          style: TextToken.h2.toStyle(color: context.colorToken.textPrimary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allRecordsProvider);
        },
        child: recordsAsync.when(
          data: (records) => records.isEmpty
              ? _EmptyState()
              : _HistoryList(records: records),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(allRecordsProvider),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: colorToken.textDisabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '暂无记录',
            style: TextToken.h3.toStyle(color: colorToken.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '开始记录你的情绪变化吧',
            style: TextToken.body2.toStyle(color: colorToken.textDisabled),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorToken.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '加载失败',
            style: TextToken.h3.toStyle(color: colorToken.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: TextToken.body2.toStyle(color: colorToken.textDisabled),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton(
            onPressed: onRetry,
            child: Text(
              '重试',
              style: TextToken.body1.toStyle(color: colorToken.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<MoodRecord> records;

  const _HistoryList({required this.records});

  @override
  Widget build(BuildContext context) {
    final groupedRecords = _groupByDate(records);

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedRecords[index];
        return _DateGroupSection(
          date: dateGroup.date,
          records: dateGroup.records,
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<MoodRecord> records) {
    final Map<String, List<MoodRecord>> grouped = {};
    for (final record in records) {
      final dateKey = _formatDateKey(record.recordedAt);
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((key) {
      final date = grouped[key]!.first.recordedAt;
      return _DateGroup(date: date, records: grouped[key]!);
    }).toList();
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _DateGroup {
  final DateTime date;
  final List<MoodRecord> records;

  _DateGroup({required this.date, required this.records});
}

class _DateGroupSection extends StatelessWidget {
  final DateTime date;
  final List<MoodRecord> records;

  const _DateGroupSection({required this.date, required this.records});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            _formatDateLabel(date),
            style: TextToken.body2.toStyle(color: colorToken.textSecondary),
          ),
        ),
        ...records.map((record) => _RecordCard(record: record)),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return '今天';
    } else if (recordDate == yesterday) {
      return '昨天';
    } else {
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return '${date.month}月${date.day}日 ${weekdays[date.weekday - 1]}';
    }
  }
}

class _RecordCard extends StatelessWidget {
  final MoodRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final moodLevel = _moodToLevel(record.moodType);
    final moodColor = colorToken.mood.forLevel(moodLevel, brightness);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Text(
                record.moodType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.moodType.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: moodColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          '强度 ${record.intensity}',
                          style: TextToken.caption.toStyle(color: moodColor),
                        ),
                      ),
                    ],
                  ),
                  if (record.note != null && record.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        record.note!,
                        style: TextToken.body2.toStyle(
                          color: colorToken.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      _formatTime(record.recordedAt),
                      style: TextToken.caption.toStyle(
                        color: colorToken.textDisabled,
                      ),
                    ),
                  ),
                ],
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}