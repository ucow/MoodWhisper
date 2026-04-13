import 'package:mood_whisper/core/constants/mood_types.dart';

class MoodRecord {
  final int? id;
  final String uuid;
  final MoodType moodType;
  final int intensity;
  final String? note;
  final DateTime recordedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MoodRecord({
    this.id,
    required this.uuid,
    required this.moodType,
    required this.intensity,
    this.note,
    required this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'mood_type': moodType.key,
      'intensity': intensity,
      'note': note,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    return MoodRecord(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      moodType: MoodType.fromKey(map['mood_type'] as String),
      intensity: map['intensity'] as int,
      note: map['note'] as String?,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recorded_at'] as int),
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
