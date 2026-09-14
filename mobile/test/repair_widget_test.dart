import 'package:bike_expert/data/database/local_database.dart';
import 'package:bike_expert/data/knowledge/repair_knowledge_repository.dart';
import 'package:bike_expert/data/providers.dart';
import 'package:bike_expert/domain/entities/bike.dart';
import 'package:bike_expert/features/repairs/problems_page.dart';
import 'package:bike_expert/features/repairs/repair_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'knowledge_fixtures.dart';

void main() {
  testWidgets('entrada directa de invitado, búsqueda y bloqueo visible',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
        overrides: [
          repairKnowledgeProvider(true)
              .overrideWith((ref) async => fixtureBundle())
        ],
        child: const MaterialApp(
            home: ProblemsPage(useBike: false, development: true))));
    await tester.pumpAndSettle();
    expect(find.textContaining('LABORATORIO'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'cadena salta');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Estoy en ruta'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('[PRUEBA] La cadena brinca al pedalear'), 200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('[PRUEBA] La cadena brinca al pedalear'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('Simular pérdida de frenado'), 200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simular pérdida de frenado'));
    await tester.pumpAndSettle();
    expect(find.text('Simulación: No continuar circulando'), findsOneWidget);
    expect(find.text('Paso anterior'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('perfil conocido evita repetir identificación en el flujo',
      (tester) async {
    final p = fixtureBundle().repairs.procedures['dev.chain']!;
    await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
            home: RepairPage(
                procedure: p,
                contextId: 'workshop',
                bike: Bike(
                    id: 'a',
                    name: 'MTB',
                    type: 'MTB',
                    profile: {'tires': 'Tubeless'})))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('En esta prueba no hay banderas rojas'), 200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('En esta prueba no hay banderas rojas'));
    await tester.pumpAndSettle();
    expect(find.text('Comprobación simulada: ¿aparece la primera causa?'),
        findsOneWidget);
    expect(find.text('Dato de prueba: ¿tu llanta tiene cámara o es tubeless?'),
        findsNothing);
  });
  testWidgets('catálogo aprobado vacío no vuelve al diagnóstico heredado',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ProblemsPage(useBike: false))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.textContaining('Todavía no hay guías'), 200,
        scrollable: find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first);
    expect(find.textContaining('Todavía no hay guías'), findsOneWidget);
    expect(find.textContaining('[PRUEBA]'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
