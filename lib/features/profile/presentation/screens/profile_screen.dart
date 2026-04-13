import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/core/constants/constants.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/services/data_export_service.dart';
import 'package:mood_whisper/core/theme/fonts.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalRecords = ref.watch(totalRecordsCountProvider);
    final longestStreak = ref.watch(longestStreakProvider);
    final mostFrequentMood = ref.watch(mostFrequentMoodProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colorToken = context.colorToken;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的',
          style: TextToken.h2.toStyle(color: colorToken.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Avatar and nickname section
              _AvatarSection(),
              const SizedBox(height: AppSpacing.lg),
              // Stats cards
              _StatsSection(
                totalRecords: totalRecords,
                longestStreak: longestStreak,
                mostFrequentMood: mostFrequentMood,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Settings list
              _SettingsSection(
                themeMode: themeMode,
                onThemeChanged: (mode) {
                  ref.read(themeModeProvider.notifier).state = mode;
                },
                onExportData: () => _showExportDialog(context, ref),
                onAbout: () => _showAboutDialog(context),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Exit/Clear data button
              _ExitButton(
                onClearData: () => _showClearDataDialog(context, ref),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Version info
              Text(
                '版本 1.0.0',
                style: TextToken.caption.toStyle(color: colorToken.textDisabled),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final colorToken = context.colorToken;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorToken.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => _ExportBottomSheet(
        colorToken: colorToken,
        onExport: (format) => _handleExport(context, ref, format),
      ),
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref, ExportFormat format) async {
    Navigator.of(context).pop();

    final exportState = ref.read(exportNotifierProvider.notifier);
    await exportState.exportData(format);

    final state = ref.read(exportNotifierProvider);
    if (context.mounted) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.error!,
              style: TextToken.body2.toStyle(color: Colors.white),
            ),
            backgroundColor: context.colorToken.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      } else if (state.exportedFilePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '导出成功: ${state.exportedFilePath}',
              style: TextToken.body2.toStyle(color: Colors.white),
            ),
            backgroundColor: context.colorToken.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    ref.read(exportNotifierProvider.notifier).reset();
  }

  void _showAboutDialog(BuildContext context) {
    final colorToken = context.colorToken;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '关于 MoodWhisper',
          style: TextToken.h3.toStyle(color: colorToken.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MoodWhisper 是一款简洁的情绪记录应用，\n帮助你追踪情绪变化，\n更好地了解自己的内心世界。',
              style: TextToken.body1.toStyle(color: colorToken.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '版本 1.0.0',
              style: TextToken.body2.toStyle(color: colorToken.textDisabled),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '确定',
              style: TextToken.body1.toStyle(color: colorToken.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final colorToken = context.colorToken;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '清除所有数据',
          style: TextToken.h3.toStyle(color: colorToken.textPrimary),
        ),
        content: Text(
          '确定要清除所有记录数据吗？\n此操作不可恢复！',
          style: TextToken.body1.toStyle(color: colorToken.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: TextToken.body1.toStyle(color: colorToken.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(context, ref);
            },
            child: Text(
              '确定清除',
              style: TextToken.body1.toStyle(color: colorToken.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(moodRecordRepositoryProvider);
      final records = await repository.findAll();
      for (final record in records) {
        await repository.delete(record.uuid);
      }
      ref.invalidate(totalRecordsCountProvider);
      ref.invalidate(longestStreakProvider);
      ref.invalidate(mostFrequentMoodProvider);
      ref.invalidate(allRecordsProvider);
      ref.invalidate(recentRecordsProvider);
      ref.invalidate(todayRecordsProvider);
      ref.invalidate(weekStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '所有数据已清除',
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '清除数据失败：$e',
              style: TextToken.body2.toStyle(color: Colors.white),
            ),
            backgroundColor: context.colorToken.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    }
  }
}

class _AvatarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colorToken.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 48,
            color: colorToken.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '用户',
          style: TextToken.h3.toStyle(color: colorToken.textPrimary),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  final AsyncValue<int> totalRecords;
  final AsyncValue<int> longestStreak;
  final AsyncValue<MoodType?> mostFrequentMood;

  const _StatsSection({
    required this.totalRecords,
    required this.longestStreak,
    required this.mostFrequentMood,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '总记录数',
            valueBuilder: (colorToken) => totalRecords.when(
              data: (count) => count.toString(),
              loading: () => '-',
              error: (_, __) => '-',
            ),
            icon: Icons.edit_note,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: '最长连续',
            valueBuilder: (colorToken) => longestStreak.when(
              data: (days) => '$days 天',
              loading: () => '-',
              error: (_, __) => '-',
            ),
            icon: Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: '最常情绪',
            valueBuilder: (colorToken) => mostFrequentMood.when(
              data: (mood) => mood?.emoji ?? '-',
              loading: () => '-',
              error: (_, __) => '-',
            ),
            icon: Icons.emoji_emotions,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String Function(ColorToken colorToken) valueBuilder;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.valueBuilder,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: colorToken.primary, size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              valueBuilder(colorToken),
              style: TextToken.h3.toStyle(color: colorToken.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextToken.caption.toStyle(color: colorToken.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onExportData;
  final VoidCallback onAbout;

  const _SettingsSection({
    required this.themeMode,
    required this.onThemeChanged,
    required this.onExportData,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return Card(
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.palette_outlined,
            title: '主题切换',
            trailing: _ThemeToggle(
              themeMode: themeMode,
              onChanged: onThemeChanged,
            ),
          ),
          Divider(height: 1, color: colorToken.divider),
          _SettingsItem(
            icon: Icons.download_outlined,
            title: '数据导出',
            onTap: onExportData,
          ),
          Divider(height: 1, color: colorToken.divider),
          _SettingsItem(
            icon: Icons.info_outline,
            title: '关于应用',
            onTap: onAbout,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return ListTile(
      leading: Icon(icon, color: colorToken.primary),
      title: Text(
        title,
        style: TextToken.body1.toStyle(color: colorToken.textPrimary),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: colorToken.textDisabled,
          ),
      onTap: onTap,
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeToggle({
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return PopupMenuButton<ThemeMode>(
      initialValue: themeMode,
      onSelected: onChanged,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getThemeLabel(themeMode),
            style: TextToken.body2.toStyle(color: colorToken.textSecondary),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: colorToken.textSecondary,
          ),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Text(
            '跟随系统',
            style: TextToken.body1.toStyle(color: colorToken.textPrimary),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Text(
            '浅色模式',
            style: TextToken.body1.toStyle(color: colorToken.textPrimary),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Text(
            '深色模式',
            style: TextToken.body1.toStyle(color: colorToken.textPrimary),
          ),
        ),
      ],
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
    }
  }
}

class _ExitButton extends StatelessWidget {
  final VoidCallback onClearData;

  const _ExitButton({required this.onClearData});

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onClearData,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorToken.error,
          side: BorderSide(color: colorToken.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          '清除所有数据',
          style: TextToken.body1.toStyle(color: colorToken.error),
        ),
      ),
    );
  }
}

class _ExportBottomSheet extends StatelessWidget {
  final ColorToken colorToken;
  final Function(ExportFormat) onExport;

  const _ExportBottomSheet({
    required this.colorToken,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据导出',
              style: TextToken.h3.toStyle(color: colorToken.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '选择导出格式',
              style: TextToken.body2.toStyle(color: colorToken.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ExportOptionTile(
              icon: Icons.table_chart_outlined,
              title: 'CSV 格式',
              subtitle: '适合在 Excel 中打开',
              onTap: () => onExport(ExportFormat.csv),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ExportOptionTile(
              icon: Icons.data_object,
              title: 'JSON 格式',
              subtitle: '适合程序解析',
              onTap: () => onExport(ExportFormat.json),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorToken = context.colorToken;

    return ListTile(
      leading: Icon(icon, color: colorToken.primary),
      title: Text(
        title,
        style: TextToken.body1.toStyle(color: colorToken.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextToken.caption.toStyle(color: colorToken.textSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorToken.textDisabled,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      tileColor: colorToken.surface,
    );
  }
}