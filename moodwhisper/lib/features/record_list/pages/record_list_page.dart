import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/constants/strings.dart';

/// 记录列表页 - 占位
/// TODO: P3 阶段实现完整功能
class RecordListPage extends ConsumerWidget {
  const RecordListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.list_page_title),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📋', style: TextStyle(fontSize: 48)),
            SizedBox(height: AppSpacing.lg),
            Text(AppStrings.list_empty_title, style: AppTypography.h2),
            SizedBox(height: AppSpacing.sm),
            Text(AppStrings.list_empty_desc, style: AppTypography.body),
            SizedBox(height: AppSpacing.xl),
            Text('P3 阶段实现', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
