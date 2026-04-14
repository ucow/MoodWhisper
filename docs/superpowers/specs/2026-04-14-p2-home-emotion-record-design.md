# P2 情绪记录首页 - 设计规格

## 概述
实现首页·情绪记录功能，包含情绪选择、强度调节、备注输入、时间修改、粒子保存动画。

## 2.1 EmotionButton 组件

### 布局
- 5个情绪按钮横向排列，val valence顺序: 极好(😆)→极差(😢)
- 间距: `AppSpacing.sm`
- 按钮大小: 56x56 圆形

### 状态
| 状态 | 样式 |
|------|------|
| 未选中 | 透明度 0.4，无边框 |
| 选中 | 放大 1.15x，spring动画 200ms，边框高亮(2px) |

### 交互
- 点击: haptic feedback (light impact)
- 选中态: 背景填充情绪色 20% opacity

### 实现
```dart
class EmotionButton extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;
}
```

## 2.2 IntensitySlider 组件

### 规格
- 5级离散滑块 (1-5)
- 默认值: 3
- 轨道填充情绪色

### 实现
- 使用 `Slider` 组件
- `divisions: 4`
- `activeColor` = 当前情绪对应颜色
- 显示当前强度数值

## 2.3 备注输入 + 键盘适配

### 规格
- 最大 500 字符
- 接近上限提示: 450/500, 480/500, 500/500
- 保存按钮 sticky bottom
- 键盘弹出时页面上推

### 实现
- `TextField` with `maxLines: 4`
- 实时字符计数显示
- `Scaffold` with `resizeToAvoidBottomInset: true`

## 2.4 时间修改交互

### 规格
- 点击顶栏时间文字触发 DateTimePicker
- 可选范围: ≤7天（今天往前7天）

### 实现
- `showDatePicker` + `showTimePicker`
- ` selectableDayPredicate` 限制日期范围

## 2.5 粒子保存动画

### 规格
- Canvas 自绘粒子扩散
- 首帧 >16ms 自动降级为缩放动画
- 降级结果持久化到 SettingsRepository

### 实现
- `CustomPainter` + `AnimationController`
- 降级标志: `_keyParticleAnimationDegraded`
- 降级时使用 `ScaleTransition` + `FadeTransition` 替代

## 2.6 保存逻辑串联

### 规格
- 未选情绪 → 按钮禁用
- 已选 → 情绪色激活按钮
- 点击 → 粒子动画 → Repository写入 → 界面重置
- 保存成功 haptic feedback (medium impact)

### 实现
- `recordFormProvider` 管理状态
- `save()` 方法内执行动画后保存

## 2.7 最近记录预览区

### 规格
- 首页底部展示最近3条
- 点击跳转列表页

### 实现
- `recentRecordsProvider` limit=3
- `HomeScreen` 底部添加 `_RecentRecordsPreview`

## 2.8 空状态处理

### 规格
- 无记录时显示: "选择一个表情开始记录吧👋"

### 实现
- `RecordScreen` 检查 `formState.moodType == null`
- 显示空状态提示

## 2.9 首页加载态

### 规格
- 情绪图标依次淡入
- 每个间隔 100ms

### 实现
- `AnimationController` + `Interval`
- 5个图标，每个 100ms 延迟

## 2.10 Widget测试

### 规格
- 情绪选择 → 强度调节 → 保存流程

### 实现
- `test/widget/record_screen_test.dart`
- 全流程 smoke test

## 组件清单

| 组件 | 文件 |
|------|------|
| EmotionButton | `lib/features/record/presentation/widgets/emotion_button.dart` |
| IntensitySlider | `lib/features/record/presentation/widgets/intensity_slider.dart` |
| NoteInput | `lib/features/record/presentation/widgets/note_input.dart` |
| ParticleAnimation | `lib/features/record/presentation/widgets/particle_animation.dart` |
| RecentRecordsPreview | `lib/features/home/presentation/widgets/recent_records_preview.dart` |
| EmptyState | `lib/features/record/presentation/widgets/empty_state.dart` |
| RecordScreen | 更新 `lib/features/record/presentation/screens/record_screen.dart` |
| HomeScreen | 更新 `lib/features/home/presentation/screens/home_screen.dart` |

## Settings Keys

| Key | 类型 | 说明 |
|-----|------|------|
| `particle_animation_degraded` | bool | 粒子动画是否降级 |

## Provider 变更

- `RecordFormNotifier`: 添加 `recordedAt` 支持
- `RecordFormState`: 添加 `recordedAt` 字段
- `recentRecordsProvider`: limit=10 保持不变（预览只取前3）

## 依赖

- `flutter/services.dart` - HapticFeedback
- `shared_preferences` 或 SettingsRepository - 降级标志持久化
