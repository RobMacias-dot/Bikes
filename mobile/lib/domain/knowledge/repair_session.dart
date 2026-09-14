import '../entities/bike.dart';
import 'repair_catalog.dart';

Map<String, String> factsFromBike(Bike? bike,
    {Iterable<Identification> identifications = const []}) {
  if (bike == null) return const {};
  return {
    for (final definition in identifications)
      definition.key: definition.values.entries
              .where((e) => e.value == bike.value(definition.storageKey))
              .firstOrNull
              ?.key ??
          'unknown'
  };
}

/// The product exposes exactly three terminal results.
enum VisibleRepairOutcome { complete, temporary, stop }

class RepairSession {
  RepairSession(this.procedure,
      {required this.context,
      Map<String, String> facts = const {},
      bool allowDevelopment = false})
      : _facts = Map.of(facts),
        _current = procedure.entry {
    if (procedure.development && !allowDevelopment) {
      throw StateError('Fixture no habilitado para esta sesión');
    }
    if (!procedure.contexts.contains(context)) {
      throw ArgumentError('Contexto no aplicable');
    }
  }
  final RepairProcedure procedure;
  final String context;
  final Map<String, String> _facts;
  final Set<String> _hardStops = {};
  final List<(String, bool)> _history = [];
  String _current;
  bool _finalPassed = false;
  RepairNode get current => procedure.nodes[_current]!;
  Set<String> get hardStops => Set.unmodifiable(_hardStops);
  Map<String, String> get facts => Map.unmodifiable(_facts);
  bool get canGoBack =>
      _history.isNotEmpty &&
      _hardStops.isEmpty &&
      current.kind != NodeKind.outcome;
  RepairOutcome? get outcome {
    if (_hardStops.isNotEmpty) return RepairOutcome.stop;
    if (current.outcome == RepairOutcome.complete && !_finalPassed) {
      return RepairOutcome.unresolved;
    }
    return current.outcome;
  }

  VisibleRepairOutcome? get visibleOutcome => switch (outcome) {
        null => null,
        RepairOutcome.complete => VisibleRepairOutcome.complete,
        RepairOutcome.temporary => VisibleRepairOutcome.temporary,
        RepairOutcome.stop => VisibleRepairOutcome.stop,
        RepairOutcome.unresolved => null,
      };

  void choose(String id) {
    if (_hardStops.isNotEmpty || current.kind == NodeKind.outcome) {
      throw StateError('La sesión ya terminó');
    }
    final choice = current.choices.where((c) => c.id == id).firstOrNull;
    if (choice == null) {
      throw ArgumentError('Respuesta no válida para este paso');
    }
    if (choice.hardStop != null) {
      reportHardStop(choice.hardStop!);
      return;
    }
    final old = (_current, _finalPassed);
    if (current.kind == NodeKind.identify) {
      if (choice.profileValue == 'unknown') {
        _facts.remove(current.profileKey!);
      } else {
        _facts[current.profileKey!] = choice.profileValue!;
      }
    }
    _finalPassed =
        current.kind == NodeKind.finalCheck && choice.verdict == 'pass';
    _history.add(old);
    _current = choice.next;
    _useKnownFacts();
  }

  void completeStep({required bool checked}) {
    if (!checked || current.kind != NodeKind.step || _hardStops.isNotEmpty) {
      throw StateError('Confirma el paso antes de continuar');
    }
    _history.add((_current, _finalPassed));
    _finalPassed = false;
    _current = current.next!;
    _useKnownFacts();
  }

  void goBack() {
    if (!canGoBack) throw StateError('No se puede regresar');
    final previous = _history.removeLast();
    _current = previous.$1;
    _finalPassed = previous.$2;
  }

  void reportHardStop(String id) {
    if (!hardStopIds.contains(id)) {
      throw ArgumentError('Bandera roja desconocida');
    }
    _hardStops.add(id);
    _finalPassed = false;
    final safety = procedure.nodes[procedure.entry]!;
    _current = safety.choices.firstWhere((c) => c.hardStop == id).next;
  }

  void _useKnownFacts() {
    while (current.kind == NodeKind.identify ||
        current.kind == NodeKind.contextBranch) {
      if (current.kind == NodeKind.contextBranch) {
        _current = current.routes[context]!;
        continue;
      }
      final value = _facts[current.profileKey];
      if (value == null || value == 'unknown') return;
      final choice =
          current.choices.where((c) => c.profileValue == value).firstOrNull;
      if (choice == null) return;
      _current = choice.next;
    }
  }
}
