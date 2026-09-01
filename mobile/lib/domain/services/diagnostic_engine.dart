import '../entities/diagnostic.dart';

class DiagnosticEngine {
  const DiagnosticEngine();
  DiagnosticResult diagnose(
      {required DiagnosticScenario scenario,
      String? redFlag,
      required String brand,
      String model = ''}) {
    // El triaje se aplica antes y jamás puede reducirse en capas posteriores.
    final risk = redFlag == null ? scenario.risk : RiskLevel.critical;
    final trace = <String>[
      'Regla activada: ${scenario.system.name}::${scenario.id}',
      if (redFlag != null) 'Triaje crítico: $redFlag'
    ];
    final notes = <String>[
      'Marca: ${brand.isEmpty ? 'genérica/no identificada' : brand}${model.isEmpty ? '' : ' — $model'}',
      'Confirma modelo, estándar, serie y manual; la marca por sí sola no prueba compatibilidad.',
    ];
    return DiagnosticResult(
        scenario: scenario,
        risk: risk,
        redFlag: redFlag,
        ruleTrace: trace,
        compatibility: notes);
  }
}

class BayesAssessment {
  const BayesAssessment(this.prior, this.posterior, this.hypothesis);
  final double prior, posterior;
  final String hypothesis;
}

BayesAssessment updateBayes(String model, bool evidence) {
  final config = switch (model) {
    'reincidencia' => (
        .30,
        evidence ? 3.2 : .45,
        'causa persistente de pérdida de aire'
      ),
    'direccion' => (
        .25,
        evidence ? 3.0 : .40,
        'rodamientos/superficies de dirección dañados'
      ),
    _ => (.25, evidence ? 2.8 : .50, 'eje/rodamiento requiere servicio'),
  };
  final odds = config.$1 / (1 - config.$1) * config.$2;
  return BayesAssessment(config.$1, odds / (1 + odds), config.$3);
}

class FuzzyAssessment {
  const FuzzyAssessment(this.score, this.label);
  final double score;
  final String label;
}

FuzzyAssessment mamdani(
    {required double experience, required int tools, required int complexity}) {
  if (experience < 0 ||
      experience > 10 ||
      tools < 0 ||
      tools > 3 ||
      complexity < 0 ||
      complexity > 3) {
    throw ArgumentError('Entradas fuera de rango');
  }
  // Aproximación determinista del conjunto Mamdani del prototipo; crítica siempre difícil.
  if (complexity == 3) {
    return const FuzzyAssessment(20, 'DIFÍCIL');
  }
  final score = (experience * 6 + tools * 13 - complexity * 16 + 25)
      .clamp(0, 100)
      .toDouble();
  return FuzzyAssessment(
      score,
      score < 40
          ? 'DIFÍCIL'
          : score < 70
              ? 'NORMAL'
              : 'FÁCIL');
}

class BackwardChain {
  (bool, List<String>) proveLimitedManual(Set<String> facts) {
    final trace = <String>[];
    final ok = facts.contains('detenida') &&
        facts.contains('sin_dano') &&
        (facts.contains('cadena_salida') || facts.contains('valvula_floja'));
    trace.add('sin_herramientas REQUIERE manual_limitada');
    trace.add(
        'manual_limitada REQUIERE escenario permitido Y detenida Y sin_dano');
    trace.add(ok
        ? 'DEMOSTRADO: intervención manual limitada'
        : 'NO DEMOSTRADO: no autoriza reparación');
    return (ok, trace);
  }
}
