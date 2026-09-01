enum RiskLevel { low, medium, high, critical }

enum AffectedSystem {
  wheels,
  brakes,
  drivetrain,
  steering,
  suspension,
  frame,
  electric
}

enum SessionStatus { inProgress, completed, cancelled }

extension RiskPresentation on RiskLevel {
  String get label => switch (this) {
        RiskLevel.low => 'BAJO',
        RiskLevel.medium => 'MEDIO',
        RiskLevel.high => 'ALTO',
        RiskLevel.critical => 'CRÍTICO'
      };
  bool get stopUse => this == RiskLevel.critical;
  static RiskLevel parse(String value) => RiskLevel.values
      .firstWhere((e) => e.name == value, orElse: () => RiskLevel.medium);
}

AffectedSystem systemFromId(String id) => switch (id) {
      'ruedas' => AffectedSystem.wheels,
      'frenos' => AffectedSystem.brakes,
      'transmision' => AffectedSystem.drivetrain,
      'direccion' => AffectedSystem.steering,
      'suspension' => AffectedSystem.suspension,
      'cuadro' => AffectedSystem.frame,
      _ => AffectedSystem.electric,
    };

class DiagnosticScenario {
  const DiagnosticScenario(
      {required this.id,
      required this.system,
      required this.label,
      required this.diagnosis,
      required this.action,
      required this.risk,
      required this.complexity,
      this.bayes,
      this.manualFact});
  final String id, label, diagnosis, action;
  final AffectedSystem system;
  final RiskLevel risk;
  final int complexity;
  final String? bayes, manualFact;
  factory DiagnosticScenario.fromJson(Map<String, dynamic> j) =>
      DiagnosticScenario(
          id: j['id'] as String,
          system: systemFromId(j['system'] as String),
          label: j['label'] as String,
          diagnosis: j['diagnosis'] as String,
          action: j['action'] as String,
          risk: RiskPresentation.parse(j['risk'] as String),
          complexity: j['complexity'] as int,
          bayes: j['bayes'] as String?,
          manualFact: j['manualFact'] as String?);
}

class DiagnosticResult {
  const DiagnosticResult(
      {required this.scenario,
      required this.risk,
      required this.redFlag,
      required this.ruleTrace,
      required this.compatibility});
  final DiagnosticScenario scenario;
  final RiskLevel risk;
  final String? redFlag;
  final List<String> ruleTrace, compatibility;
  bool get stopUse => risk.stopUse;
}

class Bike {
  const Bike(
      {required this.id,
      required this.name,
      required this.type,
      this.brand = '',
      this.model = '',
      this.year,
      this.notes = ''});
  final String id, name, type, brand, model, notes;
  final int? year;
}

abstract interface class DiagnosticExplanationService {
  Future<String> explain(DiagnosticResult result);
}
