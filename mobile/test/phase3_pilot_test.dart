import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/entities/bike.dart';
import 'package:bike_expert/domain/knowledge/knowledge_bundle.dart';
import 'package:bike_expert/domain/knowledge/repair_catalog.dart';
import 'package:bike_expert/domain/knowledge/repair_search.dart';
import 'package:bike_expert/domain/knowledge/repair_session.dart';
import 'package:bike_expert/data/knowledge/repair_knowledge_repository.dart';

Map<String, dynamic> pilotJson(String name) =>
    jsonDecode(File('assets/knowledge/pilot/$name.json').readAsStringSync());
KnowledgeBundle pilotBundle([Map<String, dynamic>? repairs]) =>
    KnowledgeBundle.parse(pilotJson('manifest'), pilotJson('components'),
        repairs ?? pilotJson('repairs'),
        allowDevelopment: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bundle = pilotBundle();
  for (final field in [
    'toolIds',
    'consumableIds',
    'estimatedMinutes',
    'sourceIds'
  ]) {
    test('piloto exige $field explícito', () {
      final j = pilotJson('repairs');
      j['procedures'][0].remove(field);
      expect(() => pilotBundle(j), throwsFormatException);
    });
  }
  test('piloto rechaza fuente vacía y herramientas libres', () {
    final noSource = pilotJson('repairs');
    noSource['procedures'][0]['sourceIds'] = [];
    expect(() => pilotBundle(noSource), throwsFormatException);
    final freeTools = pilotJson('repairs');
    freeTools['procedures'][0]['tools'] = ['Herramienta sin ID'];
    expect(() => pilotBundle(freeTools), throwsFormatException);
  });
  test(
      'laboratorio carga piloto separado; approved y maestro permanecen intactos',
      () async {
    final loaded = await RepairKnowledgeRepository().load(development: true);
    expect(loaded.repairs.procedures.keys, bundle.repairs.procedures.keys);
    expect(
        (await RepairKnowledgeRepository().load()).repairs.procedures, isEmpty);
    expect(
        pilotJson('components'),
        jsonDecode(
            File('../knowledge/generated/development/0.1.0/components.json')
                .readAsStringSync()));
    expect(bundle.technical.edition.version, '0.1.0');
    expect(bundle.repairs.edition.status, 'development');
    expect(
        () => KnowledgeBundle.parse(pilotJson('manifest'),
            pilotJson('components'), pilotJson('repairs')),
        throwsFormatException);
  });
  test('recursos de reparación por ID no son relaciones componentConsumables',
      () {
    final p = bundle.repairs.procedures['dev.pilot.tube']!;
    expect(p.toolIds, contains('pump'));
    expect(p.tools, contains('Bomba con manómetro y conexión para tu válvula'));
    expect(p.consumableIds, ['tube']);
    expect(p.consumables.single, startsWith('Cámara nueva'));
    expect(bundle.technical.consumables.containsKey('tube'), isFalse);
  });
  for (final field in ['toolIds', 'consumableIds']) {
    for (final value in [
      ['missing'],
      ['pump', 'pump'],
      [1]
    ]) {
      test('rechaza $field inválido $value', () {
        final j = pilotJson('repairs');
        j['procedures'][1][field] = value;
        expect(() => pilotBundle(j), throwsFormatException);
      });
    }
  }
  for (final collection in ['tools', 'consumables']) {
    test('rechaza catálogo $collection duplicado', () {
      final j = pilotJson('repairs');
      j[collection].add(j[collection].first);
      expect(() => pilotBundle(j), throwsFormatException);
    });
  }
  test('no acepta consumible técnico como requerimiento implícito', () {
    final j = pilotJson('repairs');
    j['procedures'][1]
        ['consumableIds'] = [bundle.technical.consumables.keys.first];
    expect(() => pilotBundle(j), throwsFormatException);
  });

  for (final p in bundle.repairs.procedures.values) {
    test(
        '${p.id}: mismas respuestas mecánicas producen mismo resultado en ambos contextos',
        () {
      RepairSession replay(String context, List<String> path) {
        final s = RepairSession(p, context: context, allowDevelopment: true);
        for (final command in path) {
          if (command == '@step') {
            s.completeStep(checked: true);
          } else {
            s.choose(command);
          }
        }
        return s;
      }

      final results = <RepairOutcome>{};
      void compare(List<String> path) {
        final route = replay('route', path);
        final workshop = replay('workshop', path);
        expect(route.outcome, workshop.outcome, reason: '$path');
        expect(route.visibleOutcome, workshop.visibleOutcome, reason: '$path');
        if (route.outcome != null) {
          results.add(route.outcome!);
          return;
        }
        expect(route.current.kind, workshop.current.kind);
        if (route.current.kind == NodeKind.step) {
          compare([...path, '@step']);
        } else {
          expect(route.current.choices.map((c) => c.id),
              workshop.current.choices.map((c) => c.id));
          for (final choice in route.current.choices) {
            compare([...path, choice.id]);
          }
        }
      }

      compare([]);
      expect(results, {RepairOutcome.complete, RepairOutcome.stop});
    });
    test('${p.id}: acceso directo, síntomas y ficha completa', () {
      expect(RepairSearch(bundle.repairs).search(p.terms.first), contains(p));
      expect(p.estimatedMinutes, isNotNull);
      expect(p.sourceReferences, isNotEmpty);
      expect(
          p.nodes.values.any((n) => n.text.startsWith('¿Funcionó?')), isFalse);
      expect(
          p.nodes.values
              .where((n) => n.kind == NodeKind.outcome)
              .map((n) => n.outcome)
              .toSet(),
          {RepairOutcome.complete, RepairOutcome.stop});
    });
    for (final context in ['route', 'workshop']) {
      for (final active in [false, true]) {
        test(
            '${p.id}: todos los recorridos $context ${active ? 'bicicleta activa' : 'invitado'}',
            () {
          final definition = p.nodes['identify']!.identification!;
          final bike = active
              ? Bike(
                  id: 'pilot',
                  name: 'Bici piloto',
                  type: 'MTB',
                  profile: {definition.storageKey: definition.values['known']!})
              : null;
          final facts = factsFromBike(bike,
              identifications: bundle.repairs.identifications.values);
          RepairSession replay(List<String> path) {
            final s = RepairSession(p,
                context: context, facts: facts, allowDevelopment: true);
            for (final command in path) {
              if (command == '@step') {
                s.completeStep(checked: true);
              } else {
                s.choose(command);
              }
            }
            return s;
          }

          final edges = <String>{};
          final results = <VisibleRepairOutcome>{};
          void walk(List<String> path) {
            final s = replay(path);
            // Every critical flag remains irreversible from every reachable state,
            // including results reached before discovering the damage.
            for (final flag in hardStopIds) {
              final stopped = replay(path)..reportHardStop(flag);
              expect(stopped.visibleOutcome, VisibleRepairOutcome.stop);
              expect(stopped.hardStops, contains(flag));
              expect(stopped.canGoBack, isFalse);
              expect(stopped.goBack, throwsStateError);
              expect(() => stopped.choose('clear'), throwsStateError);
              expect(
                  () => stopped.completeStep(checked: true), throwsStateError);
            }
            if (s.visibleOutcome != null) {
              results.add(s.visibleOutcome!);
              return;
            }
            expect(() => s.choose('nonexistent'), throwsArgumentError);
            if (s.current.kind == NodeKind.step) {
              expect(() => s.completeStep(checked: false), throwsStateError);
              edges.add('${s.current.id}/@step');
              walk([...path, '@step']);
            } else {
              for (final c in s.current.choices) {
                edges.add('${s.current.id}/${c.id}');
                walk([...path, c.id]);
              }
            }
          }

          walk([]);
          expect(results,
              {VisibleRepairOutcome.stop, VisibleRepairOutcome.complete});
          for (final n in p.nodes.values) {
            if (n.kind == NodeKind.contextBranch ||
                n.kind == NodeKind.outcome ||
                (active &&
                    (n.kind == NodeKind.identify || n.id == 'identify_help')) ||
                n.id == (context == 'route' ? 'workshop' : 'route')) {
              continue;
            }
            if (n.kind == NodeKind.step) {
              expect(edges, contains('${n.id}/@step'));
            }
            for (final c in n.choices) {
              expect(edges, contains('${n.id}/${c.id}'));
            }
          }
        });
      }
    }
    test('${p.id}: perfil No sé conserva identificación y no salva alcance',
        () {
      final definition = p.nodes['identify']!.identification!;
      final bike = Bike(
          id: 'unknown',
          name: 'Sin identificar',
          type: 'MTB',
          profile: {definition.storageKey: 'No sé'});
      final s = RepairSession(p,
          context: 'route',
          allowDevelopment: true,
          facts: factsFromBike(bike,
              identifications: bundle.repairs.identifications.values));
      s.choose('clear');
      expect(s.current.id, 'identify');
      s.choose('unknown');
      expect(s.current.id, 'identify_help');
      expect(s.visibleOutcome, isNull);
      s.choose('yes');
      expect(s.current.id, 'scope');
    });
    for (final mutation in ['final', 'hard_stop']) {
      test('${p.id}: rechaza desvío inseguro $mutation', () {
        final j = pilotJson('repairs');
        final raw =
            (j['procedures'] as List).firstWhere((v) => v['id'] == p.id);
        final n = (raw['nodes'] as List).firstWhere(
            (v) => v['id'] == (mutation == 'final' ? 'worked' : 'safety'));
        n['choices'][0]['next'] = 'complete';
        expect(() => pilotBundle(j), throwsFormatException);
      });
    }
  }
}
