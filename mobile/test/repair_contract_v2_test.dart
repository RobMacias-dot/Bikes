import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/entities/bike.dart';
import 'package:bike_expert/domain/knowledge/repair_catalog.dart';
import 'package:bike_expert/domain/knowledge/repair_session.dart';
import 'package:bike_expert/domain/knowledge/technical_catalog.dart';
import 'package:bike_expert/data/database/bike_repository.dart';
import 'package:bike_expert/data/database/local_database.dart';
import 'package:drift/native.dart';
import 'knowledge_fixtures.dart';

void main() {
  RepairCatalog parse(Map<String, dynamic> j) => RepairCatalog.parse(j,
      TechnicalCatalog.parse(fixtureJson('components'), allowDevelopment: true),
      allowDevelopment: true);
  test('identify admite un vocabulario nuevo sin cambios de motor ni de perfil',
      () async {
    final j = fixtureJson('repairs');
    (j['identifications'] as List).add({
      'key': 'test_axle',
      'storageKey': 'knowledge.test_axle',
      'values': {
        'tube': 'Opción sintética A',
        'tubeless': 'Opción sintética B',
        'unknown': 'No sé'
      }
    });
    node(j, 'identify')['profileKey'] = 'test_axle';
    final catalog = parse(j),
        definition = catalog.identifications['test_axle']!;
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = BikeRepository(db);
    await repo.save(Bike(
        id: 'a', name: 'TEST', type: 'MTB', profile: {'notes': 'preservar'}));
    await repo.saveIdentification('a', definition, 'tube');
    final bike = (await repo.list()).single;
    expect(bike.notes, 'preservar');
    expect(bike.value('knowledge.test_axle'), 'Opción sintética A');
    final s = RepairSession(catalog.procedures.values.first,
        context: 'route',
        allowDevelopment: true,
        facts: factsFromBike(bike,
            identifications: catalog.identifications.values));
    s.choose('clear');
    expect(s.current.id, 'initial');
    await expectLater(repo.saveIdentification('a', definition, 'unknown'),
        throwsArgumentError);
    final guest = RepairSession(catalog.procedures.values.first,
        context: 'route', allowDevelopment: true);
    guest.choose('clear');
    expect(guest.current.kind, NodeKind.identify);
  });
  for (final field in ['risk', 'estimatedMinutes', 'safetyFocus']) {
    test('contrato exige $field', () {
      final j = fixtureJson('repairs');
      firstProcedure(j).remove(field);
      expect(() => parse(j), throwsFormatException);
    });
  }
  for (final time in [
    {'min': 0, 'max': 10},
    {'min': 10, 'max': 2},
    {'min': 1.5, 'max': 2},
    'quick'
  ]) {
    test('rechaza intervalo $time', () {
      final j = fixtureJson('repairs');
      firstProcedure(j)['estimatedMinutes'] = time;
      expect(() => parse(j), throwsFormatException);
    });
  }
  test('riesgo y tiempo se conservan como datos editoriales', () {
    final j = fixtureJson('repairs');
    firstProcedure(j)['risk'] = 'moderate';
    firstProcedure(j)['estimatedMinutes'] = {'min': 3, 'max': 8};
    final p = parse(j).procedures.values.first;
    expect(p.risk, 'moderate');
    expect(p.estimatedMinutes, (3, 8));
  });
  test('unresolved permanece interno y no crea un resultado visible', () {
    final s = RepairSession(fixtureBundle().repairs.procedures.values.first,
        context: 'route', allowDevelopment: true);
    s.choose('clear');
    s.choose('tube');
    s.choose('no');
    s.choose('unknown');
    expect(s.outcome, RepairOutcome.unresolved);
    expect(s.visibleOutcome, isNull);
    expect(VisibleRepairOutcome.values.map((v) => v.name),
        ['complete', 'temporary', 'stop']);
  });
  for (final flag in hardStopIds) {
    for (final target in ['complete', 'temporary', 'unresolved']) {
      test('safetyFocus no permite rebajar $flag a $target', () {
        final j = fixtureJson('repairs');
        firstProcedure(j)['safetyFocus'] = [];
        final c = (node(j, 'safety')['choices'] as List)
            .firstWhere((c) => c['hardStop'] == flag);
        c['next'] = target;
        expect(() => parse(j), throwsFormatException);
      });
    }
  }
}
