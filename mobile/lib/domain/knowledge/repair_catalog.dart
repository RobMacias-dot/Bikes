import 'technical_catalog.dart';
import 'validation.dart';

const hardStopIds = [
  'structural_damage',
  'braking_loss',
  'steering_damage',
  'critical_part_broken'
];

/// Vocabulary supplied by the repair edition, independent of bicycle categories.
class Identification {
  Identification(Map<String, dynamic> j) {
    keys(j, 'identification', ['key', 'storageKey', 'values']);
    key = identifier(j['key'], 'identification.key');
    storageKey = identifier(j['storageKey'], 'identification.storageKey');
    // Existing garage fields are read-only aliases; new facts use their own namespace.
    if (!storageKey.startsWith('knowledge.') &&
        !['tires', 'brakes'].contains(storageKey)) {
      throw KnowledgeError(key, 'storageKey debe usar knowledge.*');
    }
    final input = object(j['values'], key);
    if (!input.containsKey('unknown') || input.length < 2) {
      throw KnowledgeError(key, 'vocabulario incompleto');
    }
    values = Map.unmodifiable({
      for (final entry in input.entries)
        identifier(entry.key, key): textValue(entry.value, key)
    });
    if (values.values.toSet().length != values.length) {
      throw KnowledgeError(key, 'etiquetas ambiguas');
    }
  }
  late final String key, storageKey;
  late final Map<String, String> values;
}

enum NodeKind {
  safetyCheck,
  identify,
  contextBranch,
  check,
  step,
  finalCheck,
  outcome
}

enum RepairOutcome { complete, temporary, stop, unresolved }

class RepairCatalog {
  RepairCatalog._(this.edition, this.technicalVersion, this.procedures,
      this.synonyms, this.sources, this.identifications);
  final Edition edition;
  final Map<String, SourceReference> sources;
  final String technicalVersion;
  final Map<String, RepairProcedure> procedures;
  final List<List<String>> synonyms;
  final Map<String, Identification> identifications;
  factory RepairCatalog.parse(
      Map<String, dynamic> j, TechnicalCatalog technical,
      {bool allowDevelopment = false}) {
    keys(j, 'repairs', [
      'kind',
      'schemaVersion',
      'contentVersion',
      'status',
      'technicalVersion',
      'locale',
      'sources',
      'synonyms',
      'procedures',
      'identifications'
    ], [
      'tools',
      'consumables'
    ]);
    final edition = Edition(j, 'repairs', allowDevelopment: allowDevelopment);
    if (!edition.development && technical.edition.development) {
      throw KnowledgeError('repairs', 'contenido aprobado depende de fixtures');
    }
    final technicalVersion =
        textValue(j['technicalVersion'], 'technicalVersion');
    if (technicalVersion != technical.edition.version) {
      throw KnowledgeError('repairs', 'versión técnica incompatible');
    }
    if (j['locale'] != 'es-MX') {
      throw KnowledgeError('repairs', 'locale no soportado');
    }
    final sources = indexed(
        array(j['sources'], 'sources')
            .map((v) => SourceReference(object(v, 'source')))
            .toList(),
        (s) => s.id,
        'sources');
    final groups = array(j['synonyms'], 'synonyms')
        .map((v) => strings(v, 'synonyms.group'))
        .toList();
    for (final group in groups) {
      if (group.length < 2) {
        throw KnowledgeError('synonyms', 'grupo incompleto');
      }
    }
    final identifications = indexed(
        array(j['identifications'], 'identifications')
            .map((v) => Identification(object(v, 'identification')))
            .toList(),
        (v) => v.key,
        'identifications');
    if (identifications.values.map((v) => v.storageKey).toSet().length !=
        identifications.length) {
      throw KnowledgeError('identifications', 'storageKey duplicado');
    }
    Map<String, String> resources(String key) {
      final result = <String, String>{};
      for (final value in array(j[key] ?? [], key)) {
        final resource = object(value, key);
        keys(resource, key, ['id', 'name']);
        final id = identifier(resource['id'], key);
        if (result.containsKey(id)) {
          throw KnowledgeError(key, 'ID repetido $id');
        }
        result[id] = textValue(resource['name'], key);
      }
      return Map.unmodifiable(result);
    }

    final toolCatalog = resources('tools');
    final consumableCatalog = resources('consumables');
    final procedures = indexed(
        array(j['procedures'], 'procedures')
            .map((v) => RepairProcedure(object(v, 'procedure'), technical,
                sources, edition.development, identifications,
                toolCatalog: toolCatalog, consumableCatalog: consumableCatalog))
            .toList(),
        (p) => p.id,
        'procedures');
    return RepairCatalog._(edition, technicalVersion, procedures,
        List.unmodifiable(groups), sources, identifications);
  }
}

