import 'package:mood_whisper/data/dao/mood_record_dao.dart';
import 'package:mood_whisper/data/models/mood_record.dart';

class MoodRecordRepository {
  final MoodRecordDao _dao;

  MoodRecordRepository(this._dao);

  Future<MoodRecord> save(MoodRecord record) async {
    final existing = await _dao.queryByUuid(record.uuid);
    if (existing != null) {
      await _dao.update(record);
    } else {
      await _dao.insert(record);
    }
    return record;
  }

  Future<MoodRecord?> findByUuid(String uuid) => _dao.queryByUuid(uuid);

  Future<List<MoodRecord>> findAll({int? limit, int? offset}) =>
      _dao.queryAll(limit: limit, offset: offset);

  Future<void> delete(String uuid) => _dao.delete(uuid);

  Future<List<MoodRecord>> findByDateRange(DateTime start, DateTime end) =>
      _dao.queryByDateRange(start, end);
}
