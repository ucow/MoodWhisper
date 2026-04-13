import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/database/database_helper.dart';
import 'package:mood_whisper/data/dao/mood_record_dao.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:mood_whisper/data/repository/mood_record_repository.dart';
import 'package:uuid/uuid.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final moodRecordDaoProvider = Provider<MoodRecordDao>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return MoodRecordDao(dbHelper);
});

final moodRecordRepositoryProvider = Provider<MoodRecordRepository>((ref) {
  final dao = ref.watch(moodRecordDaoProvider);
  return MoodRecordRepository(dao);
});

class RecordFormState {
  final MoodType? moodType;
  final int intensity;
  final String note;
  final bool isSaving;
  final String? error;

  const RecordFormState({
    this.moodType,
    this.intensity = 3,
    this.note = '',
    this.isSaving = false,
    this.error,
  });

  RecordFormState copyWith({
    MoodType? moodType,
    int? intensity,
    String? note,
    bool? isSaving,
    String? error,
  }) {
    return RecordFormState(
      moodType: moodType ?? this.moodType,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class RecordFormNotifier extends StateNotifier<RecordFormState> {
  final MoodRecordRepository _repository;
  final Uuid _uuid = const Uuid();

  RecordFormNotifier(this._repository) : super(const RecordFormState());

  void selectMood(MoodType type) {
    state = state.copyWith(moodType: type);
  }

  void setIntensity(int intensity) {
    state = state.copyWith(intensity: intensity.clamp(1, 5));
  }

  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  Future<bool> save() async {
    if (state.moodType == null) {
      state = state.copyWith(error: '请选择情绪');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final record = MoodRecord(
        uuid: _uuid.v4(),
        moodType: state.moodType!,
        intensity: state.intensity,
        note: state.note.isEmpty ? null : state.note,
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _repository.save(record);
      state = const RecordFormState();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const RecordFormState();
  }
}

final recordFormProvider =
    StateNotifierProvider<RecordFormNotifier, RecordFormState>((ref) {
  final repository = ref.watch(moodRecordRepositoryProvider);
  return RecordFormNotifier(repository);
});

final recentRecordsProvider = FutureProvider<List<MoodRecord>>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  return repository.findAll(limit: 10);
});

final todayRecordsProvider = FutureProvider<List<MoodRecord>>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return repository.findByDateRange(startOfDay, endOfDay);
});

final weekStatsProvider = FutureProvider<List<MoodRecord>>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final endOfToday = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  return repository.findByDateRange(startOfWeek, endOfToday);
});

final allRecordsProvider = FutureProvider<List<MoodRecord>>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  return repository.findAll();
});

// Profile statistics providers

final totalRecordsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  final records = await repository.findAll();
  return records.length;
});

final longestStreakProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  final records = await repository.findAll();
  if (records.isEmpty) return 0;
  return _calculateLongestStreak(records);
});

final mostFrequentMoodProvider = FutureProvider<MoodType?>((ref) async {
  final repository = ref.watch(moodRecordRepositoryProvider);
  final records = await repository.findAll();
  if (records.isEmpty) return null;
  final moodCounts = <MoodType, int>{};
  for (final record in records) {
    moodCounts[record.moodType] = (moodCounts[record.moodType] ?? 0) + 1;
  }
  return moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
});

int _calculateLongestStreak(List<MoodRecord> records) {
  if (records.isEmpty) return 0;

  final sortedDates = records.map((r) => DateTime(
    r.recordedAt.year,
    r.recordedAt.month,
    r.recordedAt.day,
  )).toSet().toList()..sort();

  int longestStreak = 1;
  int currentStreak = 1;

  for (int i = 1; i < sortedDates.length; i++) {
    final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
    if (diff == 1) {
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else {
      currentStreak = 1;
    }
  }

  return longestStreak;
}

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
