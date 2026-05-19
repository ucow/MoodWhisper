import '../../../core/constants/mood_type.dart';

/// 情绪记录实体
/// 基于架构设计文档 v1.0 §6.2
class MoodRecord {
  final int? id;
  final String uuid;  // v3.0 云端同步预留
  final MoodType moodType;
  final int intensity; // 1-5
  final String? note;
  final DateTime recordedAt; // 用户选择的时间（可回溯7天内）
  final DateTime createdAt; // 实际创建时间
  final DateTime updatedAt; // 最后更新时间

  MoodRecord({
    this.id,
    required this.uuid,
    required this.moodType,
    required this.intensity,
    this.note,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库 Map 创建
  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    return MoodRecord(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      moodType: MoodType.fromKey(map['mood_type'] as String) ?? MoodType.happy,
      intensity: map['intensity'] as int,
      note: map['note'] as String?,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'mood_type': moodType.key,
      'intensity': intensity,
      'note': note,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建副本（用于更新）
  MoodRecord copyWith({
    int? id,
    String? uuid,
    MoodType? moodType,
    int? intensity,
    String? note,
    DateTime? recordedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodRecord(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      moodType: moodType ?? this.moodType,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MoodRecord(id: $id, mood: ${moodType.label}, intensity: $intensity, at: $recordedAt)';
  }
}

/// 时间范围
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({required this.start, required this.end});

  factory DateTimeRange.last7Days() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day - 6),
      end: now,
    );
  }

  factory DateTimeRange.last30Days() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day - 29),
      end: now,
    );
  }

  factory DateTimeRange.all() {
    return DateTimeRange(
      start: DateTime(2000),
      end: DateTime.now(),
    );
  }
}

/// 统计摘要
class StatSummary {
  final double averageIntensity;
  final MoodType mostFrequentMood;
  final int totalRecords;
  final int totalDays;

  StatSummary({
    required this.averageIntensity,
    required this.mostFrequentMood,
    required this.totalRecords,
    required this.totalDays,
  });
}

/// 时间序列数据点
class TimeSeriesPoint {
  final DateTime date;
  final double value;

  TimeSeriesPoint({required this.date, required this.value});
}
