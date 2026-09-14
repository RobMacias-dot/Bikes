import 'validation.dart';

/// Technical knowledge only. Relations never imply other relations.
class TechnicalCatalog {
  TechnicalCatalog._(
      this.edition,
      this.components,
      this.specifications,
      this.compatibilities,
      this.sources,
      this.manufacturers,
      this.families,
      this.standards,
      this.consumables,
      this.componentConsumables);
  final Edition edition;
  final Map<String, SourceReference> sources;
  final Map<String, Map<String, dynamic>> manufacturers,
      families,
      standards,
      consumables,
      componentConsumables;
  final Map<String, TechnicalComponent> components;
  final Map<String, TechnicalSpecification> specifications;
  final Map<String, Compatibility> compatibilities;
  factory TechnicalCatalog.parse(Map<String, dynamic> j,
      {bool allowDevelopment = false}) {
    keys(j, 'technical', [
      'kind',
      'schemaVersion',
      'contentVersion',
      'status',
      'sources',
      'manufacturers',
      'families',
      'components',
      'standards',
      'specifications',
      'compatibilities',
      'consumables',
      'componentConsumables'
    ], [
      'editorial'
    ]);
    final edition =
        Edition(j, 'components', allowDevelopment: allowDevelopment);
    if (j.containsKey('editorial')) {
      final editorial = object(j['editorial'], 'editorial');
      keys(editorial, 'editorial', ['sourceFile', 'sha256', 'metadata']);
      if (editorial['sourceFile'] != 'BiciFirme_Componentes_Master.xlsx' ||
          !RegExp(r'^[a-f0-9]{64}$')
              .hasMatch(textValue(editorial['sha256'], 'sha256'))) {
        throw KnowledgeError('editorial', 'procedencia inválida');
      }
      final metadata = object(editorial['metadata'], 'metadata');
      for (final value in metadata.values) {
        optionalText(value, 'metadata');
      }
      if (metadata['schema_version'] != '1' ||
          metadata['status'] != 'development' ||
          !edition.development ||
          metadata['content_version'] != edition.version) {
        throw KnowledgeError(
            'editorial', 'versión o estado editorial incompatible');
      }
    }
    final sources = indexed(
        array(j['sources'], 'sources')
            .map((v) => SourceReference(object(v, 'source')))
            .toList(),
        (s) => s.id,
        'sources');
    Map<String, Map<String, dynamic>> records(String key, List<String> required,
            [List<String> optional = const []]) =>
        indexed(
            array(j[key], key).map((v) {
              final r = object(v, key);
              keys(r, key, required, optional);
              identifier(r['id'], '$key.id');
              for (final field in r.keys.where((k) => k != 'id')) {
                optionalText(r[field], '$key.$field');
              }
              return Map<String, dynamic>.unmodifiable(r);
            }).toList(),
            (r) => r['id'] as String,
            key);
    final manufacturers =
        records('manufacturers', ['id', 'name'], ['website', 'notes']);
    final families = records('families', ['id', 'manufacturerId', 'name'],
        ['componentCategory', 'notes']);
    for (final r in [...manufacturers.values, ...families.values]) {
      textValue(r['name'], 'name');
    }
    for (final r in families.values) {
      reference(identifier(r['manufacturerId'], 'family.manufacturerId'),
          manufacturers, 'family');
    }
    final standards = records('standards', [
      'id',
      'category',
      'name',
      'designation',
      'description',
      'dimension1',
      'dimension1Unit',
      'dimension2',
      'dimension2Unit',
      'thread',
      'sourceId',
      'notes'
    ]);
    for (final r in standards.values) {
      for (final f in ['category', 'name', 'designation', 'description']) {
        textValue(r[f], 'standard.$f');
      }
      reference(
          identifier(r['sourceId'], 'standard.sourceId'), sources, 'standard');
      for (final i in [1, 2]) {
        final unit = unitValue(r['dimension${i}Unit'], 'standard.unit');
        if ((r['dimension$i'] == '') != (unit == '')) {
          throw KnowledgeError(
              r['id'] as String, 'dimensión y unidad deben estar juntas');
        }
      }
    }
    void optionalRef(
        Map<String, dynamic> r, String field, Map<String, dynamic> target) {
      if (r.containsKey(field) && r[field] != '') {
        reference(identifier(r[field], field), target, r['id'] as String);
      }
    }

    final components = indexed(
        array(j['components'], 'components')
            .map((v) => TechnicalComponent(object(v, 'component')))
            .toList(),
        (c) => c.id,
        'components');
    for (final c in components.values) {
      reference(c.familyId, families, c.id);
      optionalRef(c.fields, 'sourceId', sources);
      optionalRef(c.fields, 'standardPrimaryId', standards);
      optionalRef(c.fields, 'manufacturerId', manufacturers);
      if (c.fields.containsKey('manufacturerId') &&
          c.fields['manufacturerId'] !=
              families[c.familyId]!['manufacturerId']) {
        throw KnowledgeError(c.id, 'fabricante distinto al de la familia');
      }
    }
    final specs = indexed(
        array(j['specifications'], 'specifications')
            .map((v) => TechnicalSpecification(object(v, 'specification')))
            .toList(),
        (s) => s.id,
        'specifications');
    for (final s in specs.values) {
      reference(s.componentId, components, s.id);
      reference(s.sourceId, sources, s.id);
      if (s.standardId.isNotEmpty) reference(s.standardId, standards, s.id);
    }
    final consumables = records('consumables', [
      'id',
      'manufacturerId',
      'category',
      'name',
      'variant',
      'specification',
      'unit',
      'standardId',
      'sourceId',
      'notes'
    ]);
    for (final r in consumables.values) {
      for (final f in ['category', 'name', 'specification']) {
        textValue(r[f], 'consumable.$f');
      }
      unitValue(r['unit'], 'consumable.unit');
      optionalRef(r, 'manufacturerId', manufacturers);
      optionalRef(r, 'standardId', standards);
      reference(identifier(r['sourceId'], 'consumable.sourceId'), sources,
          'consumable');
    }
    final links = records('componentConsumables', [
      'id',
      'componentId',
      'consumableId',
      'relationType',
      'scope',
      'sourceId',
      'notes'
    ]);
    final linkKeys = <String>{};
    for (final r in links.values) {
      reference(identifier(r['componentId'], 'relation.componentId'),
          components, 'relation');
      reference(identifier(r['consumableId'], 'relation.consumableId'),
          consumables, 'relation');
      reference(
          identifier(r['sourceId'], 'relation.sourceId'), sources, 'relation');
      oneOf(r['relationType'], 'relation.type',
          ['service', 'replacement', 'compatible']);
      textValue(r['scope'], 'relation.scope');
      if (!linkKeys.add(
          '${r['componentId']}|${r['consumableId']}|${r['relationType']}|${r['scope']}')) {
        throw KnowledgeError('relation', 'relación duplicada');
      }
    }
    final compatibility = indexed(
        array(j['compatibilities'], 'compatibilities')
            .map((v) => Compatibility(object(v, 'compatibility')))
            .toList(),
        (c) => c.id,
        'compatibilities');
    final endpointTables = {
      'component': components,
      'standard': standards,
      'family': families
    };
    final pairs = <String>{};
    for (final c in compatibility.values) {
      reference(c.from.id, endpointTables[c.from.type]!, c.id);
      reference(c.to.id, endpointTables[c.to.type]!, c.id);
      reference(c.sourceId, sources, c.id);
      final pair = [c.from.key, c.to.key]..sort();
      if (!pairs.add('${pair.join('|')}|${c.scope}')) {
        throw KnowledgeError(c.id,
            'compatibilidad duplicada o contradictoria en el mismo alcance');
      }
    }
    for (final id in [
      ...sources.keys,
      ...manufacturers.keys,
      ...families.keys,
      ...components.keys,
      ...standards.keys,
      ...specs.keys,
      ...compatibility.keys,
      ...consumables.keys,
      ...links.keys
    ]) {
      if (!edition.development && id.startsWith('dev.')) {
        throw KnowledgeError(id, 'fixture no publicable');
      }
    }
    return TechnicalCatalog._(edition, components, specs, compatibility,
        sources, manufacturers, families, standards, consumables, links);
  }
  String compatibility(String a, String b, {String? scope}) =>
      compatibilityBetween(CompatibilityEndpoint('component', a),
          CompatibilityEndpoint('component', b),
          scope: scope);
  String compatibilityBetween(CompatibilityEndpoint a, CompatibilityEndpoint b,
      {String? scope}) {
    for (final c in compatibilities.values) {
      if (scope == c.scope &&
          ((c.from.key == a.key && c.to.key == b.key) ||
              (c.from.key == b.key && c.to.key == a.key))) {
        return c.result;
      }
    }
    return 'unknown';
  }
}

