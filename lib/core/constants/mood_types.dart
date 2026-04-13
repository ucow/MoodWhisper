enum MoodType {
  great('great', '极好', '😆', 2),
  good('good', '好', '😊', 1),
  neutral('neutral', '一般', '😐', 0),
  bad('bad', '差', '😔', -1),
  terrible('terrible', '极差', '😢', -2);

  const MoodType(this.key, this.label, this.emoji, this.valence);

  final String key;
  final String label;
  final String emoji;
  final int valence;

  static MoodType fromKey(String key) {
    return MoodType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => MoodType.neutral,
    );
  }
}
