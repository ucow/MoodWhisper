import 'package:sqflite/sqflite.dart';
import 'package:mood_whisper/core/logger/app_logger.dart';

/// Migration from v1 to v2
///
/// v1: Initial schema with mood_records and app_settings tables
/// v2: Reserved for future schema changes (e.g., adding tags, categories)
///
/// Current v1 schema:
/// - mood_records: id, uuid, mood_type, intensity, note, recorded_at, created_at, updated_at
/// - app_settings: key, value, updated_at
///
/// When adding new migrations:
/// 1. Create new migration file (e.g., migration_v2to3.dart)
/// 2. Update _dbVersion in database_helper.dart
/// 3. Uncomment the migration call in _onUpgrade
Future<void> migrateV1ToV2(Database db) async {
  AppLogger.info('[Migration] v1→v2 started');

  await db.transaction((txn) async {
    // Example: Add new column
    // await txn.execute(
    //   'ALTER TABLE mood_records ADD COLUMN tags TEXT',
    // );

    // Example: Create new table
    // await txn.execute('''
    //   CREATE TABLE IF NOT EXISTS mood_tags (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     name TEXT UNIQUE NOT NULL,
    //     color TEXT
    //   )
    // ''');

    // Placeholder: No schema changes for v2 yet
    // This migration serves as a template for future migrations
    AppLogger.info('[Migration] v1→v2: No schema changes in this version');
  });

  AppLogger.info('[Migration] v1→v2 completed');
}
