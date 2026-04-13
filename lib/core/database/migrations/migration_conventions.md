# Database Migration Conventions

## Versioning Strategy

- Database version starts at 1 and increments sequentially
- Each version increment corresponds to one migration step
- Version numbers are defined in `database_helper.dart` as `_dbVersion`
- Migrations are applied sequentially via `_onUpgrade` callback

## Migration Script Naming

```
migration_v{from}to{to}.dart
```

Examples:
- `migration_v1to2.dart` - migrates from v1 to v2
- `migration_v2to3.dart` - migrates from v2 to v3

## Migration Script Template

Each migration script must:

1. Be placed in `lib/core/database/migrations/`
2. Export a function: `Future<void> migrateV{from}ToV{to}(Database db) async`
3. Perform all operations within the function
4. Use transactions for data integrity
5. Log migration start and completion

```dart
import 'package:sqflite/sqflite.dart';
import 'package:mood_whisper/core/logger/app_logger.dart';

Future<void> migrateV1ToV2(Database db) async {
  AppLogger.info('[Migration] v1→v2 started');

  await db.transaction((txn) async {
    // Add new columns
    await txn.execute('ALTER TABLE table_name ADD COLUMN new_column TEXT');

    // Data migration if needed
    await txn.update('table_name', {'new_column': 'default'});

    // Create new indexes
    await txn.execute('CREATE INDEX idx_new ON table_name(new_column)');
  });

  AppLogger.info('[Migration] v1→v2 completed');
}
```

## Version History

| Version | Description | Migration File |
|---------|-------------|----------------|
| 1 | Initial schema with mood_records and app_settings | (initial) |
| 2 | TBD | migration_v1to2.dart |

## Checklist Before Migration

- [ ] Write migration script following template
- [ ] Update `_dbVersion` in `database_helper.dart`
- [ ] Uncomment migration call in `_onUpgrade`
- [ ] Test migration on development database
- [ ] Backup production data before deployment
- [ ] Monitor error logs after deployment

## Rollback Policy

SQLite migrations cannot be automatically rolled back.
For critical migrations, ship a new migration that reverses the change.
