class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'MoodWhisper';
  static const String appVersion = '1.0.0';

  // Navigation
  static const String navHome = '仪表盘';
  static const String navList = '历史记录';
  static const String navStatistics = '统计';
  static const String navProfile = '我的';
  static const String navRecord = '记录情绪';

  // Home
  static const String todayOverview = '今日情绪概览';
  static const String recordCount = '记录数';
  static const String avgIntensity = '平均强度';
  static const String dominantMood = '主导情绪';
  static const String noRecordsToday = '今天还没有记录，点击下方按钮开始记录吧~';
  static const String quickRecord = '快速记录';
  static const String moodDistribution = '情绪分布';
  static const String weekTrend = '近7天情绪趋势';
  static const String monthTrend = '近30天情绪趋势';
  static const String chartWeekLabel = '周';
  static const String chartMonthLabel = '月';
  static const String noData = '暂无数据';

  // Record
  static const String howDoYouFeel = '今天感觉怎么样？';
  static const String moodIntensity = '情绪强度';
  static const String intensityMild = '轻微';
  static const String intensityStrong = '强烈';
  static const String noteOptional = '备注（可选）';
  static const String noteHint = '写下今天的心情...';
  static const String saveRecord = '保存记录';
  static const String recordSaved = '记录已保存';

  // List
  static const String historyRecords = '历史记录';
  static const String noRecords = '暂无记录';
  static const String startRecording = '开始记录你的情绪变化吧';
  static const String loadFailed = '加载失败';
  static const String retry = '重试';
  static const String today = '今天';
  static const String yesterday = '昨天';
  static const String intensity = '强度';

  // Profile
  static const String totalRecords = '总记录数';
  static const String longestStreak = '最长连续';
  static const String mostFrequentMood = '最常情绪';
  static const String themeSwitch = '主题切换';
  static const String dataExport = '数据导出';
  static const String aboutApp = '关于应用';
  static const String clearAllData = '清除所有数据';
  static const String clearAllDataConfirm =
      '确定要清除所有记录数据吗？\n此操作不可恢复！';
  static const String cancel = '取消';
  static const String confirmClear = '确定清除';
  static const String allDataCleared = '所有数据已清除';
  static const String dataClearFailed = '清除数据失败';

  // Theme
  static const String followSystem = '跟随系统';
  static const String lightMode = '浅色模式';
  static const String darkMode = '深色模式';
  static const String lightShort = '浅色';
  static const String darkShort = '深色';

  // Export
  static const String exportTitle = '数据导出';
  static const String selectExportFormat = '选择导出格式';
  static const String csvFormat = 'CSV 格式';
  static const String csvFormatDesc = '适合在 Excel 中打开';
  static const String jsonFormat = 'JSON 格式';
  static const String jsonFormatDesc = '适合程序解析';
  static const String exportSuccess = '导出成功';
  static const String exportFailed = '导出失败';

  // About
  static const String aboutTitle = '关于 MoodWhisper';
  static const String aboutDescription =
      'MoodWhisper 是一款简洁的情绪记录应用，\n帮助你追踪情绪变化，\n更好地了解自己的内心世界。';
  static const String ok = '确定';

  // Statistics
  static const String statistics = '统计';

  // Onboarding
  static const String onboardingPlaceholder = '占位';

  // Days
  static const String days = '天';

  // Weekdays (周一 to 周日)
  static const List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // Chart
  static const String intensityLabel = '强度';

  // Errors
  static const String loadTodayDataFailed = '加载今日数据失败';
  static const String loadTrendDataFailed = '加载趋势数据失败';
  static const String loadDistributionFailed = '加载分布数据失败';
}
