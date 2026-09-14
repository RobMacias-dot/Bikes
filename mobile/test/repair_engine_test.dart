import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/entities/bike.dart';
import 'package:bike_expert/domain/knowledge/repair_search.dart';
import 'package:bike_expert/domain/knowledge/repair_catalog.dart';
import 'package:bike_expert/domain/knowledge/repair_session.dart';
import 'package:bike_expert/domain/knowledge/technical_catalog.dart';
import 'knowledge_fixtures.dart';

void main() {
  test(
      'filtros conservan opciones para invitado y respetan bicicleta y contexto conocidos',
      () {
    final j = fixtureJson('repairs');
    firstProcedure(j)['bikeTypes'] = ['Fixie / single speed'];
    firstProcedure(j)['contexts'] = ['workshop'];
    final catalog = RepairCatalog.parse(
        j,
        TechnicalCatalog.parse(fixtureJson('components'),
            allowDevelopment: true),
        allowDevelopment: true);
    final search = RepairSearch(catalog);
    expect(search.search('cadena').any((p) => p.id == 'dev.chain'), isTrue);
    expect(
        search.search('cadena', bike: Bike(id: 'a', name: 'MTB', type: 'MTB')),
        isEmpty);
    expect(search.search('cadena', context: 'route'), isEmpty);
    expect(search.search('cadena', context: 'workshop').single.id, 'dev.chain');
  });
  test('el motor rechaza fixtures salvo autorización explícita de desarrollo',
      () {
    expect(
        () => RepairSession(fixtureBundle().repairs.procedures['dev.chain']!,
            context: 'route'),
        throwsStateError);
  });
  test('el mismo procedimiento selecciona un paso distinto para ruta y taller',
      () {
    final p = fixtureBundle().repairs.procedures['dev.chain']!;
    for (final context in ['route', 'workshop']) {
      final s = RepairSession(p,
          context: context, allowDevelopment: true, facts: {'tires': 'tube'});
      s.choose('clear');
      s.choose('yes');
      expect(s.current.id, context == 'route' ? 'action' : 'workshop_action');
    }
  });
  test('corregir una identificación a No sé elimina la respuesta previa', () {
    final s = RepairSession(fixtureBundle().repairs.procedures['dev.chain']!,
        context: 'route', allowDevelopment: true);
    s.choose('clear');
    s.choose('tube');
    s.goBack();
    s.choose('unknown');
    expect(s.facts.containsKey('tires'), isFalse);
  });
  RepairSession session({Map<String, String> facts = const {}}) =>
      RepairSession(fixtureBundle().repairs.procedures['dev.chain']!,
          context: 'route', facts: facts, allowDevelopment: true);
  void toAction(RepairSession s) {
    s.choose('clear');
    if (s.current.id == 'identify') s.choose('tube');
    s.choose('yes');
  }

  void complete(RepairSession s) {
    toAction(s);
    s.completeStep(checked: true);
    s.choose('yes');
    s.choose('pass');
  }

  test('pasos requieren confirmación y complete exige prueba final', () {
    final s = session();
    toAction(s);
    expect(() => s.completeStep(checked: false), throwsStateError);
    expect(s.outcome, isNull);
    s.completeStep(checked: true);
    s.choose('yes');
    expect(s.outcome, isNull);
    s.choose('pass');
    expect(s.outcome, RepairOutcome.complete);
  });
  test('fallo conduce a siguiente causa y temporal conserva restricciones', () {
    final s = session();
    toAction(s);
    s.completeStep(checked: true);
    s.choose('no');
    expect(s.current.id, 'alternative');
    s.choose('temporary');
    expect(s.outcome, RepairOutcome.temporary);
    expect(s.current.restrictions, isNotEmpty);
  });
  test('fallo de prueba final no autoriza complete', () {
    final s = session();
    toAction(s);
    s.completeStep(checked: true);
    s.choose('yes');
    s.choose('fail');
    expect(s.outcome, RepairOutcome.unresolved);
  });
  for (final flag in hardStopIds) {
    for (final previous in [
      'initial',
      'step',
      'complete',
      'temporary',
      'unresolved'
    ]) {
      test('$flag nunca se rebaja desde $previous', () {
        final s = session();
        if (previous == 'step') toAction(s);
        if (previous == 'complete') complete(s);
        if (previous == 'temporary' || previous == 'unresolved') {
          toAction(s);
          s.completeStep(checked: true);
          s.choose('no');
          s.choose(previous == 'temporary' ? 'temporary' : 'unknown');
        }
        s.reportHardStop(flag);
        expect(s.outcome, RepairOutcome.stop);
        expect(s.canGoBack, isFalse);
        expect(() => s.goBack(), throwsStateError);
        expect(() => s.choose('clear'), throwsStateError);
        expect(() => s.completeStep(checked: true), throwsStateError);
        expect(() => s.hardStops.clear(), throwsUnsupportedError);
        expect(s.outcome, RepairOutcome.stop);
      });
    }
  }
  test('la rama de seguridad bloquea el flujo', () {
    final s = session();
    s.choose('braking');
    expect(s.outcome, RepairOutcome.stop);
  });
  test('perfil conocido reduce preguntas, desconocido e invitado no se suponen',
      () {
    final known = session(facts: {'tires': 'tube'});
    known.choose('clear');
    expect(known.current.id, 'initial');
    final unknown = session(facts: {'tires': 'unknown'});
    unknown.choose('clear');
    expect(unknown.current.id, 'identify');
    final guest = session();
    guest.choose('clear');
    expect(guest.current.id, 'identify');
    expect(
        factsFromBike(
            Bike(
                id: 'a',
                name: 'Bici',
                type: 'MTB',
                profile: {'transmission': '1x12'}),
            identifications:
                fixtureBundle().repairs.identifications.values)['tires'],
        'unknown');
  });
  test('retroceder no conserva una prueba final que no fue aprobada', () {
    final s = session();
    toAction(s);
    s.completeStep(checked: true);
    s.choose('yes');
    s.goBack();
    expect(s.outcome, isNull);
    expect(s.current.id, 'worked');
    s.choose('no');
    s.choose('unknown');
    expect(s.outcome, RepairOutcome.unresolved);
  });
  test('la búsqueda entiende acentos, sinónimos y lenguaje cotidiano', () {
    final search = RepairSearch(fixtureBundle().repairs);
    expect(search.search('cadena SALTA').first.id, 'dev.chain');
    expect(search.search('neumático pinchado').first.id, 'dev.tire');
    expect(search.search('rueda descentrada').first.id, 'dev.wheel');
    expect(search.search('freno suelto').first.id, 'dev.brake');
    expect(search.search('No frena').first.id, 'dev.brake');
    expect(search.search('zzzz'), isEmpty);
    expect(search.search('', category: 'brakes').single.id, 'dev.brake');
  });
}
