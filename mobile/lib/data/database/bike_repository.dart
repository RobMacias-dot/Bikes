import 'package:drift/drift.dart';
import '../../domain/entities/bike.dart';
import '../../domain/knowledge/repair_catalog.dart';
import 'local_database.dart';

class BikeRepository {
  BikeRepository(this.db);
  final LocalDatabase db;
  Future<void> saveIdentification(
      String id, Identification definition, String value) async {
    if (value == 'unknown' || !definition.values.containsKey(value)) {
      throw ArgumentError('Respuesta fuera del vocabulario editorial');
    }
    return _saveFact(id, definition.storageKey, definition.values[value]!);
  }

  Future<void> saveProfileFact(String id, String key, String value) async {
    const allowed = {
      'tires': ['Con cámara', 'Tubeless'],
      'brakes': [
        'De rin con cable',
        'Disco mecánico',
        'Disco hidráulico',
        'Contrapedal / tambor'
      ],
    };
    if (!(allowed[key]?.contains(value) ?? false)) {
      throw ArgumentError('Dato de perfil no admitido');
    }
    return _saveFact(id, key, value);
  }

  Future<void> _saveFact(String id, String key, String value) async {
    await db.transaction(() async {
      final row = await db.customSelect('SELECT * FROM bikes WHERE id=?',
          variables: [Variable(id)]).getSingleOrNull();
      if (row == null) throw StateError('La bicicleta ya no existe');
      final current = Bike.fromRow(row.data);
      await save(Bike(
          id: current.id,
          name: current.name,
          type: current.type,
          profile: {...current.profile, key: value}));
    });
  }

  Future<List<Bike>> list() async => (await db
          .customSelect('SELECT * FROM bikes ORDER BY name COLLATE NOCASE, id')
          .get())
      .map((row) => Bike.fromRow(row.data))
      .toList();
  Future<void> save(Bike bike) async {
    final row = bike.toRow();
    await db.transaction(() async {
      await db.customStatement(
          '''INSERT INTO bikes(id,name,type,profile) VALUES(?,?,?,?)
        ON CONFLICT(id) DO UPDATE SET name=excluded.name,type=excluded.type,profile=excluded.profile''',
          [bike.id, bike.name, bike.type, row['profile']]);
      if ((await preference('defaultBike') ?? '').isEmpty) {
        await setPreference('defaultBike', bike.id);
        await setPreference('activeBike', bike.id);
      }
    });
  }

  Future<String?> preference(String key) async {
    final row = await db.customSelect(
        'SELECT value FROM preferences WHERE key=?',
        variables: [Variable(key)]).getSingleOrNull();
    return row?.read<String>('value');
  }

  Future<void> setPreference(String key, String value) async {
    if ((key == 'activeBike' || key == 'defaultBike') && value.isNotEmpty) {
      final bike = await db.customSelect('SELECT id FROM bikes WHERE id=?',
          variables: [Variable(value)]).getSingleOrNull();
      if (bike == null) throw ArgumentError('La bicicleta no existe');
    }
    await db.customStatement('''INSERT INTO preferences(key,value) VALUES(?,?)
      ON CONFLICT(key) DO UPDATE SET value=excluded.value''', [key, value]);
  }

  Future<void> delete(String id) => db.transaction(() async {
        await db.customStatement('DELETE FROM bikes WHERE id=?', [id]);
        for (final key in ['activeBike', 'defaultBike']) {
          if (await preference(key) == id) {
            final remaining = await list();
            await setPreference(
                key, remaining.isEmpty ? '' : remaining.first.id);
          }
        }
      });
}
