import 'package:fl_chart/fl_chart.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRecords = ref.watch(todayRecordsProvider);
    final weekStats = ref.watch(weekStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '仪表盘',
          style: TextToken.h2.toStyle(color: context.colorToken.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayRecordsProvider);
            ref.invalidate(weekStatsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                todayRecords.when(
                  data: (records) => _TodayOverviewCard(records: records),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const _ErrorCard(message: '加载今日数据失败'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '近7天情绪趋势',
                  style: TextToken.h3.toStyle(color: context.colorToken.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                weekStats.when(
                  data: (records) => _WeekTrendChart(records: records),
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const _ErrorCard(message: '加载趋势数据失败'),
                ),
                const SizedBox(height: AppSpacing.xl),
                _QuickRecordButton(
                  onTap: () => context.go(AppRouter.record),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayOverviewCard extends StatelessWidget {
  final List<MoodRecord> records;

  const _TodayOverviewCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final count = records.length;
    final avgIntensity = count > 0
        ? records.map((r) => r.intensity).reduce((a, b) => a + b) / count
        : 0.0;
    final dominantMood = _getDominantMood(records);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日情绪概览',
              style: TextToken.h3.toStyle(color: colorToken.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatItem(
                  label: '记录数',
                  value: count.toString(),
                  icon: Icons.edit_note,
                ),
                const SizedBox(width: AppSpacing.lg),
                _StatItem(
                  label: '平均强度',
                  value: count > 0 ? avgIntensity.toStringAsFixed(1) : '-',
                  icon: Icons.speed,
                ),
                const SizedBox(width: AppSpacing.lg),
                _StatItem(
                  label: '主导情绪',
                  value: dominantMood != null ? dominantMood.emoji : '-',
                  icon: Icons.emoji_emotions,
                ),
              ],
            ),
            if (count == 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  '今天还没有记录，点击下方按钮开始记录吧~',
                  style: TextToken.body2.toStyle(color: colorToken.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  MoodType? _getDominantMood(List<MoodRecord> records) {
    if (records.isEmpty) return null;
    final moodCounts = <MoodType, int>{};
    for (final record in records) {
      moodCounts[record.moodType] = (moodCounts[record.moodType] ?? 0) + 1;
    }
    return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: colorToken.primary, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextToken.h2.toStyle(color: colorToken.textPrimary),
          ),
          Text(
            label,
            style: TextToken.caption.toStyle(color: colorToken.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WeekTrendChart extends StatelessWidget {
  final List<MoodRecord> records;

  const _WeekTrendChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final barGroups = _buildBarGroups(colorToken, brightness);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 200,
          child: barGroups.isEmpty
              ? Center(
                  child: Text(
                    '暂无数据',
                    style: TextToken.body2.toStyle(color: colorToken.textSecondary),
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 5,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => colorToken.card,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final dayLabel = _getDayLabel(group.x);
                          return BarTooltipItem(
                            '$dayLabel\n',
                            TextToken.caption.toStyle(color: colorToken.textPrimary),
                            children: [
                              TextSpan(
                                text: rod.toY.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final label = _getDayLabel(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: TextToken.caption.toStyle(
                                  color: colorToken.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 || value == 3 || value == 5) {
                              return Text(
                                value.toInt().toString(),
                                style: TextToken.caption.toStyle(
                                  color: colorToken.textSecondary,
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: colorToken.divider,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ColorToken colorToken, Brightness brightness) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<BarChartGroupData> groups = [];

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayRecords = records.where((r) {
        final recordDate = DateTime(
          r.recordedAt.year,
          r.recordedAt.month,
          r.recordedAt.day,
        );
        return recordDate == day;
      }).toList();

      final avgIntensity = dayRecords.isEmpty
          ? 0.0
          : dayRecords.map((r) => r.intensity).reduce((a, b) => a + b) /
              dayRecords.length;

      final moodLevel = _intensityToMoodLevel(avgIntensity);
      final color = colorToken.mood.forLevel(moodLevel, brightness);

      groups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: avgIntensity,
              color: dayRecords.isEmpty ? color.withOpacity(0.3) : color,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return groups;
  }

  MoodLevel _intensityToMoodLevel(double intensity) {
    if (intensity <= 0) return MoodLevel.neutral;
    if (intensity <= 1.5) return MoodLevel.bad;
    if (intensity <= 2.5) return MoodLevel.neutral;
    if (intensity <= 3.5) return MoodLevel.good;
    return MoodLevel.veryGood;
  }

  String _getDayLabel(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = today.subtract(Duration(days: 6 - index));
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '${day.month}/${day.day}${weekdays[day.weekday - 1]}';
  }
}

class _QuickRecordButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickRecordButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add),
        label: Text(
          '快速记录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 120,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextToken.body2.toStyle(color: context.colorToken.error),
        ),
      ),
    );
  }
}