class TechnicalComponent {
  TechnicalComponent(Map<String, dynamic> j) {
    keys(j, 'component', [
      'id',
      'familyId',
      'name',
      'identification'
    ], [
      'manufacturerId',
      'category',
      'subcategory',
      'model',
      'variant',
      'bikeUse',
      'standardPrimaryId',
      'sourceId',
      'notes'
    ]);
    id = identifier(j['id'], 'component.id');
    familyId = identifier(j['familyId'], 'component.familyId');
    name = textValue(j['name'], 'component.name');
    identification = textValue(j['identification'], 'component.identification');
    for (final field in j.keys) {
      optionalText(j[field], 'component.$field');
    }
    fields = Map.unmodifiable(j);
  }
  late final String id, familyId, name, identification;
  late final Map<String, dynamic> fields;
}

class TechnicalSpecification {
  TechnicalSpecification(Map<String, dynamic> j) {
    keys(
        j,
        'specification',
        ['id', 'componentId', 'property', 'value', 'unit', 'scope', 'sourceId'],
        ['standardId', 'critical', 'notes']);
    id = identifier(j['id'], 'specification.id');
    componentId = identifier(j['componentId'], 'specification.componentId');
    sourceId = identifier(j['sourceId'], 'specification.sourceId');
    property = textValue(j['property'], 'specification.property');
    value = textValue(j['value'], 'specification.value');
    unit = unitValue(j['unit'], 'specification.unit');
    scope = optionalText(j['scope'], 'specification.scope');
    standardId = optionalText(
        j.containsKey('standardId') ? j['standardId'] : '',
        'specification.standardId');
    notes = optionalText(
        j.containsKey('notes') ? j['notes'] : '', 'specification.notes');
    if (j.containsKey('critical') && j['critical'] is! bool) {
      throw KnowledgeError(id, 'critical debe ser booleano');
    }
    critical = j['critical'] as bool? ?? false;
  }
  late final String id,
      componentId,
      sourceId,
      property,
      value,
      unit,
      scope,
      standardId,
      notes;
  late final bool critical;
}

