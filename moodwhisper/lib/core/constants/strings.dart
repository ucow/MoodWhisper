/// MoodWhisper 文案集中管理
/// MVP 阶段仅中文，但架构上为多语言扩展预留
/// key 命名规范：页面_组件_用途

class AppStrings {
  // -------------------------------------------------------------------------
  // 全局
  // -------------------------------------------------------------------------
  static const String appName = 'MoodWhisper';

  // -------------------------------------------------------------------------
  // 首次引导 (Onboarding)
  // -------------------------------------------------------------------------
  static const String onboarding_skip = '跳过';
  static const String onboarding_next = '下一步';
  static const String onboarding_start = '开始使用';

  // Page 1
  static const String onboarding_page1_title = '记录情绪';
  static const String onboarding_page1_desc = '3秒记录你的每一刻情绪';

  // Page 2
  static const String onboarding_page2_title = '查看趋势';
  static const String onboarding_page2_desc = '发现情绪变化模式';

  // Page 3
  static const String onboarding_page3_title = '隐私承诺';
  static const String onboarding_page3_desc = '你的数据只属于你';

  // -------------------------------------------------------------------------
  // 首页 - 情绪记录 (Record)
  // -------------------------------------------------------------------------
  static const String record_page_title = '记录情绪';
  static const String record_prompt = '你现在感觉怎么样？';
  static const String record_intensity_label = '强度';
  static const String record_intensity_weak = '弱';
  static const String record_intensity_strong = '强';
  static const String record_note_hint = '添加备注（可选）';
  static const String record_save = '保存记录';
  static const String record_recent = '最近';

  // 空状态
  static const String record_empty = '选择一个表情开始记录吧 👋';

  // -------------------------------------------------------------------------
  // 记录列表 (Record List)
  // -------------------------------------------------------------------------
  static const String list_page_title = '情绪记录';
  static const String list_swipe_hint = '左滑可删除，右滑可编辑';
  static const String list_edit = '编辑记录';
  static const String list_delete = '删除记录';
  static const String list_delete_confirm = '确定删除这条记录？';
  static const String list_delete_yes = '删除';
  static const String list_delete_no = '取消';
  static const String list_updated = '已更新 ✅';

  // 空状态
  static const String list_empty_title = '还没有记录哦～';
  static const String list_empty_desc = '去记录第一个情绪吧 😊';
  static const String list_empty_action = '去记录';

  // -------------------------------------------------------------------------
  // 统计趋势 (Statistics)
  // -------------------------------------------------------------------------
  static const String stats_page_title = '情绪趋势';
  static const String stats_tab_7days = '7天';
  static const String stats_tab_30days = '30天';
  static const String stats_tab_all = '全部';

  // 统计摘要
  static const String stats_avg_intensity = '平均强度';
  static const String stats_most_frequent = '最频繁';
  static const String stats_total_records = '记录总数';
  static const String stats_total_days = '记录天数';
  static const String stats_daily_avg = '平均每天';

  // 空状态
  static const String stats_locked_title = '记录更多天后解锁趋势分析';
  static const String stats_locked_progress = '已记录';

  // -------------------------------------------------------------------------
  // 设置 (Settings)
  // -------------------------------------------------------------------------
  static const String settings_page_title = '我的';

  // 分组标题
  static const String settings_group_appearance = '外观';
  static const String settings_group_data = '数据';
  static const String settings_group_help = '帮助';
  static const String settings_group_about = '关于';

  // 外观
  static const String settings_dark_mode = '深色模式';
  static const String settings_follow_system = '跟随系统';

  // 数据
  static const String settings_export = '导出数据 (CSV)';
  static const String settings_clear = '清空所有数据';

  // 帮助
  static const String settings_guide = '使用引导';

  // 关于
  static const String settings_version = '版本';
  static const String settings_license = '开源许可';
  static const String settings_privacy = '隐私政策';

  // 清空数据确认
  static const String settings_clear_confirm_title = '确认清空所有数据？';
  static const String settings_clear_confirm_desc = '此操作不可撤销，所有情绪记录将被永久删除。';
  static const String settings_clear_input_hint = '请输入"清空"以确认：';
  static const String settings_clear_confirm = '确认清空';

  // Toast
  static const String toast_export_empty = '暂无记录可导出';
  static const String toast_export_failed = '导出失败，请重试';
  static const String toast_save_failed = '保存失败，请重试';

  // -------------------------------------------------------------------------
  // 时间
  // -------------------------------------------------------------------------
  static String today() {
    final now = DateTime.now();
    return '${now.month}月${now.day}日';
  }
}
