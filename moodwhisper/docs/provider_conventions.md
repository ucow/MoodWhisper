# Riverpod Provider 规范

## 1. Provider 分层架构

### 全局 Provider（app/ 目录）
```dart
// 数据库实例
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('必须被 ProviderScope 覆盖');
});

// 仓库层
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});
```

### 页面级 Provider（features/ 各模块 bloc/ 目录）
```dart
// 记录列表状态
final recordListNotifierProvider = StateNotifierProvider<RecordListNotifier, RecordListState>((ref) {
  return RecordListNotifier(ref.watch(moodRepositoryProvider));
});
```

## 2. Provider 命名规范
- Provider: `xxxProvider`
- StateNotifier: `XxxNotifier`
- State: `XxxState`

## 3. 状态管理原则
- 使用 `ref.watch` 监听状态变化
- 使用 `ref.read` 执行一次性操作
- 避免在 build 方法外调用 `ref.read`

## 4. AsyncValue 使用
对于异步数据，使用 `AsyncValue` 处理加载/错误/数据三态：
```dart
final recordsProvider = FutureProvider<List<MoodRecord>>((ref) async {
  final repo = ref.watch(moodRepositoryProvider);
  return repo.getList();
});
```
