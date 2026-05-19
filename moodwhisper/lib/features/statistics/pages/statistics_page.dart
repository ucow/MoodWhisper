import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/constants/strings.dart';

/// 统计页 - 占位
/// TODO: P4 阶段实现完整功能
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.stats_page_title),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📊', style: TextStyle(fontSize: 48)),
            SizedBox(height: AppSpacing.lg),
            Text('情绪趋势', style: AppTypography.h2),
            SizedBox(height: AppSpacing.xl),
            Text('P4 阶段实现', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
