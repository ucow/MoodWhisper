import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/constants/strings.dart';

/// 记录页 - 占位
/// TODO: P2 阶段实现完整功能
class RecordPage extends ConsumerWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.record_page_title),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('😊 😌 😢 😠 😰', style: TextStyle(fontSize: 48)),
            SizedBox(height: AppSpacing.lg),
            Text(
              AppStrings.record_prompt,
              style: AppTypography.h2,
            ),
            SizedBox(height: AppSpacing.xl),
            Text('P2 阶段实现', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }
}
