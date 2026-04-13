import 'package:mood_whisper/core/database/database_helper.dart';
import 'package:mood_whisper/data/models/mood_record.dart';

class MoodRecordDao {
  final DatabaseHelper _dbHelper;

  MoodRecordDao(this._dbHelper);

  Future<int> insert(MoodRecord record) async {
    final db = await _dbHelper.database;
    return db.insert('mood_records', record.toMap());
  }

  Future<MoodRecord?> queryByUuid(String uuid) async {
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
    final db = await _dbHelper.database;
    final maps = await db.query(
      'mood_records',
      orderBy: 'recorded_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => MoodRecord.fromMap(m)).toList();
  }

  Future<int> delete(String uuid) async {
    final db = await _dbHelper.database;
    return db.delete(
      'mood_records',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<int> update(MoodRecord record) async {
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
}