class RepairProcedure {
  RepairProcedure(
      Map<String, dynamic> j,
      TechnicalCatalog technical,
      Map<String, SourceReference> sources,
      this.development,
      Map<String, Identification> identifications,
      {Map<String, String> toolCatalog = const {},
      Map<String, String> consumableCatalog = const {}}) {
    keys(j, 'procedure', [
      'id',
      'title',
      'problem',
      'category',
      'terms',
      'bikeTypes',
      'contexts',
      'tools',
      'difficulty',
      'risk',
      'estimatedMinutes',
      'safetyFocus',
      'sourceIds',
      'specificationIds',
      'entry',
      'nodes'
    ], [
      'toolIds',
      'consumableIds'
    ]);
    id = identifier(j['id'], 'procedure.id');
    title = textValue(j['title'], id);
    problem = textValue(j['problem'], id);
    if (development &&
        (!id.startsWith('dev.') || !title.startsWith('[PRUEBA]'))) {
      throw KnowledgeError(id, 'fixture sin marca de desarrollo');
    }
    if (!development && id.startsWith('dev.')) {
      throw KnowledgeError(id, 'fixture no publicable');
    }
    category = oneOf(j['category'], id,
        ['wheels', 'brakes', 'drivetrain', 'steering', 'frame']);
    terms = strings(j['terms'], id);
    bikeTypes = strings(j['bikeTypes'], id);
    contexts = strings(j['contexts'], id);
    final legacyTools = strings(j['tools'], id);
    if (pilot &&
        (!j.containsKey('toolIds') ||
            !j.containsKey('consumableIds') ||
            legacyTools.isNotEmpty)) {
      throw KnowledgeError(id, 'el piloto exige recursos explícitos por ID');
    }
    toolIds = strings(j['toolIds'] ?? [], id);
    consumableIds = strings(j['consumableIds'] ?? [], id);
    for (final tool in toolIds) {
      identifier(tool, id);
      reference(tool, toolCatalog, id);
    }
    for (final consumable in consumableIds) {
      identifier(consumable, id);
      reference(consumable, consumableCatalog, id);
    }
    if (toolIds.isNotEmpty && legacyTools.isNotEmpty) {
      throw KnowledgeError(id, 'no mezclar herramientas libres y referencias');
    }
    tools = List.unmodifiable(
        [...legacyTools, ...toolIds.map((v) => toolCatalog[v]!)]);
    consumables =
        List.unmodifiable(consumableIds.map((v) => consumableCatalog[v]!));
    for (final type in bikeTypes) {
      oneOf(type, id,
          ['MTB', 'Ruta', 'Gravel', 'Urbana', 'Fixie / single speed']);
    }
    if (contexts.isEmpty) throw KnowledgeError(id, 'faltan contextos');
    for (final context in contexts) {
      oneOf(context, id, ['route', 'workshop']);
    }
    difficulty =
        oneOf(j['difficulty'], id, ['basic', 'intermediate', 'advanced']);
    risk = oneOf(j['risk'], id, ['low', 'moderate', 'high']);
    if (j['estimatedMinutes'] == null) {
      estimatedMinutes = null;
    } else {
      final time = object(j['estimatedMinutes'], id);
      keys(time, id, ['min', 'max']);
      if (time['min'] is! int ||
          time['max'] is! int ||
          time['min'] < 1 ||
          time['max'] < time['min'] ||
          time['max'] > 10080) {
        throw KnowledgeError(id, 'intervalo de tiempo inválido');
      }
      estimatedMinutes = (time['min'] as int, time['max'] as int);
    }
    if ((!development || pilot) && estimatedMinutes == null) {
      throw KnowledgeError(id, 'falta estimación editorial de tiempo');
    }
    safetyFocus = strings(j['safetyFocus'], id);
    for (final flag in safetyFocus) {
      oneOf(flag, id, hardStopIds);
    }
    sourceIds = strings(j['sourceIds'], id);
    if ((!development || pilot) && sourceIds.isEmpty) {
      throw KnowledgeError(id, 'procedimiento sin fuente revisada');
    }
    for (final source in sourceIds) {
      reference(source, sources, id);
    }
    sourceReferences = List.unmodifiable(sourceIds.map((v) => sources[v]!));
    specificationIds = strings(j['specificationIds'], id);
    for (final spec in specificationIds) {
      reference(spec, technical.specifications, id);
    }
    entry = identifier(j['entry'], id);
    nodes = indexed(
        array(j['nodes'], id)
            .map((v) => RepairNode(object(v, '$id.node'), identifications))
            .toList(),
        (n) => n.id,
        id);
    if (nodes.length > 512) throw KnowledgeError(id, 'demasiados nodos');
    _validateGraph(development);
  }
  final bool development;
  bool get pilot => id.startsWith('dev.pilot.');
  late final List<String> toolIds, consumableIds, consumables;
  late final List<SourceReference> sourceReferences;
  late final String risk;
  late final (int, int)? estimatedMinutes;
  late final List<String> safetyFocus;
  late final String id, title, problem, category, difficulty, entry;
  late final List<String> terms,
      bikeTypes,
      contexts,
      sourceIds,
      specificationIds;
  late final List<String> tools;
  late final Map<String, RepairNode> nodes;
  void _validateGraph(bool development) {
    reference(entry, nodes, id);
    if (nodes[entry]!.kind != NodeKind.safetyCheck) {
      throw KnowledgeError(id, 'entrada debe comprobar seguridad');
    }
    for (final n in nodes.values) {
      for (final c in n.choices) {
        reference(c.next, nodes, n.id);
        if (nodes[c.next]!.outcome == RepairOutcome.complete &&
            (n.kind != NodeKind.finalCheck || c.verdict != 'pass')) {
          throw KnowledgeError(
              n.id, 'complete solo puede seguir a una prueba final aprobada');
        }
        if (c.hardStop != null &&
            nodes[c.next]!.outcome != RepairOutcome.stop) {
          throw KnowledgeError(n.id, 'bandera roja debe terminar en stop');
        }
      }
      if (n.next != null) reference(n.next!, nodes, n.id);
      for (final target in n.routes.values) {
        reference(target, nodes, n.id);
      }
      if (n.outcome == RepairOutcome.temporary &&
          !development &&
          sourceIds.isEmpty) {
        throw KnowledgeError(n.id, 'temporal sin fuente');
      }
    }
    final reached = <String>{};
    final visiting = <String>{};
    final finished = <String>{};
    void visit(String nodeId, bool passedFinal) {
      if (visiting.contains(nodeId)) {
        throw KnowledgeError(id, 'ciclo en $nodeId');
      }
      final key = '$nodeId/$passedFinal';
      if (finished.contains(key)) return;
      final n = nodes[nodeId]!;
      reached.add(nodeId);
      visiting.add(nodeId);
      if (n.outcome == RepairOutcome.complete && !passedFinal) {
        throw KnowledgeError(id, 'complete sin prueba final aprobada');
      }
      if (n.kind == NodeKind.finalCheck) {
        for (final c in n.choices) {
          visit(c.next, c.verdict == 'pass');
        }
      } else {
        for (final c in n.choices) {
          visit(c.next, passedFinal);
        }
        if (n.next != null) {
          visit(n.next!,
              false); // A new action invalidates an earlier final test.
        }
        for (final target in n.routes.values) {
          visit(target, false);
        }
      }
      visiting.remove(nodeId);
      finished.add(key);
    }

    visit(entry, false);
    if (reached.length != nodes.length) {
      throw KnowledgeError(id, 'nodos inalcanzables');
    }
  }
}

