import 'package:bike_expert/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de inicio de Bike Expert', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BikeExpertApp()));
    await tester.pumpAndSettle();

    expect(find.text('Bike Expert'), findsOneWidget);
    expect(find.text('Iniciar diagnóstico'), findsOneWidget);
    expect(find.text('Mi garaje'), findsOneWidget);
  });
}
