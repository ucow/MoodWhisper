import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/constants/strings.dart';

/// 设置页 - 占位
/// TODO: P5 阶段实现完整功能
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings_page_title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // 外观
          _buildSectionHeader(context, AppStrings.settings_group_appearance),
          _buildListTile(
            context,
            icon: '🌙',
            title: AppStrings.settings_dark_mode,
            trailing: const SizedBox(
              width: 50,
              child: Center(child: Text('P5')),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 数据
          _buildSectionHeader(context, AppStrings.settings_group_data),
          _buildListTile(
            context,
            icon: '📤',
            title: AppStrings.settings_export,
            trailing: const SizedBox(
              width: 50,
              child: Center(child: Text('P5')),
            ),
          ),
          _buildListTile(
            context,
            icon: '🗑️',
            title: AppStrings.settings_clear,
            trailing: const SizedBox(
              width: 50,
              child: Center(child: Text('P5')),
            ),
            textColor: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 帮助
          _buildSectionHeader(context, AppStrings.settings_group_help),
          _buildListTile(
            context,
            icon: '📖',
            title: AppStrings.settings_guide,
            trailing: const SizedBox(
              width: 50,
              child: Center(child: Text('P6')),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 关于
          _buildSectionHeader(context, AppStrings.settings_group_about),
          _buildListTile(
            context,
            icon: 'ℹ️',
            title: '${AppStrings.settings_version}：v1.0.0',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.small.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String icon,
    required String title,
    Widget? trailing,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(
          title,
          style: AppTypography.body.copyWith(color: textColor),
        ),
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
