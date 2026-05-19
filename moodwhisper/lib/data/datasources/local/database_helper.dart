import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库版本管理
class DbVersion {
  static const int current = 2;
}

/// 数据库名称
const String dbName = 'mood_whisper.db';

/// DatabaseHelper - SQLite 单例模式
/// 所有数据库操作必须在 Main Isolate 执行
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  /// 单例访问
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// 获取数据库实例（懒加载）
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    return openDatabase(
      path,
      version: DbVersion.current,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建表（首次创建）
  Future<void> _onCreate(Database db, int version) async {
    // mood_records 表
    await db.execute('''
      CREATE TABLE mood_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        mood_type TEXT NOT NULL,
        intensity INTEGER NOT NULL CHECK (intensity BETWEEN 1 AND 5),
        note TEXT,
        recorded_at TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // app_settings 表
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 索引
    await db.execute(
      'CREATE INDEX idx_mood_records_recorded_at ON mood_records(recorded_at DESC)'
    );
    await db.execute(
      'CREATE INDEX idx_mood_records_mood_type ON mood_records(mood_type)'
    );

    // 预置设置
    await db.insert('app_settings', {
      'key': 'theme_mode',
      'value': 'system',
    });
    await db.insert('app_settings', {
      'key': 'onboarding_completed',
      'value': 'false',
    });
    await db.insert('app_settings', {
      'key': 'list_swipe_guided',
      'value': 'false',
    });
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 -> v2: 添加 uuid 字段
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE mood_records ADD COLUMN uuid TEXT UNIQUE
      ''');
      // 为现有记录生成 UUID
      await db.execute('''
        UPDATE mood_records SET uuid = lower(hex(randomblob(16)))
        WHERE uuid IS NULL
      ''');
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 清空所有数据（用于测试或清空功能）
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('mood_records');
    await db.update(
      'app_settings',
      {'value': 'false'},
      where: "key = 'onboarding_completed'",
    );
    await db.update(
      'app_settings',
      {'value': 'false'},
      where: "key = 'list_swipe_guided'",
    );
  }
}

/// 数据库单例访问便捷方法
Future<Database> getDb() => DatabaseHelper.instance.database;