class RepairNode {
  RepairNode(
      Map<String, dynamic> j, Map<String, Identification> identifications) {
    id = identifier(j['id'], 'node.id');
    final kindName =
        oneOf(j['kind'], id, NodeKind.values.map((v) => v.name).toList());
    kind = NodeKind.values.byName(kindName);
    final specific = switch (kind) {
      NodeKind.step => ['next'],
      NodeKind.outcome => ['result', 'restrictions'],
      NodeKind.identify => ['profileKey', 'choices'],
      NodeKind.contextBranch => ['routes'],
      _ => ['choices'],
    };
    keys(j, id, ['id', 'kind', 'text', ...specific], ['details', 'visualIds']);
    visualIds = strings(j['visualIds'] ?? [], id);
    for (final visual in visualIds) {
      oneOf(visual, id, ['tube_bead', 'chain_arm', 'disc_gap']);
    }
    text = textValue(j['text'], id);
    details = j.containsKey('details') ? textValue(j['details'], id) : null;
    next = kind == NodeKind.step ? identifier(j['next'], id) : null;
    if (kind == NodeKind.contextBranch) {
      final values = object(j['routes'], id);
      keys(values, id, ['route', 'workshop']);
      routes = Map.unmodifiable({
        for (final context in values.keys)
          context: identifier(values[context], id)
      });
    } else {
      routes = const {};
    }
    outcome = kind == NodeKind.outcome
        ? RepairOutcome.values.byName(oneOf(
            j['result'], id, RepairOutcome.values.map((v) => v.name).toList()))
        : null;
    restrictions =
        kind == NodeKind.outcome ? strings(j['restrictions'], id) : const [];
    if (outcome == RepairOutcome.temporary && restrictions.isEmpty) {
      throw KnowledgeError(id, 'temporal sin restricciones');
    }
    profileKey = kind == NodeKind.identify
        ? oneOf(j['profileKey'], id, identifications.keys.toList())
        : null;
    identification = profileKey == null ? null : identifications[profileKey];
    choices = List.unmodifiable(j.containsKey('choices')
        ? array(j['choices'], id)
            .map((v) => RepairChoice(object(v, id), kind))
            .toList()
        : <RepairChoice>[]);
    indexed(choices, (c) => c.id, id);
    if (kind != NodeKind.step &&
        kind != NodeKind.outcome &&
        kind != NodeKind.contextBranch &&
        choices.length < 2) {
      throw KnowledgeError(id, 'ramas insuficientes');
    }
    if (kind == NodeKind.finalCheck &&
        (choices.length != 2 ||
            choices.map((c) => c.verdict).toSet().length != 2)) {
      throw KnowledgeError(id, 'prueba final necesita pass y fail');
    }
    if (kind == NodeKind.safetyCheck) {
      if (choices.length != hardStopIds.length + 1 ||
          choices.where((c) => c.hardStop == null).length != 1 ||
          !choices.map((c) => c.hardStop).toSet().containsAll(hardStopIds)) {
        throw KnowledgeError(id, 'faltan banderas rojas obligatorias');
      }
    }
    if (kind == NodeKind.identify) {
      final values = choices.map((c) => c.profileValue).toSet();
      if (values.length != choices.length || !values.contains('unknown')) {
        throw KnowledgeError(
            id, 'identificación sin No sé o con respuestas repetidas');
      }
      for (final value in values) {
        oneOf(value, id, identification!.values.keys.toList());
      }
    }
  }
  late final List<String> visualIds;
  late final String id, text;
  late final String? next, details, profileKey;
  late final Identification? identification;
  late final NodeKind kind;
  late final RepairOutcome? outcome;
  late final List<RepairChoice> choices;
  late final List<String> restrictions;
  late final Map<String, String> routes;
}

class RepairChoice {
  RepairChoice(Map<String, dynamic> j, NodeKind kind) {
    keys(
        j,
        'choice',
        ['id', 'label', 'next'],
        switch (kind) {
          NodeKind.safetyCheck => ['hardStop'],
          NodeKind.identify => ['profileValue'],
          NodeKind.finalCheck => ['verdict'],
          _ => [],
        });
    id = identifier(j['id'], 'choice.id');
    label = textValue(j['label'], id);
    next = identifier(j['next'], id);
    hardStop = j.containsKey('hardStop')
        ? oneOf(j['hardStop'], id, hardStopIds)
        : null;
    profileValue =
        kind == NodeKind.identify ? textValue(j['profileValue'], id) : null;
    verdict = kind == NodeKind.finalCheck
        ? oneOf(j['verdict'], id, ['pass', 'fail'])
        : null;
  }
  late final String id, label, next;
  late final String? hardStop, profileValue, verdict;
}
