import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/data/models/mood_record.dart';

/// A test-specific DAO that uses a directly passed database
/// This allows proper test isolation without singleton issues
class TestMoodRecordDao {
  final Database db;

  TestMoodRecordDao(this.db);

  Future<int> insert(MoodRecord record) async {
    return db.insert('mood_records', record.toMap());
  }

  Future<MoodRecord?> queryByUuid(String uuid) async {
    final maps = await db.query(
      'mood_records',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
    if (maps.isEmpty) return null;
    return MoodRecord.fromMap(maps.first);
  }

  Future<List<MoodRecord>> queryAll({int? limit, int? offset}) async {
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
    return db.delete(
      'mood_records',
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  Future<int> deleteAll() async {
    return db.delete('mood_records');
  }

  Future<int> update(MoodRecord record) async {
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

  Future<int> getTotalCount() async {
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM mood_records');
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<MoodType, int>> getDistribution({DateTime? since}) async {
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

  Future<List<Map<String, dynamic>>> getIntensityTrend({
    required DateTime start,
    required DateTime end,
  }) async {
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

    return result;
  }

  Future<Map<String, dynamic>> getSummaryStats({DateTime? since}) async {
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (since != null) {
      whereClause = 'WHERE recorded_at >= ?';
      whereArgs = [since.millisecondsSinceEpoch];
    }

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count, AVG(intensity) as avg_intensity FROM mood_records $whereClause',
      whereArgs,
    );
    final totalRecords = countResult.first['count'] as int? ?? 0;
    final averageIntensity = (countResult.first['avg_intensity'] as num?)?.toDouble() ?? 0.0;

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

    return {
      'totalRecords': totalRecords,
      'averageIntensity': averageIntensity,
      'dominantMood': dominantMood,
    };
  }
}

void main() {
  late Database db;
  late TestMoodRecordDao dao;

  setUpAll(() {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create in-memory database for testing
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE mood_records (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              uuid TEXT UNIQUE NOT NULL,
              mood_type TEXT NOT NULL,
              intensity INTEGER NOT NULL DEFAULT 3,
              note TEXT,
              recorded_at INTEGER NOT NULL,
              created_at INTEGER,
              updated_at INTEGER
            )
          ''');
          await db.execute('''
            CREATE INDEX idx_mood_records_recorded_at
            ON mood_records(recorded_at DESC)
          ''');
        },
      ),
    );

    dao = TestMoodRecordDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('MoodRecordDao CRUD Tests', () {
    test('insert should add a new record', () async {
      final record = _createTestRecord(uuid: 'test-uuid-1');

      final id = await dao.insert(record);

      expect(id, greaterThan(0));
    });

    test('queryByUuid should return record when exists', () async {
      final record = _createTestRecord(uuid: 'test-uuid-2');
      await dao.insert(record);

      final result = await dao.queryByUuid('test-uuid-2');

      expect(result, isNotNull);
      expect(result!.uuid, equals('test-uuid-2'));
      expect(result.moodType, equals(record.moodType));
      expect(result.intensity, equals(record.intensity));
    });

    test('queryByUuid should return null when not exists', () async {
      final result = await dao.queryByUuid('non-existent-uuid');
      expect(result, isNull);
    });

    test('update should modify existing record', () async {
      final record = _createTestRecord(uuid: 'test-uuid-3');
      await dao.insert(record);

      final updatedRecord = record.copyWith(intensity: 5, note: 'Updated note');
      await dao.update(updatedRecord);

      final result = await dao.queryByUuid('test-uuid-3');
      expect(result!.intensity, equals(5));
      expect(result.note, equals('Updated note'));
    });

    test('delete should remove record', () async {
      final record = _createTestRecord(uuid: 'test-uuid-4');
      await dao.insert(record);

      await dao.delete('test-uuid-4');

      final result = await dao.queryByUuid('test-uuid-4');
      expect(result, isNull);
    });

    test('deleteAll should remove all records', () async {
      await dao.insert(_createTestRecord(uuid: 'test-uuid-5'));
      await dao.insert(_createTestRecord(uuid: 'test-uuid-6'));

      await dao.deleteAll();

      final count = await dao.getTotalCount();
      expect(count, equals(0));
    });

    test('queryAll should return all records ordered by recorded_at DESC', () async {
      final now = DateTime.now();
      await dao.insert(_createTestRecord(uuid: 'test-uuid-7', recordedAt: now.subtract(const Duration(days: 1))));
      await dao.insert(_createTestRecord(uuid: 'test-uuid-8', recordedAt: now));
      await dao.insert(_createTestRecord(uuid: 'test-uuid-9', recordedAt: now.subtract(const Duration(days: 2))));

      final results = await dao.queryAll();

      expect(results.length, equals(3));
      expect(results[0].uuid, equals('test-uuid-8')); // Most recent first
      expect(results[1].uuid, equals('test-uuid-7'));
      expect(results[2].uuid, equals('test-uuid-9'));
    });

    test('queryAll with limit should return limited records', () async {
      await dao.insert(_createTestRecord(uuid: 'test-uuid-10'));
      await dao.insert(_createTestRecord(uuid: 'test-uuid-11'));
      await dao.insert(_createTestRecord(uuid: 'test-uuid-12'));

      final results = await dao.queryAll(limit: 2);

      expect(results.length, equals(2));
    });

    test('queryPaged should return correct page', () async {
      for (int i = 0; i < 10; i++) {
        await dao.insert(_createTestRecord(uuid: 'test-uuid-page-$i'));
      }

      final page0 = await dao.queryPaged(page: 0, pageSize: 3);
      final page1 = await dao.queryPaged(page: 1, pageSize: 3);
      final page2 = await dao.queryPaged(page: 2, pageSize: 3);
      final page3 = await dao.queryPaged(page: 3, pageSize: 3);

      expect(page0.length, equals(3));
      expect(page1.length, equals(3));
      expect(page2.length, equals(3)); // records 6,7,8
      expect(page3.length, equals(1)); // records 9 (only 1 left out of 10)
    });

    test('queryByDateRange should return records within range', () async {
      final now = DateTime.now();
      await dao.insert(_createTestRecord(
        uuid: 'test-uuid-range-1',
        recordedAt: now.subtract(const Duration(days: 1)),
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-uuid-range-2',
        recordedAt: now.subtract(const Duration(days: 3)),
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-uuid-range-3',
        recordedAt: now.subtract(const Duration(days: 5)),
      ));

      final results = await dao.queryByDateRange(
        now.subtract(const Duration(days: 4)),
        now,
      );

      expect(results.length, equals(2));
    });

    test('getTotalCount should return correct count', () async {
      expect(await dao.getTotalCount(), equals(0));

      await dao.insert(_createTestRecord(uuid: 'test-count-1'));
      await dao.insert(_createTestRecord(uuid: 'test-count-2'));

      expect(await dao.getTotalCount(), equals(2));
    });
  });

  group('MoodRecordDao Statistics Tests', () {
    test('getSummaryStats should return correct statistics', () async {
      final now = DateTime.now();
      await dao.insert(_createTestRecord(
        uuid: 'test-stat-1',
        moodType: MoodType.good,
        intensity: 4,
        recordedAt: now,
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-stat-2',
        moodType: MoodType.good,
        intensity: 5,
        recordedAt: now,
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-stat-3',
        moodType: MoodType.neutral,
        intensity: 3,
        recordedAt: now,
      ));

      final summary = await dao.getSummaryStats();

      expect(summary['totalRecords'], equals(3));
      expect(summary['averageIntensity'], closeTo(4.0, 0.1));
      expect(summary['dominantMood'], equals(MoodType.good));
    });

    test('getSummaryStats should return empty summary when no records', () async {
      final summary = await dao.getSummaryStats();

      expect(summary['totalRecords'], equals(0));
      expect(summary['averageIntensity'], equals(0.0));
      expect(summary['dominantMood'], isNull);
    });

    test('getDistribution should return correct distribution', () async {
      final now = DateTime.now();
      await dao.insert(_createTestRecord(uuid: 'test-dist-1', moodType: MoodType.great));
      await dao.insert(_createTestRecord(uuid: 'test-dist-2', moodType: MoodType.great));
      await dao.insert(_createTestRecord(uuid: 'test-dist-3', moodType: MoodType.bad));
      await dao.insert(_createTestRecord(uuid: 'test-dist-4', moodType: MoodType.neutral));

      final distribution = await dao.getDistribution();

      expect(distribution[MoodType.great], equals(2));
      expect(distribution[MoodType.bad], equals(1));
      expect(distribution[MoodType.neutral], equals(1));
    });

    test('getDistribution with since should filter by date', () async {
      final now = DateTime.now();
      await dao.insert(_createTestRecord(
        uuid: 'test-dist-since-1',
        moodType: MoodType.great,
        recordedAt: now,
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-dist-since-2',
        moodType: MoodType.bad,
        recordedAt: now.subtract(const Duration(days: 10)),
      ));

      final distribution = await dao.getDistribution(
        since: now.subtract(const Duration(days: 7)),
      );

      expect(distribution[MoodType.great], equals(1));
      expect(distribution[MoodType.bad], isNull);
    });

    test('getIntensityTrend should return daily averages', () async {
      final now = DateTime.now();
      await dao.insert(_createTestRecord(
        uuid: 'test-trend-1',
        intensity: 4,
        recordedAt: DateTime(now.year, now.month, now.day, 10, 0),
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-trend-2',
        intensity: 2,
        recordedAt: DateTime(now.year, now.month, now.day, 14, 0),
      ));
      await dao.insert(_createTestRecord(
        uuid: 'test-trend-3',
        intensity: 5,
        recordedAt: DateTime(now.year, now.month, now.day, 16, 0),
      ));

      final trend = await dao.getIntensityTrend(
        start: DateTime(now.year, now.month, now.day),
        end: now,
      );

      expect(trend.length, equals(1));
      expect(trend[0]['avg_intensity'], closeTo(3.67, 0.1)); // (4+2+5)/3
      expect(trend[0]['count'], equals(3));
    });
  });

  group('MoodRecord Model Tests', () {
    test('toMap and fromMap should be reversible', () {
      final record = _createTestRecord(uuid: 'test-model-1');
      final map = record.toMap();
      final restored = MoodRecord.fromMap(map);

      expect(restored.uuid, equals(record.uuid));
      expect(restored.moodType, equals(record.moodType));
      expect(restored.intensity, equals(record.intensity));
      expect(restored.note, equals(record.note));
      expect(restored.recordedAt.millisecondsSinceEpoch,
          equals(record.recordedAt.millisecondsSinceEpoch));
    });

    test('copyWith should create modified copy', () {
      final original = _createTestRecord(uuid: 'test-copy-1');
      final modified = original.copyWith(intensity: 5, note: 'Modified');

      expect(modified.uuid, equals(original.uuid));
      expect(modified.intensity, equals(5));
      expect(modified.note, equals('Modified'));
      expect(original.intensity, equals(3)); // Original unchanged
    });
  });
}

MoodRecord _createTestRecord({
  String uuid = 'default-uuid',
  MoodType moodType = MoodType.neutral,
  int intensity = 3,
  String? note,
  DateTime? recordedAt,
}) {
  return MoodRecord(
    uuid: uuid,
    moodType: moodType,
    intensity: intensity,
    note: note,
    recordedAt: recordedAt ?? DateTime.now(),
  );
}
