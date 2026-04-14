import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/theme.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:mood_whisper/data/models/onboarding_state.dart';
import 'package:mood_whisper/data/models/stat_summary.dart';
import 'package:mood_whisper/data/models/time_series_point.dart';
import 'package:mood_whisper/data/repository/mood_record_repository.dart';
import 'package:mood_whisper/data/repository/settings_repository.dart';
import 'package:mood_whisper/features/record/presentation/screens/record_screen.dart';
import 'package:mood_whisper/features/record/presentation/widgets/emotion_button.dart';
import 'package:mood_whisper/shared/providers/mood_providers.dart';

/// A fake repository for testing that doesn't need database
class FakeMoodRecordRepository implements MoodRecordRepository {
  final List<MoodRecord> _records = [];

  @override
  Future<MoodRecord> save(MoodRecord record) async {
    _records.add(record);
    return record;
  }

  @override
  Future<List<MoodRecord>> findAll({int? limit, int? offset}) async {
    var result = List<MoodRecord>.from(_records);
    result.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    if (offset != null) {
      result = result.skip(offset).toList();
    }
    if (limit != null) {
      result = result.take(limit).toList();
    }
    return result;
  }

  @override
  Future<List<MoodRecord>> findByDateRange(DateTime start, DateTime end) async {
    return _records
        .where((r) =>
            r.recordedAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            r.recordedAt.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  @override
  Future<MoodRecord?> findByUuid(String uuid) async {
    try {
      return _records.firstWhere((r) => r.uuid == uuid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String uuid) async {
    _records.removeWhere((r) => r.uuid == uuid);
  }

  @override
  Future<void> deleteAll() async {
    _records.clear();
  }

  @override
  Future<List<MoodRecord>> findPaged({required int page, required int pageSize}) async {
    return findAll(offset: page * pageSize, limit: pageSize);
  }

  @override
  Future<StatSummary> getSummary({DateTime? since}) async {
    return StatSummary(
      totalRecords: _records.length,
      averageIntensity: _records.isEmpty ? 0.0 : _records.map((r) => r.intensity).reduce((a, b) => a + b) / _records.length,
      dominantMood: null,
      currentStreak: 0,
      longestStreak: 0,
      moodDistribution: {},
    );
  }

  @override
  Future<Map<MoodType, int>> getDistribution({DateTime? since}) async {
    final Map<MoodType, int> distribution = {};
    for (final record in _records) {
      distribution[record.moodType] = (distribution[record.moodType] ?? 0) + 1;
    }
    return distribution;
  }

  @override
  Future<List<TimeSeriesPoint>> getIntensityTrend({required DateTime start, required DateTime end}) async {
    return [];
  }

  @override
  Future<int> getTotalCount() async {
    return _records.length;
  }
}

/// A fake settings repository for testing
class FakeSettingsRepository implements SettingsRepository {
  bool _particleDegraded = false;

  @override
  Future<bool> isParticleAnimationDegraded() async {
    return _particleDegraded;
  }

  @override
  Future<void> setParticleAnimationDegraded(bool degraded) async {
    _particleDegraded = degraded;
  }

  @override
  Future<ThemeMode> getThemeMode() async => ThemeMode.system;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {}

  @override
  Future<bool> isOnboardingComplete() async => false;

  @override
  Future<OnboardingState> getOnboardingState() async {
    return OnboardingState(isCompleted: false, currentStep: 0);
  }

  @override
  Future<void> markOnboardingComplete() async {}

  @override
  Future<void> setOnboardingStep(int step) async {}

  @override
  Future<void> resetOnboarding() async {}
}

void main() {
  late FakeMoodRecordRepository fakeRepository;
  late FakeSettingsRepository fakeSettingsRepository;

  setUp(() {
    fakeRepository = FakeMoodRecordRepository();
    fakeSettingsRepository = FakeSettingsRepository();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        moodRecordRepositoryProvider.overrideWithValue(fakeRepository),
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        home: const RecordScreen(),
      ),
    );
  }

  group('RecordScreen Widget Tests', () {
    testWidgets('should display all mood buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that all 5 mood emojis are displayed
      expect(find.text('😆'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
      expect(find.text('😔'), findsOneWidget);
      expect(find.text('😢'), findsOneWidget);
    });

    testWidgets('should display intensity slider', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Default intensity is 3
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('should display note input field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('写下今天的心情...'), findsOneWidget);
    });

    testWidgets('should display save button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, '保存记录');
      expect(saveButton, findsOneWidget);
    });

    testWidgets('should display time selector in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show "点击选择时间" or similar when no time is selected
      expect(find.text('点击选择时间'), findsOneWidget);
      expect(find.byIcon(Icons.edit_calendar), findsOneWidget);
    });

    testWidgets('should display intensity labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('轻微'), findsOneWidget);
      expect(find.text('强烈'), findsOneWidget);
    });

    testWidgets('should display section headers', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('今天感觉怎么样？'), findsOneWidget);
      expect(find.text('情绪强度'), findsOneWidget);
      expect(find.text('备注（可选）'), findsOneWidget);
    });

    testWidgets('should update note when typing in text field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test note');
      await tester.pumpAndSettle();

      expect(find.text('Test note'), findsOneWidget);
    });

    testWidgets('should show mood icons in loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Before selecting a mood, we see loading icons (emoji text without EmotionButton wrapper)
      // After pumpAndSettle, the animation completes but we haven't selected a mood yet
      await tester.pumpAndSettle();

      // When no mood is selected, the loading icons should have transitioned to actual emotion buttons
      // But the initial state shows emoji texts as loading animation
      expect(find.text('😆'), findsOneWidget);
    });

    testWidgets('should display loading animation initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Loading animation should be visible initially
      expect(find.text('👋'), findsNothing); // Empty state not shown
    });

    testWidgets('record form state should be properly initialized', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify record screen is rendered
      expect(find.byType(RecordScreen), findsOneWidget);
      expect(find.text('今天感觉怎么样？'), findsOneWidget);
    });
  });
}
