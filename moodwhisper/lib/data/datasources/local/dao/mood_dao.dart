import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/mood_record.dart';
import '../../../core/constants/mood_type.dart';

/// MoodDao - 情绪记录数据访问对象
/// 基于架构设计文档 v1.0 §6.1
class MoodDao {
  Future<Database> get _db => getDb();

  /// 创建记录
  Future<MoodRecord> insert(MoodRecord record) async {
    final db = await _db;
    final id = await db.insert('mood_records', record.toMap());
    return record.copyWith(id: id);
  }

  /// 更新记录
  Future<MoodRecord> update(MoodRecord record) async {
    final db = await _db;
    await db.update(
      'mood_records',
      record.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
    return record.copyWith(updatedAt: DateTime.now());
  }

  /// 删除记录
  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(
      'mood_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 清空所有记录
  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('mood_records');
  }

  /// 分页查询列表（按时间倒序）
  Future<List<MoodRecord>> queryPaged({
    required int page,
    required int pageSize,
    DateTimeRange? range,
  }) async {
    final db = await _db;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (range != null) {
      whereClause = 'recorded_at BETWEEN ? AND ?';
      whereArgs = [
        range.start.toIso8601String(),
        range.end.toIso8601String(),
      ];
    }

    final result = await db.query(
      'mood_records',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'recorded_at DESC',
      limit: pageSize,
      offset: page * pageSize,
    );

    return result.map((map) => MoodRecord.fromMap(map)).toList();
  }

  /// 获取统计摘要
  Future<StatSummary> getSummary({DateTimeRange? range}) async {
    final db = await _db;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (range != null) {
      whereClause = 'WHERE recorded_at BETWEEN ? AND ?';
      whereArgs = [
        range.start.toIso8601String(),
        range.end.toIso8601String(),
      ];
    }

    // 平均强度
    final avgResult = await db.rawQuery(
      'SELECT AVG(intensity) as avg FROM mood_records $whereClause',
      whereArgs,
    );
    final avgIntensity = (avgResult.first['avg'] as num?)?.toDouble() ?? 0.0;

    // 最频繁情绪
    final countResult = await db.rawQuery('''
      SELECT mood_type, COUNT(*) as count 
      FROM mood_records 
      $whereClause
      GROUP BY mood_type 
      ORDER BY count DESC 
      LIMIT 1
    ''', whereArgs);
    final mostFrequentKey = countResult.isNotEmpty 
        ? countResult.first['mood_type'] as String 
        : 'happy';
    final mostFrequentMood = MoodType.fromKey(mostFrequentKey) ?? MoodType.happy;

    // 记录总数
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM mood_records $whereClause',
      whereArgs,
    );
    final totalRecords = totalResult.first['count'] as int? ?? 0;

    // 记录天数
    final daysResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT date(recorded_at)) as days 
      FROM mood_records 
      $whereClause
    ''', whereArgs);
    final totalDays = daysResult.first['days'] as int? ?? 0;

    return StatSummary(
      averageIntensity: avgIntensity,
      mostFrequentMood: mostFrequentMood,
      totalRecords: totalRecords,
      totalDays: totalDays,
    );
  }

  /// 获取情绪分布
  Future<Map<MoodType, int>> getDistribution({DateTimeRange? range}) async {
    final db = await _db;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (range != null) {
      whereClause = 'WHERE recorded_at BETWEEN ? AND ?';
      whereArgs = [
        range.start.toIso8601String(),
        range.end.toIso8601String(),
      ];
    }

    final result = await db.rawQuery('''
      SELECT mood_type, COUNT(*) as count 
      FROM mood_records 
      $whereClause
      GROUP BY mood_type
    ''', whereArgs);

    final distribution = <MoodType, int>{};
    for (final type in MoodType.values) {
      distribution[type] = 0;
    }

    for (final row in result) {
      final type = MoodType.fromKey(row['mood_type'] as String);
      if (type != null) {
        distribution[type] = row['count'] as int;
      }
    }

    return distribution;
  }

  /// 获取强度趋势（按天聚合）
  Future<List<TimeSeriesPoint>> getIntensityTrend({DateTimeRange? range}) async {
    final db = await _db;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (range != null) {
      whereClause = 'WHERE recorded_at BETWEEN ? AND ?';
      whereArgs = [
        range.start.toIso8601String(),
        range.end.toIso8601String(),
      ];
    }

    final result = await db.rawQuery('''
      SELECT 
        date(recorded_at) as date,
        AVG(intensity) as avg_intensity
      FROM mood_records
      $whereClause
      GROUP BY date(recorded_at)
      ORDER BY date ASC
    ''', whereArgs);

    return result.map((row) {
      return TimeSeriesPoint(
        date: DateTime.parse(row['date'] as String),
        value: (row['avg_intensity'] as num).toDouble(),
      );
    }).toList();
  }

  /// 检查是否有足够数据（>=7天）
  Future<bool> hasEnoughDataForStats() async {
    final db = await _db;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT date(recorded_at)) as days FROM mood_records
    ''');
    final days = result.first['days'] as int? ?? 0;
    return days >= 7;
  }
}