class CompatibilityEndpoint {
  CompatibilityEndpoint(String type, String id)
      : type =
            oneOf(type, 'endpoint.type', ['component', 'standard', 'family']),
        id = identifier(id, 'endpoint.id');
  factory CompatibilityEndpoint.parse(Object? value) {
    final j = object(value, 'endpoint');
    keys(j, 'endpoint', ['type', 'id']);
    return CompatibilityEndpoint(textValue(j['type'], 'endpoint.type'),
        identifier(j['id'], 'endpoint.id'));
  }
  final String type, id;
  String get key => '$type:$id';
}

class Compatibility {
  Compatibility(Map<String, dynamic> j) {
    keys(j, 'compatibility',
        ['id', 'from', 'to', 'result', 'scope', 'sourceId'], ['notes']);
    id = identifier(j['id'], 'compatibility.id');
    from = CompatibilityEndpoint.parse(j['from']);
    to = CompatibilityEndpoint.parse(j['to']);
    if (from.key == to.key) throw KnowledgeError(id, 'endpoints idénticos');
    sourceId = identifier(j['sourceId'], 'compatibility.sourceId');
    scope = textValue(j['scope'], 'compatibility.scope');
    notes = optionalText(
        j.containsKey('notes') ? j['notes'] : '', 'compatibility.notes');
    result = oneOf(
        j['result'], 'compatibility.result', ['compatible', 'incompatible']);
  }
  late final String id, result, sourceId, scope, notes;
  late final CompatibilityEndpoint from, to;
}
