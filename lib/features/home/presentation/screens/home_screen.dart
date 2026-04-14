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
import 'package:mood_whisper/features/home/presentation/widgets/recent_records_preview.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRecords = ref.watch(todayRecordsProvider);
    final viewMode = ref.watch(chartViewModeProvider);

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
            ref.invalidate(monthStatsProvider);
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
                _ChartSectionHeader(viewMode: viewMode),
                const SizedBox(height: AppSpacing.md),
                _ChartCard(viewMode: viewMode),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '情绪分布',
                  style: TextToken.h3.toStyle(color: context.colorToken.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _MoodDistributionCard(),
                const SizedBox(height: AppSpacing.xl),
                const RecentRecordsPreview(),
                const SizedBox(height: AppSpacing.md),
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

class _ChartSectionHeader extends ConsumerWidget {
  final ChartViewMode viewMode;

  const _ChartSectionHeader({required this.viewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorToken = context.colorToken;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          viewMode == ChartViewMode.week ? '近7天情绪趋势' : '近30天情绪趋势',
          style: TextToken.h3.toStyle(color: colorToken.textPrimary),
        ),
        SegmentedButton<ChartViewMode>(
          segments: const [
            ButtonSegment(
              value: ChartViewMode.week,
              label: Text('周'),
            ),
            ButtonSegment(
              value: ChartViewMode.month,
              label: Text('月'),
            ),
          ],
          selected: {viewMode},
          onSelectionChanged: (selection) {
            ref.read(chartViewModeProvider.notifier).state = selection.first;
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorToken.primary.withOpacity(0.2);
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colorToken.primary;
              }
              return colorToken.textSecondary;
            }),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends ConsumerWidget {
  final ChartViewMode viewMode;

  const _ChartCard({required this.viewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (viewMode == ChartViewMode.week) {
      final weekStats = ref.watch(weekStatsProvider);
      return weekStats.when(
        data: (records) => _WeekTrendChart(records: records),
        loading: () => const _LoadingCard(),
        error: (_, __) => const _ErrorCard(message: '加载趋势数据失败'),
      );
    } else {
      final monthStats = ref.watch(monthStatsProvider);
      return monthStats.when(
        data: (records) => _MonthTrendChart(records: records),
        loading: () => const _LoadingCard(),
        error: (_, __) => const _ErrorCard(message: '加载趋势数据失败'),
      );
    }
  }
}

class _WeekTrendChart extends ConsumerStatefulWidget {
  final List<MoodRecord> records;

  const _WeekTrendChart({required this.records});

  @override
  ConsumerState<_WeekTrendChart> createState() => _WeekTrendChartState();
}

class _WeekTrendChartState extends ConsumerState<_WeekTrendChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final barGroups = _buildBarGroups(colorToken, brightness);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 220,
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
                          final intensity = rod.toY;
                          return BarTooltipItem(
                            '$dayLabel\n',
                            TextToken.caption.toStyle(color: colorToken.textPrimary),
                            children: [
                              TextSpan(
                                text: '强度 ${intensity.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: colorToken.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      touchCallback: (event, response) {
                        setState(() {
                          if (response == null || response.spot == null) {
                            _touchedIndex = null;
                          } else {
                            _touchedIndex = response.spot!.touchedBarGroupIndex;
                          }
                        });
                      },
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
      final dayRecords = widget.records.where((r) {
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
      final isTouched = _touchedIndex == (6 - i);

      groups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: avgIntensity,
              color: isTouched ? color : (dayRecords.isEmpty ? color.withOpacity(0.3) : color),
              width: isTouched ? 24 : 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5,
                color: color.withOpacity(0.1),
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

class _MonthTrendChart extends ConsumerStatefulWidget {
  final List<MoodRecord> records;

  const _MonthTrendChart({required this.records});

  @override
  ConsumerState<_MonthTrendChart> createState() => _MonthTrendChartState();
}

class _MonthTrendChartState extends ConsumerState<_MonthTrendChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final spots = _buildSpots(colorToken, brightness);
    final double minX = spots.isEmpty ? 0.0 : spots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
    final double maxX = spots.isEmpty ? 30.0 : spots.map((s) => s.x).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          height: 220,
          child: spots.isEmpty
              ? Center(
                  child: Text(
                    '暂无数据',
                    style: TextToken.body2.toStyle(color: colorToken.textSecondary),
                  ),
                )
              : LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: 0.0,
                    maxY: 5.0,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => colorToken.card,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final dayLabel = _getDayLabel(spot.x.toInt());
                            return LineTooltipItem(
                              '$dayLabel\n',
                              TextToken.caption.toStyle(color: colorToken.textPrimary),
                              children: [
                                TextSpan(
                                  text: '强度 ${spot.y.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: colorToken.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (event, response) {
                        setState(() {
                          if (response == null || response.lineBarSpots == null || response.lineBarSpots!.isEmpty) {
                            _touchedIndex = null;
                          } else {
                            _touchedIndex = response.lineBarSpots!.first.spotIndex;
                          }
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 7,
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
                          interval: 1,
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
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: colorToken.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final isTouched = _touchedIndex == index;
                            return FlDotCirclePainter(
                              radius: isTouched ? 6 : 3,
                              color: colorToken.primary,
                              strokeWidth: 2,
                              strokeColor: colorToken.card,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              colorToken.primary.withOpacity(0.3),
                              colorToken.primary.withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots(ColorToken colorToken, Brightness brightness) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<FlSpot> spots = [];

    for (int i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayRecords = widget.records.where((r) {
        final recordDate = DateTime(
          r.recordedAt.year,
          r.recordedAt.month,
          r.recordedAt.day,
        );
        return recordDate == day;
      }).toList();

      final avgIntensity = dayRecords.isEmpty
          ? null
          : dayRecords.map((r) => r.intensity).reduce((a, b) => a + b) /
              dayRecords.length;

      if (avgIntensity != null) {
        spots.add(FlSpot((29 - i).toDouble(), avgIntensity));
      }
    }

    return spots;
  }

  String _getDayLabel(int index) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = today.subtract(Duration(days: 29 - index));
    return '${day.month}/${day.day}';
  }
}

class _MoodDistributionCard extends ConsumerWidget {
  const _MoodDistributionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRecords = ref.watch(allRecordsProvider);
    final colorToken = context.colorToken;

    return allRecords.when(
      data: (records) {
        if (records.isEmpty) {
          return Card(
            child: Container(
              height: 200,
              alignment: Alignment.center,
              child: Text(
                '暂无数据',
                style: TextToken.body2.toStyle(color: colorToken.textSecondary),
              ),
            ),
          );
        }

        final distribution = _calculateDistribution(records);
        final total = distribution.values.fold(0, (a, b) => a + b);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildSections(distribution, total, colorToken),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _DistributionLegend(distribution: distribution, total: total),
              ],
            ),
          ),
        );
      },
      loading: () => const _LoadingCard(),
      error: (_, __) => const _ErrorCard(message: '加载分布数据失败'),
    );
  }

  Map<MoodType, int> _calculateDistribution(List<MoodRecord> records) {
    final Map<MoodType, int> distribution = {};
    for (final record in records) {
      distribution[record.moodType] = (distribution[record.moodType] ?? 0) + 1;
    }
    return distribution;
  }

  List<PieChartSectionData> _buildSections(
    Map<MoodType, int> distribution,
    int total,
    ColorToken colorToken,
  ) {
    final brightness = Brightness.light;
    final List<PieChartSectionData> sections = [];

    for (final entry in distribution.entries) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
      final color = _getMoodColor(entry.key, brightness);

      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          color: color,
          radius: 50,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return sections;
  }

  Color _getMoodColor(MoodType type, Brightness brightness) {
    switch (type) {
      case MoodType.great:
        return brightness == Brightness.dark
            ? const Color(0xFF81C784)
            : const Color(0xFF4CAF50);
      case MoodType.good:
        return brightness == Brightness.dark
            ? const Color(0xFFAED581)
            : const Color(0xFF8BC34A);
      case MoodType.neutral:
        return brightness == Brightness.dark
            ? const Color(0xFFFFD54F)
            : const Color(0xFFFFC107);
      case MoodType.bad:
        return brightness == Brightness.dark
            ? const Color(0xFFFFB74D)
            : const Color(0xFFFF9800);
      case MoodType.terrible:
        return brightness == Brightness.dark
            ? const Color(0xFFE57373)
            : const Color(0xFFF44336);
    }
  }
}

class _DistributionLegend extends StatelessWidget {
  final Map<MoodType, int> distribution;
  final int total;

  const _DistributionLegend({
    required this.distribution,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: distribution.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getMoodColor(entry.key, brightness),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key.emoji} ${entry.key.label} (${entry.value})',
              style: TextToken.caption.toStyle(color: colorToken.textSecondary),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getMoodColor(MoodType type, Brightness brightness) {
    switch (type) {
      case MoodType.great:
        return brightness == Brightness.dark
            ? const Color(0xFF81C784)
            : const Color(0xFF4CAF50);
      case MoodType.good:
        return brightness == Brightness.dark
            ? const Color(0xFFAED581)
            : const Color(0xFF8BC34A);
      case MoodType.neutral:
        return brightness == Brightness.dark
            ? const Color(0xFFFFD54F)
            : const Color(0xFFFFC107);
      case MoodType.bad:
        return brightness == Brightness.dark
            ? const Color(0xFFFFB74D)
            : const Color(0xFFFF9800);
      case MoodType.terrible:
        return brightness == Brightness.dark
            ? const Color(0xFFE57373)
            : const Color(0xFFF44336);
    }
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