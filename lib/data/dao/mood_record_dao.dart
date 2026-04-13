import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/database/database_helper.dart';
import 'package:mood_whisper/core/logger/app_logger.dart';
import 'package:mood_whisper/data/models/mood_record.dart';
import 'package:mood_whisper/data/models/stat_summary.dart';
import 'package:mood_whisper/data/models/time_series_point.dart';

class MoodRecordDao {
  final DatabaseHelper _dbHelper;

  MoodRecordDao(this._dbHelper);

  Future<int> insert(MoodRecord record) async {
    AppLogger.logDbOperation('INSERT', 'mood_records', id: record.uuid);
    final db = await _dbHelper.database;
    return db.insert('mood_records', record.toMap());
  }

  Future<MoodRecord?> queryByUuid(String uuid) async {
    AppLogger.logDbOperation('QUERY', 'mood_records', id: uuid);
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mood_records',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return MoodRecord.fromMap(maps.first);
  }

  Future<List<MoodRecord>> queryAll({int? limit, int? offset}) async {
    AppLogger.logDbOperation('QUERY_ALL', 'mood_records');
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mood_records',
      orderBy: 'recorded_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => MoodRecord.fromMap(m)).toList();
  }

  Future<List<MoodRecord>> queryPaged({
    required int page,
    required int pageSize,
  }) async {
    AppLogger.logDbOperation('QUERY_PAGED', 'mood_records',
        id: 'page=$page,size=$pageSize');
    final db = await _dbHelper.database;
    final offset = page * pageSize;
    final maps = await db.query(
      'mood_records',
      orderBy: 'recorded_at DESC',
      limit: pageSize,
      offset: offset,
    );
    return maps.map((m) => MoodRecord.fromMap(m)).toList();
  }

  Future<int> delete(String uuid) async {
    AppLogger.logDbOperation('DELETE', 'mood_records', id: uuid);
    final db = await _dbHelper.database;
    return db.delete(
      'mood_records',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<int> deleteAll() async {
    AppLogger.logDbOperation('DELETE_ALL', 'mood_records');
    final db = await _dbHelper.database;
    return db.delete('mood_records');
  }

  Future<int> update(MoodRecord record) async {
    AppLogger.logDbOperation('UPDATE', 'mood_records', id: record.uuid);
    final db = await _dbHelper.database;
    return db.update(
      'mood_records',
      record.toMap(),
      where: 'uuid = ?',
      whereArgs: [record.uuid],
    );
  }

  Future<List<MoodRecord>> queryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    AppLogger.logDbOperation('QUERY_BY_DATE_RANGE', 'mood_records',
        id: '${start.toIso8601String()}-${end.toIso8601String()}');
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mood_records',
      where: 'recorded_at >= ? AND recorded_at <= ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'recorded_at DESC',
    );
    return maps.map((m) => MoodRecord.fromMap(m)).toList();
  }

  Future<StatSummary> getSummary({DateTime? since}) async {
    AppLogger.logDbOperation('GET_SUMMARY', 'mood_records');
    final db = await _dbHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (since != null) {
      whereClause = 'WHERE recorded_at >= ?';
      whereArgs = [since.millisecondsSinceEpoch];
    }

    // Total records and average intensity
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count, AVG(intensity) as avg_intensity FROM mood_records $whereClause',
      whereArgs,
    );
    final totalRecords = countResult.first['count'] as int? ?? 0;
    final averageIntensity = (countResult.first['avg_intensity'] as num?)?.toDouble() ?? 0.0;

    // Dominant mood
    MoodType? dominantMood;
    if (totalRecords > 0) {
      final moodResult = await db.rawQuery(
        'SELECT mood_type, COUNT(*) as count FROM mood_records $whereClause GROUP BY mood_type ORDER BY count DESC LIMIT 1',
        whereArgs,
      );
      if (moodResult.isNotEmpty) {
        dominantMood = MoodType.fromKey(moodResult.first['mood_type'] as String);
      }
    }

    // Mood distribution
    final Map<MoodType, int> moodDistribution = {};
    final distResult = await db.rawQuery(
      'SELECT mood_type, COUNT(*) as count FROM mood_records $whereClause GROUP BY mood_type',
      whereArgs,
    );
    for (final row in distResult) {
      final moodType = MoodType.fromKey(row['mood_type'] as String);
      moodDistribution[moodType] = row['count'] as int;
    }

    // Calculate streaks
    final streaks = await _calculateStreaks(db);

    return StatSummary(
      totalRecords: totalRecords,
      averageIntensity: averageIntensity,
      dominantMood: dominantMood,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      moodDistribution: moodDistribution,
    );
  }

  Future<Map<String, int>> _calculateStreaks(dynamic db) async {
    final result = await db.rawQuery('''
      SELECT DISTINCT date(recorded_at / 1000, 'unixepoch', 'localtime') as day
      FROM mood_records
      ORDER BY day DESC
    ''');

    if (result.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (int i = 0; i < result.length - 1; i++) {
      final currentDay = DateTime.parse(result[i]['day'] as String);
      final nextDay = DateTime.parse(result[i + 1]['day'] as String);

      if (currentDay.difference(nextDay).inDays == 1) {
        tempStreak++;
      } else {
        if (i == 0) {
          // Check if streak includes today or yesterday
          final firstDay = DateTime.parse(result.first['day'] as String);
          if (firstDay == today || firstDay == yesterday) {
            currentStreak = tempStreak;
          }
        }
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 1;
      }
    }

    // Handle the last streak
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
    if (result.length == 1) {
      final firstDay = DateTime.parse(result.first['day'] as String);
      if (firstDay == today || firstDay == yesterday) {
        currentStreak = 1;
      }
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  Future<Map<MoodType, int>> getDistribution({DateTime? since}) async {
    AppLogger.logDbOperation('GET_DISTRIBUTION', 'mood_records');
    final db = await _dbHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (since != null) {
      whereClause = 'WHERE recorded_at >= ?';
      whereArgs = [since.millisecondsSinceEpoch];
    }

    final result = await db.rawQuery(
      'SELECT mood_type, COUNT(*) as count FROM mood_records $whereClause GROUP BY mood_type',
      whereArgs,
    );

    final Map<MoodType, int> distribution = {};
    for (final row in result) {
      final moodType = MoodType.fromKey(row['mood_type'] as String);
      distribution[moodType] = row['count'] as int;
    }

    return distribution;
  }

  Future<List<TimeSeriesPoint>> getIntensityTrend({
    required DateTime start,
    required DateTime end,
  }) async {
    AppLogger.logDbOperation('GET_INTENSITY_TREND', 'mood_records');
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT
        date(recorded_at / 1000, 'unixepoch', 'localtime') as day,
        AVG(intensity) as avg_intensity,
        COUNT(*) as count
      FROM mood_records
      WHERE recorded_at >= ? AND recorded_at <= ?
      GROUP BY day
      ORDER BY day ASC
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);

    return result.map((row) {
      return TimeSeriesPoint(
        date: DateTime.parse(row['day'] as String),
        value: (row['avg_intensity'] as num).toDouble(),
        count: row['count'] as int,
      );
    }).toList();
  }

  Future<int> getTotalCount() async {
    AppLogger.logDbOperation('GET_TOTAL_COUNT', 'mood_records');
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM mood_records');
    return result.first['count'] as int? ?? 0;
  }
}
