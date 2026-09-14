import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

/// SQL explícito: migraciones revisables sin generación de código.
class LocalDatabase extends GeneratedDatabase {
  LocalDatabase(super.executor);
  factory LocalDatabase.device() => LocalDatabase(LazyDatabase(() async {
        final directory = await getApplicationSupportDirectory();
        return NativeDatabase.createInBackground(
            File('${directory.path}/bicifirme.sqlite'));
      }));
  @override
  int get schemaVersion => 2;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {
        await customStatement('''CREATE TABLE bikes (
        id TEXT PRIMARY KEY, name TEXT NOT NULL CHECK(length(trim(name)) > 0),
        type TEXT NOT NULL, profile TEXT NOT NULL)''');
        await _createRelatedTables();
      }, onUpgrade: (_, from, to) async {
        if (from != 1 || to != 2) {
          throw StateError('Migración no soportada: $from → $to');
        }
        await transaction(_createRelatedTables);
      }, beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        if (details.versionNow != schemaVersion) {
          throw StateError('Versión no soportada');
        }
      });
  Future<void> _createRelatedTables() async {
    await customStatement(
        'CREATE TABLE preferences (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
    await customStatement('''CREATE TABLE components (
      id TEXT PRIMARY KEY, bike_id TEXT NOT NULL REFERENCES bikes(id) ON DELETE CASCADE,
      description TEXT NOT NULL, catalog_id TEXT, details TEXT NOT NULL)''');
    await customStatement('''CREATE TABLE kit (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, quantity INTEGER NOT NULL CHECK(quantity >= 0))''');
    await customStatement('''CREATE TABLE history (
      id TEXT PRIMARY KEY, bike_id TEXT REFERENCES bikes(id) ON DELETE SET NULL,
      created_at TEXT NOT NULL, procedure_id TEXT NOT NULL, title TEXT NOT NULL,
      outcome TEXT NOT NULL CHECK(outcome IN ('complete','temporary','stop','unresolved')),
      notes TEXT NOT NULL, resolved INTEGER NOT NULL CHECK(resolved IN (0,1)))''');
    await customStatement('''CREATE TABLE maintenance (
      id TEXT PRIMARY KEY, bike_id TEXT NOT NULL REFERENCES bikes(id) ON DELETE CASCADE,
      title TEXT NOT NULL, completed_at TEXT, due_at TEXT, notes TEXT NOT NULL)''');
    await customStatement(
        'CREATE INDEX history_bike_date ON history(bike_id, created_at)');
    await customStatement(
        'CREATE INDEX maintenance_due ON maintenance(due_at)');
  }
}
