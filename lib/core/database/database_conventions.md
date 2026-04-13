# Database Conventions

## SQLite Singleton Pattern

The `DatabaseHelper` class implements the singleton pattern to ensure only one database instance exists throughout the application lifecycle.

```dart
class DatabaseHelper {
  DatabaseHelper._();  // Private constructor
  static final DatabaseHelper instance = DatabaseHelper._();  // Singleton instance

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }
}
```

### Why Singleton?

- **Thread Safety**: SQLite connections are not thread-safe. A single instance ensures all database operations go through the same connection.
- **Resource Management**: Creating multiple database connections wastes resources and can cause locking issues.
- **Consistency**: Single source of truth for database state.

### Rules

1. **Never** instantiate `DatabaseHelper` directly - use `DatabaseHelper.instance`
2. **Never** call `openDatabase` multiple times - use the `database` getter
3. **Always** use `async/await` when accessing the database
4. **Never** close the database manually - let Flutter manage the lifecycle

## Isolate Usage Specification

### When to Use Isolates

Use isolates for expensive database operations that could block the UI thread:

- Large data exports (>1000 records)
- Batch inserts/updates
- Complex aggregation queries
- Database compaction

### When NOT to Use Isolates

Regular CRUD operations don't need isolates because:

- SQLite operations in sqflite are already asynchronous
- The overhead of isolate communication may exceed the operation time
- Most operations complete in <100ms

### Implementation Pattern

```dart
Future<void> _runInIsolate(List<MoodRecord> records) async {
  await Isolate.run(() async {
    final db = await database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert('mood_records', record.toMap());
    }
    await batch.commit(noResult: true);
  });
}
```

### Communication Protocol

When passing data to/from isolates:

1. Use simple types (int, String, List, Map) - not complex objects
2. Serialize data to JSON if needed for complex objects
3. Avoid passing database connections across isolates

## Indexes

### Required Indexes

| Table | Column | Purpose |
|-------|--------|---------|
| mood_records | recorded_at | Date range queries, sorting |
| mood_records | uuid | Lookups by UUID |
| mood_records | mood_type | Distribution queries |

### Index Creation

Create indexes in `onCreate` or migrations:

```dart
await db.execute('''
  CREATE INDEX idx_mood_records_recorded_at
  ON mood_records(recorded_at DESC)
''');
```

## Performance Guidelines

1. **Batch Operations**: Use `batch()` for bulk inserts
2. **Pagination**: Always paginate large queries (limit/offset)
3. **Projection**: Only select needed columns
4. **Indexes**: Create indexes for frequently queried columns
5. **Transactions**: Wrap multiple operations in transactions

## Connection Pooling

sqflite handles connection pooling internally. No manual configuration needed for typical use cases.

## Error Handling

Database errors should be caught and handled gracefully:

```dart
try {
  await db.insert('mood_records', record.toMap());
} on DatabaseException catch (e) {
  if (e.isUniqueConstraintError()) {
    throw DuplicateRecordException('Record already exists');
  }
  rethrow;
}
```
