import 'package:flutter/material.dart';
import 'package:mood_whisper/core/database/database_helper.dart';
import 'package:mood_whisper/core/logger/app_logger.dart';
import 'package:mood_whisper/data/models/onboarding_state.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper;

  SettingsRepository(this._dbHelper);

  // Settings keys
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyOnboardingStep = 'onboarding_step';
  static const String _keyOnboardingCompletedAt = 'onboarding_completed_at';

  /// Gets the current theme mode
  Future<ThemeMode> getThemeMode() async {
    AppLogger.logDbOperation('GET', 'app_settings', id: _keyThemeMode);
    final db = await _dbHelper.database;
    final maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyThemeMode],
    );

    if (maps.isEmpty) {
      return ThemeMode.system;
    }

    final value = maps.first['value'] as String?;
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Sets the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    AppLogger.logDbOperation('SET', 'app_settings', id: _keyThemeMode);
    final db = await _dbHelper.database;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await db.insert(
      'app_settings',
      {
        'key': _keyThemeMode,
        'value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Checks if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    AppLogger.logDbOperation('GET', 'app_settings', id: _keyOnboardingCompleted);
    final db = await _dbHelper.database;
    final maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingCompleted],
    );

    if (maps.isEmpty) {
      return false;
    }

    return maps.first['value'] == 'true';
  }

  /// Gets the current onboarding state
  Future<OnboardingState> getOnboardingState() async {
    AppLogger.logDbOperation('GET', 'app_settings', id: 'onboarding_state');
    final db = await _dbHelper.database;

    final completedMaps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingCompleted],
    );

    final stepMaps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingStep],
    );

    final completedAtMaps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingCompletedAt],
    );

    final isCompleted =
        completedMaps.isNotEmpty && completedMaps.first['value'] == 'true';
    final currentStep =
        stepMaps.isNotEmpty ? int.tryParse(stepMaps.first['value'] as String? ?? '0') ?? 0 : 0;
    final completedAt = completedAtMaps.isNotEmpty && completedAtMaps.first['value'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            int.parse(completedAtMaps.first['value'] as String))
        : null;

    return OnboardingState(
      isCompleted: isCompleted,
      currentStep: currentStep,
      completedAt: completedAt,
    );
  }

  /// Marks onboarding as complete
  Future<void> markOnboardingComplete() async {
    AppLogger.logDbOperation('SET', 'app_settings', id: _keyOnboardingCompleted);
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'app_settings',
      {
        'key': _keyOnboardingCompleted,
        'value': 'true',
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      'app_settings',
      {
        'key': _keyOnboardingCompletedAt,
        'value': now.toString(),
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      'app_settings',
      {
        'key': _keyOnboardingStep,
        'value': '3',
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates the current onboarding step
  Future<void> setOnboardingStep(int step) async {
    AppLogger.logDbOperation('SET', 'app_settings', id: _keyOnboardingStep);
    final db = await _dbHelper.database;

    await db.insert(
      'app_settings',
      {
        'key': _keyOnboardingStep,
        'value': step.toString(),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Resets onboarding state (for testing or re-onboarding)
  Future<void> resetOnboarding() async {
    AppLogger.logDbOperation('RESET', 'app_settings', id: 'onboarding');
    final db = await _dbHelper.database;

    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingCompleted],
    );
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingStep],
    );
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_keyOnboardingCompletedAt],
    );
  }
}
