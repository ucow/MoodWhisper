/// 情绪类型枚举
/// 基于 PRD v2.5 + 架构设计文档 v1.0 §6.2
/// 按效价（积极→消极）排列：开心→平静→难过→焦虑→生气

enum MoodType {
  happy('happy', '开心', '😊', 0.8),
  calm('calm', '平静', '😌', 0.6),
  sad('sad', '难过', '😢', 0.3),
  anxious('anxious', '焦虑', '😰', 0.2),
  angry('angry', '生气', '😠', 0.1);

  const MoodType(this.key, this.label, this.emoji, this.valence);

  /// 唯一标识键
  final String key;

  /// 显示标签
  final String label;

  /// 表情图标
  final String emoji;

  /// 效价分数（用于排列顺序：积极→消极）
  final double valence;

  /// 通过 key 获取枚举值
  static MoodType? fromKey(String key) {
    return MoodType.values.cast<MoodType?>().firstWhere(
      (e) => e?.key == key,
      orElse: () => null,
    );
  }
}

/// 强度范围常量
class IntensityRange {
  static const int min = 1;
  static const int max = 5;
  static const int defaultValue = 3;
}
