import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/data/database/local_database.dart';
import 'package:bike_expert/data/database/bike_repository.dart';
import 'package:bike_expert/domain/entities/bike.dart';

void main() {
  test('bicicletas, perfil y selección sobreviven al cierre', () async {
    final dir = await Directory.systemTemp.createTemp('bicifirme-test-');
    final file = File('${dir.path}/test.sqlite');
    var db = LocalDatabase(NativeDatabase(file));
    try {
      var repo = BikeRepository(db);
      await repo.save(Bike(
          id: 'a',
          name: 'Mi MTB',
          type: 'MTB',
          profile: {'transmission': '1x11', 'tires': 'No sé'}));
      await repo.save(Bike(id: 'b', name: 'Mi ruta', type: 'Ruta'));
      await repo.setPreference('activeBike', 'b');
      await db.close();
      db = LocalDatabase(NativeDatabase(file));
      repo = BikeRepository(db);
      expect((await repo.list()).length, 2);
      expect((await repo.list()).first.value('transmission'), '1x11');
      expect(await repo.preference('defaultBike'), 'a');
      expect(await repo.preference('activeBike'), 'b');
      await repo.save(Bike(id: 'a', name: 'MTB actualizada', type: 'MTB'));
      expect((await repo.list()).length, 2);
      await expectLater(
          repo.setPreference('activeBike', 'inexistente'), throwsArgumentError);
      await repo.delete('b');
      expect(await repo.preference('activeBike'), 'a');
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });
  test('migración 1 → 2 conserva las bicicletas', () async {
    final dir = await Directory.systemTemp.createTemp('bicifirme-migration-');
    final file = File('${dir.path}/test.sqlite');
    final old = _VersionOne(NativeDatabase(file));
    await old
        .customStatement("INSERT INTO bikes VALUES('a','Anterior','MTB','{}')");
    await old.close();
    final db = LocalDatabase(NativeDatabase(file));
    try {
      expect((await BikeRepository(db).list()).single.name, 'Anterior');
      await BikeRepository(db).setPreference('activeBike', 'a');
      await expectLater(
          db.customStatement(
              "INSERT INTO maintenance VALUES('x','missing','Frenos',NULL,NULL,'')"),
          throwsA(anything));
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });
  test('rechaza perfil sin nombre y tipos fuera de V1', () {
    expect(() => Bike(id: 'a', name: ' ', type: 'MTB'), throwsFormatException);
    expect(() => Bike(id: 'a', name: 'Bici', type: 'e-bike'),
        throwsFormatException);
  });
}

class _VersionOne extends LocalDatabase {
  _VersionOne(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (_) async {
        await customStatement(
            'CREATE TABLE bikes (id TEXT PRIMARY KEY, name TEXT NOT NULL, type TEXT NOT NULL, profile TEXT NOT NULL)');
      });
}
