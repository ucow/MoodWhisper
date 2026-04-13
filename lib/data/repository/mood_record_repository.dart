import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/logger/app_logger.dart';
import 'package:mood_whisper/data/dao/mood_record_dao.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:mood_whisper/data/models/stat_summary.dart';
import 'package:mood_whisper/data/models/time_series_point.dart';

class MoodRecordRepository {
  final MoodRecordDao _dao;

  MoodRecordRepository(this._dao);

  /// Valid intensity range (1-5)
  static const int minIntensity = 1;
  static const int maxIntensity = 5;

  /// Maximum days allowed for backdating a record
  static const int maxBacktrackDays = 7;

  /// Validates intensity is within allowed range
  bool _isValidIntensity(int intensity) {
    return intensity >= minIntensity && intensity <= maxIntensity;
  }

  /// Validates that a record date is not too far in the past
  bool _isValidRecordDate(DateTime recordedAt) {
    final now = DateTime.now();
    final earliestAllowed = now.subtract(const Duration(days: maxBacktrackDays));
    return recordedAt.isAfter(earliestAllowed) || recordedAt.isAtSameMomentAs(earliestAllowed);
  }

  /// Saves a mood record with validation
  ///
  /// Throws [ValidationException] if intensity is out of range or date is too far in the past
  Future<MoodRecord> save(MoodRecord record) async {
    // Validate intensity
    if (!_isValidIntensity(record.intensity)) {
      throw ValidationException(
        'Intensity must be between $minIntensity and $maxIntensity, got ${record.intensity}',
      );
    }

    // Validate record date
    if (!_isValidRecordDate(record.recordedAt)) {
      throw ValidationException(
        'Cannot record mood more than $maxBacktrackDays days in the past',
      );
    }

    final existing = await _dao.queryByUuid(record.uuid);
    if (existing != null) {
      await _dao.update(record);
      AppLogger.info('[Repository] Updated mood record: ${record.uuid}');
    } else {
      await _dao.insert(record);
      AppLogger.info('[Repository] Inserted mood record: ${record.uuid}');
    }
    return record;
  }

  /// Finds a record by UUID
  Future<MoodRecord?> findByUuid(String uuid) => _dao.queryByUuid(uuid);

  /// Finds all records with optional pagination
  Future<List<MoodRecord>> findAll({int? limit, int? offset}) =>
      _dao.queryAll(limit: limit, offset: offset);

  /// Finds records with pagination
  Future<List<MoodRecord>> findPaged({
    required int page,
    required int pageSize,
  }) =>
      _dao.queryPaged(page: page, pageSize: pageSize);

  /// Deletes a record by UUID
  Future<void> delete(String uuid) {
    return _dao.delete(uuid);
  }

  /// Deletes all records
  Future<void> deleteAll() {
    return _dao.deleteAll();
  }

  /// Finds records within a date range
  Future<List<MoodRecord>> findByDateRange(DateTime start, DateTime end) =>
      _dao.queryByDateRange(start, end);

  /// Gets summary statistics
  Future<StatSummary> getSummary({DateTime? since}) =>
      _dao.getSummary(since: since);

  /// Gets mood distribution
  Future<Map<MoodType, int>> getDistribution({DateTime? since}) =>
      _dao.getDistribution(since: since);

  /// Gets intensity trend for a date range
  Future<List<TimeSeriesPoint>> getIntensityTrend({
    required DateTime start,
    required DateTime end,
  }) =>
      _dao.getIntensityTrend(start: start, end: end);

  /// Gets total record count
  Future<int> getTotalCount() => _dao.getTotalCount();
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
