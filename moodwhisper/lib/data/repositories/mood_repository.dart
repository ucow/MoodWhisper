import 'package:uuid/uuid.dart';
import '../datasources/local/dao/mood_dao.dart';
import '../models/mood_record.dart';
import '../../../core/constants/mood_type.dart';

/// MoodRepository - 情绪记录仓库层
/// 封装业务逻辑，基于架构设计文档 v1.0 §6.1
class MoodRepository {
  final MoodDao _dao;
  final Uuid _uuid = const Uuid();

  MoodRepository({MoodDao? dao}) : _dao = dao ?? MoodDao();

  /// 创建记录
  Future<MoodRecord> create({
    required MoodType moodType,
    required int intensity,
    String? note,
    required DateTime recordedAt,
  }) async {
    // 强度校验
    if (intensity < IntensityRange.min || intensity > IntensityRange.max) {
      throw ArgumentError('Intensity must be between ${IntensityRange.min} and ${IntensityRange.max}');
    }

    // 时间回溯校验（不能超过7天前）
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day - 7);
    if (recordedAt.isBefore(sevenDaysAgo)) {
      throw ArgumentError('recordedAt cannot be more than 7 days ago');
    }

    final record = MoodRecord(
      uuid: _uuid.v4(),  // v3.0 云端同步预留
      moodType: moodType,
      intensity: intensity,
      note: note?.isNotEmpty == true ? note : null,
      recordedAt: recordedAt,
      createdAt: now,
      updatedAt: now,
    );

    return _dao.insert(record);
  }

  /// 更新记录
  Future<MoodRecord> update(MoodRecord record) async {
    // 强度校验
    if (record.intensity < IntensityRange.min || record.intensity > IntensityRange.max) {
      throw ArgumentError('Intensity must be between ${IntensityRange.min} and ${IntensityRange.max}');
    }

    // 时间回溯校验
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day - 7);
    if (record.recordedAt.isBefore(sevenDaysAgo)) {
      throw ArgumentError('recordedAt cannot be more than 7 days ago');
    }

    return _dao.update(record);
  }

  /// 删除记录
  Future<void> delete(int id) async {
    await _dao.delete(id);
  }

  /// 清空所有记录
  Future<void> deleteAll() async {
    await _dao.deleteAll();
  }

  /// 分页查询列表
  Future<List<MoodRecord>> getList({
    int page = 0,
    int pageSize = 20,
    DateTimeRange? range,
  }) async {
    return _dao.queryPaged(
      page: page,
      pageSize: pageSize,
      range: range,
    );
  }

  /// 获取统计摘要
  Future<StatSummary> getSummary({DateTimeRange? range}) async {
    return _dao.getSummary(range: range);
  }

  /// 获取情绪分布
  Future<Map<MoodType, int>> getDistribution({DateTimeRange? range}) async {
    return _dao.getDistribution(range: range);
  }

  /// 获取强度趋势
  Future<List<TimeSeriesPoint>> getIntensityTrend({DateTimeRange? range}) async {
    return _dao.getIntensityTrend(range: range);
  }

  /// 检查是否有足够数据
  Future<bool> hasEnoughDataForStats() async {
    return _dao.hasEnoughDataForStats();
  }
}
