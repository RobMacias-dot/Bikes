import 'package:bike_expert/app/app.dart';
import 'package:bike_expert/data/database/local_database.dart';
import 'package:bike_expert/data/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inicio en español permite invitado y persistencia del garaje',
      (tester) async {
    final db = LocalDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const BiciFirmeApp()));
    await tester.pumpAndSettle();
    expect(find.text('BiciFirme'), findsOneWidget);
    expect(find.text('Resolver un problema'), findsOneWidget);
    expect(find.text('Continuar sin registrar bicicleta'), findsOneWidget);
    await tester.tap(find.text('Administrar mis bicicletas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Añadir bicicleta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Mi MTB');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Guardar bicicleta'), 250,
        scrollable: find
            .descendant(
                of: find.byType(ListView).last,
                matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar bicicleta'));
    await tester.pumpAndSettle();
    expect(find.text('Mi MTB'), findsOneWidget);
    expect(find.text('Bicicleta activa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
