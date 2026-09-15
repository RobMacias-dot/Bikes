import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/knowledge/repair_session.dart';
import 'package:bike_expert/domain/knowledge/repair_catalog.dart';
import 'package:bike_expert/features/repairs/repair_visual.dart';
import 'package:bike_expert/data/knowledge/repair_knowledge_repository.dart';
import 'phase3_pilot_test.dart' show pilotBundle, pilotJson;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  test('la política de producción rechaza conocimiento development', () async {
    final repository =
        RepairKnowledgeRepository(developmentToolsEnabled: false);
    await expectLater(
        repository.load(development: true), throwsFormatException);
  });

  test('el producto solo expone complete, temporary y stop', () {
    expect(VisibleRepairOutcome.values.map((value) => value.name),
        ['complete', 'temporary', 'stop']);
    for (final procedure in pilotBundle().repairs.procedures.values) {
      expect(procedure.nodes.values.map((node) => node.outcome),
          isNot(contains(RepairOutcome.unresolved)));
      expect(procedure.nodes.values.map((node) => node.outcome),
          isNot(contains(RepairOutcome.temporary)),
          reason:
              '${procedure.id}: temporary no sustituye falta de diagnóstico');
      for (final node in procedure.nodes.values) {
        expect(node.choices.map((choice) => choice.next),
            isNot(contains('unresolved')));
      }
    }
  });

  setUpAll(() async {
    final config = File('.dart_tool/package_config.json').absolute;
    final packages =
        jsonDecode(await config.readAsString())['packages'] as List;
    final flutter = packages.firstWhere((p) => p['name'] == 'flutter');
    final root =
        Directory.fromUri(config.uri.resolve(flutter['rootUri'])).parent.parent;
    final font = File(
        '${root.path}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
    await loader.load();
  });
  test('cadena: fallo no crítico abre causa y reintento con prueba final', () {
    final s = RepairSession(
        pilotBundle().repairs.procedures['dev.pilot.chain']!,
        context: 'route',
        allowDevelopment: true);
    s.choose('clear');
    s.choose('known');
    s.choose('yes');
    s.choose('yes');
    s.completeStep(checked: true);
    s.choose('yes');
    s.completeStep(checked: true);
    s.completeStep(checked: true);
    s.choose('no');
    expect(s.current.id, 'next_cause');
    expect(s.visibleOutcome, isNull);
    expect(s.hardStops, isEmpty);
    s.choose('yes');
    s.choose('yes');
    s.completeStep(checked: true);
    s.choose('yes');
    expect(s.current.kind, NodeKind.finalCheck);
    s.choose('pass');
    expect(s.outcome, RepairOutcome.complete);
    s.reportHardStop('critical_part_broken');
    expect(s.visibleOutcome, VisibleRepairOutcome.stop);
    expect(s.goBack, throwsStateError);
  });
  test('referencias visuales inválidas se rechazan', () {
    final raw = pilotJson('repairs');
    raw['procedures'][0]['nodes'][0]['visualIds'] = ['https://external/image'];
    expect(() => pilotBundle(raw), throwsFormatException);
  });
  for (final id in RepairVisual.captions.keys) {
    testWidgets('diagrama offline $id legible y expandible', (tester) async {
      await tester.pumpWidget(MaterialApp(
          theme: ThemeData(fontFamily: 'Roboto'),
          home: Scaffold(
              body: ListView(
            children: [RepairVisual(id: id)],
          ))));
      await tester.tap(find.text('Ver ayuda visual offline'));
      await tester.pumpAndSettle();
      expect(find.text(RepairVisual.captions[id]!), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectLater(
          find.byType(Scaffold), matchesGoldenFile('goldens/$id.png'));
    });
  }
}
