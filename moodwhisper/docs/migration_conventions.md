# SQLite 数据库迁移规范

## 1. 版本管理原则
- `DB_VERSION` 常量必须逐级递增，不允许跳跃
- 每次迁移只升 1 个版本
- 迁移脚本必须可逆或明确标记为不可逆

## 2. 当前版本
```dart
class DbVersion {
  static const int current = 2;
}
```

## 3. 迁移历史

### v0 → v1（初始建表）
- 创建 `mood_records` 表
- 创建 `app_settings` 表
- 创建索引

### v1 → v2
- 添加 `uuid` 字段（v3.0 云端同步预留）
- 为现有记录生成 UUID

## 4. 迁移代码模板
```dart
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _migrateToV2(db);
  }
  if (oldVersion < 3) {
    await _migrateToV3(db);
  }
}

Future<void> _migrateToV2(Database db) async {
  await db.execute('ALTER TABLE mood_records ADD COLUMN uuid TEXT UNIQUE');
  await db.execute('''
    UPDATE mood_records SET uuid = lower(hex(randomblob(16)))
    WHERE uuid IS NULL
  ''');
}
```

## 5. 约束
⚠️ **所有数据库操作必须在 Main Isolate 执行**
⚠️ **禁止在后台 Isolate 中直接访问数据库**
