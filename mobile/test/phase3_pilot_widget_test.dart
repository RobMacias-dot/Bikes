import 'package:bike_expert/data/knowledge/repair_knowledge_repository.dart';

import 'package:bike_expert/data/providers.dart';

import 'package:bike_expert/domain/entities/bike.dart';

import 'package:bike_expert/domain/knowledge/repair_catalog.dart';

import 'package:bike_expert/features/repairs/problems_page.dart';

import 'package:bike_expert/features/repairs/repair_page.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_test/flutter_test.dart';

import 'phase3_pilot_test.dart' show pilotBundle;



void main() {

  final bundle = pilotBundle();

  final symptoms = {

    'chain': 'Pedales giran sin avanzar',

    'tube': 'Llanta pierde aire',

    'index': 'Cambio no entra',

    'disc': 'Disco roza'

  };

  for (final p in bundle.repairs.procedures.values) {

    for (final active in [false, true]) {

      testWidgets(

          '${p.id}: UI completa ${active ? 'activa y síntomas' : 'invitado directo'}',

          (tester) async {

        tester.view.physicalSize = const Size(1200, 2200);

        tester.view.devicePixelRatio = 1;

        addTearDown(tester.view.resetPhysicalSize);

        addTearDown(tester.view.resetDevicePixelRatio);

        final definition = p.nodes['identify']!.identification!;

        final bike = Bike(

            id: 'pilot',

            name: 'Bici activa piloto',

            type: 'MTB',

            profile: {definition.storageKey: definition.values['known']!});

        await tester.pumpWidget(ProviderScope(

            overrides: [

              repairKnowledgeProvider(true).overrideWith((ref) async => bundle),

              bikesProvider.overrideWith((ref) async => [bike]),

              activeBikeIdProvider.overrideWith((ref) async => bike.id),

            ],

            child: MaterialApp(

                home: ProblemsPage(useBike: active, development: true))));

        await tester.pumpAndSettle();

        Future<void> tap(Finder target) async {

          await tester.scrollUntilVisible(target, 350,

              scrollable: find

                  .descendant(

                      of: find.byType(ListView).last,

                      matching: find.byType(Scrollable))

                  .first);

          await tester.ensureVisible(target);

          await tester.tap(target);

          await tester.pumpAndSettle();

        }



        if (active) {

          await tap(find.text('No sé qué tiene'));

          await tap(find.text(symptoms[p.id.split('.').last]!));

        } else {

          await tester.enterText(find.byType(TextField), p.terms.first);

          await tester.pumpAndSettle();

        }

        await tap(find.text(active ? 'En casa / taller' : 'Estoy en ruta'));

        await tap(find.text(p.title));

        expect(find.byType(RepairPage), findsOneWidget);

        expect(

            find.textContaining(

                active ? 'Bici activa piloto ·' : 'Modo invitado ·'),

            findsOneWidget);

        await tap(find.text('Qué ocurre y qué necesitas'));

        expect(find.text('Consumibles'), findsOneWidget);

        expect(

            find.textContaining('${p.estimatedMinutes!.$1}–'), findsOneWidget);

        for (final label in [...p.tools, ...p.consumables]) {

          expect(find.textContaining(label), findsOneWidget);

        }

        await tap(find.text('Qué ocurre y qué necesitas'));

        await tap(find.text('No observo estas señales'));

        if (!active) {

          await tap(find.text(definition.values['known']!));

        }

        // Drive visible buttons, not a shadow engine. Exercise the slow-index branch.

        for (var count = 0; count < 30; count++) {

          final list = tester.widget<ListView>(find.byType(ListView).last);

          final node = p.nodes[(list.key! as ValueKey<String>).value]!;

          if (node.kind == NodeKind.outcome) {

            break;

          }

          if (node.kind == NodeKind.step) {

            await tap(find.text('Paso hecho · continuar'));

          } else {

            final c = node.choices

                .firstWhere((c) => ['yes', 'slow', 'pass'].contains(c.id));

            await tap(find.text(c.label));

          }

        }

        expect(find.text('Reparación completa'), findsOneWidget);

        expect(find.text('Paso anterior'), findsNothing);

        expect(find.textContaining('unresolved'), findsNothing);

        expect(tester.takeException(), isNull);

      });

    }

  }

}
