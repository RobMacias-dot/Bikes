import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/entities/diagnostic.dart';
import 'package:bike_expert/domain/services/diagnostic_engine.dart';

void main() {
  const scenario = DiagnosticScenario(
      id: 'sin_freno',
      system: AffectedSystem.brakes,
      label: 'Sin freno',
      diagnosis: 'Falla',
      action: 'No usar',
      risk: RiskLevel.critical,
      complexity: 3);
  test('una bandera roja eleva a crítico', () {
    final r = const DiagnosticEngine()
        .diagnose(scenario: scenario, redFlag: 'freno', brand: 'Shimano');
    expect(r.risk, RiskLevel.critical);
    expect(r.stopUse, isTrue);
  });
  test('Bayes aumenta con evidencia positiva', () {
    expect(updateBayes('eje', true).posterior,
        greaterThan(updateBayes('eje', false).posterior));
  });
  test('Mamdani crítico es difícil', () {
    expect(mamdani(experience: 10, tools: 3, complexity: 3).label, 'DIFÍCIL');
  });
  test('backward chaining limita intervención', () {
    expect(
        BackwardChain()
            .proveLimitedManual({'cadena_salida', 'detenida', 'sin_dano'}).$1,
        isTrue);
    expect(BackwardChain().proveLimitedManual({'detenida'}).$1, isFalse);
  });
}
