import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/local/database_helper.dart';

/// SettingsRepository - 应用设置仓库
/// 基于架构设计文档 v1.0 §6.1
class SettingsRepository {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyListSwipeGuided = 'list_swipe_guided';
  static const String _keyReminderEnabled = 'reminder_enabled';
  static const String _keyReminderTime = 'reminder_time';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // =========================================================================
  // 主题模式
  // =========================================================================

  /// 获取当前主题模式
  Future<ThemeMode> getThemeMode() async {
    final prefs = await _preferences;
    final value = prefs.getString(_keyThemeMode) ?? 'system';
    return _themeModeFromString(value);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _preferences;
    await prefs.setString(_keyThemeMode, _themeModeToString(mode));
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // =========================================================================
  // 首次引导
  // =========================================================================

  /// 是否完成首次引导
  Future<bool> isOnboardingCompleted() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// 标记引导完成
  Future<void> markOnboardingCompleted() async {
    final prefs = await _preferences;
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  // =========================================================================
  // 滑动引导
  // =========================================================================

  /// 是否完成列表滑动引导
  Future<bool> isSwipeGuided() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyListSwipeGuided) ?? false;
  }

  /// 标记滑动引导完成
  Future<void> markSwipeGuided() async {
    final prefs = await _preferences;
    await prefs.setBool(_keyListSwipeGuided, true);
  }

  // =========================================================================
  // 每日提醒
  // =========================================================================

  /// 是否启用每日提醒
  Future<bool> isReminderEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyReminderEnabled) ?? false;
  }

  /// 设置每日提醒开关
  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyReminderEnabled, enabled);
  }

  /// 获取提醒时间（小时）
  Future<int> getReminderHour() async {
    final prefs = await _preferences;
    return prefs.getInt(_keyReminderTime) ?? 21; // 默认 21:00
  }

  /// 设置提醒时间
  Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await _preferences;
    await prefs.setInt(_keyReminderTime, hour);
    // 分钟暂时存为另一个key
    await prefs.setInt('${_keyReminderTime}_minute', minute);
  }

  /// 获取提醒分钟
  Future<int> getReminderMinute() async {
    final prefs = await _preferences;
    return prefs.getInt('${_keyReminderTime}_minute') ?? 0;
  }

  // =========================================================================
  // 数据清空
  // =========================================================================

  /// 清空所有数据（同时重置引导状态）
  Future<void> clearAllData() async {
    // 清空数据库
    await DatabaseHelper.instance.clearAll();
    
    // 重置 SharedPreferences 中的引导状态
    final prefs = await _preferences;
    await prefs.setBool(_keyOnboardingCompleted, false);
    await prefs.setBool(_keyListSwipeGuided, false);
  }
}
