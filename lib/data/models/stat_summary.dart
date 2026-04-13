import 'package:mood_whisper/core/constants/mood_types.dart';

/// Summary statistics for mood records
class StatSummary {
  final int totalRecords;
  final double averageIntensity;
  final MoodType? dominantMood;
  final int currentStreak;
  final int longestStreak;
  final Map<MoodType, int> moodDistribution;

  const StatSummary({
    required this.totalRecords,
    required this.averageIntensity,
    this.dominantMood,
    required this.currentStreak,
    required this.longestStreak,
    required this.moodDistribution,
  });

  factory StatSummary.empty() {
    return const StatSummary(
      totalRecords: 0,
      averageIntensity: 0.0,
      dominantMood: null,
      currentStreak: 0,
      longestStreak: 0,
      moodDistribution: {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalRecords': totalRecords,
      'averageIntensity': averageIntensity,
      'dominantMood': dominantMood?.key,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'moodDistribution': moodDistribution.map(
        (key, value) => MapEntry(key.key, value),
      ),
    };
  }
}
