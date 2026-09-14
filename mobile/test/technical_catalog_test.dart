import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/knowledge/technical_catalog.dart';
import 'knowledge_fixtures.dart';

// Synthetic contract data, confined to tests. No real mechanical specifications.
Map<String, dynamic> technicalFixture() {
  final j = fixtureJson('components');
  j['sources'] = [
    {
      'id': 'dev.source',
      'publisher': 'TEST ONLY',
      'document': 'Synthetic test document',
      'revision': 'test',
      'url': 'https://example.invalid/test',
      'section': 'test',
      'reviewedAt': '2026-09-05'
    }
  ];
  j['manufacturers'] = [
    {'id': 'dev.m', 'name': 'TEST ONLY'}
  ];
  j['families'] = [
    {'id': 'dev.f', 'manufacturerId': 'dev.m', 'name': 'TEST ONLY'}
  ];
  j['components'] = [
    for (final id in ['dev.a', 'dev.b', 'dev.c'])
      {
        'id': id,
        'familyId': 'dev.f',
        'name': 'TEST ONLY $id',
        'identification': 'Synthetic identifier, not a real component'
      }
  ];
  j['specifications'] = [
    {
      'id': 'dev.spec',
      'componentId': 'dev.a',
      'property': 'test_label',
      'value': 'synthetic',
      'unit': '',
      'scope': 'test only',
      'sourceId': 'dev.source'
    }
  ];
  j['compatibilities'] = [
    {
      'id': 'dev.pair',
      'from': {'type': 'component', 'id': 'dev.a'},
      'to': {'type': 'component', 'id': 'dev.b'},
      'result': 'compatible',
      'scope': 'test only',
      'sourceId': 'dev.source'
    }
  ];
  return jsonDecode(jsonEncode(j)) as Map<String, dynamic>;
}

void main() {
  test(
      'relaciones explícitas no producen transitividad ni expansión de familia',
      () {
    final j = technicalFixture();
    (j['compatibilities'] as List).addAll([
      {
        'id': 'dev.bc',
        'from': {'type': 'component', 'id': 'dev.b'},
        'to': {'type': 'component', 'id': 'dev.c'},
        'result': 'compatible',
        'scope': 'test only',
        'sourceId': 'dev.source'
      },
      {
        'id': 'dev.af',
        'from': {'type': 'component', 'id': 'dev.a'},
        'to': {'type': 'family', 'id': 'dev.f'},
        'result': 'compatible',
        'scope': 'test only',
        'sourceId': 'dev.source'
      },
    ]);
    final c = TechnicalCatalog.parse(j, allowDevelopment: true);
    expect(c.compatibility('dev.a', 'dev.c', scope: 'test only'), 'unknown');
    expect(
        c.compatibilityBetween(CompatibilityEndpoint('component', 'dev.a'),
            CompatibilityEndpoint('family', 'dev.f'),
            scope: 'test only'),
        'compatible');
  });
  test('propiedad categórica conserva unidad y alcance vacíos', () {
    final j = technicalFixture();
    (j['specifications'] as List).first['scope'] = '';
    final c = TechnicalCatalog.parse(j, allowDevelopment: true);
    expect(c.specifications.values.single.unit, '');
    expect(c.specifications.values.single.scope, '');
  });
  test('no se pueden promover fixtures técnicos cambiando solo status', () {
    final j = technicalFixture();
    j['status'] = 'approved';
    expect(() => TechnicalCatalog.parse(j), throwsFormatException);
  });
  void reject(String name, void Function(Map<String, dynamic>) change) {
    test(name, () {
      final j = technicalFixture();
      change(j);
      expect(() => TechnicalCatalog.parse(j, allowDevelopment: true),
          throwsFormatException);
    });
  }

  test(
      'compatibilidad solo por par exacto, sin inferencia transitiva ni por familia',
      () {
    final c =
        TechnicalCatalog.parse(technicalFixture(), allowDevelopment: true);
    expect(c.compatibility('dev.a', 'dev.b', scope: 'test only'), 'compatible');
    expect(c.compatibility('dev.b', 'dev.a', scope: 'test only'), 'compatible');
    expect(c.compatibility('dev.a', 'dev.b'), 'unknown');
    expect(c.compatibility('dev.a', 'dev.b', scope: 'different'), 'unknown');
    expect(c.compatibility('dev.a', 'dev.c'), 'unknown');
    expect(c.compatibility('missing', 'dev.a'), 'unknown');
    expect(c.specifications['dev.spec']!.value, 'synthetic');
    expect(c.sources['dev.source']!.section, 'test');
  });
  for (final collection in [
    'sources',
    'manufacturers',
    'families',
    'components',
    'specifications',
    'compatibilities'
  ]) {
    reject('$collection rechaza IDs duplicados',
        (j) => (j[collection] as List).add((j[collection] as List).first));
  }
  reject(
      'familia sin fabricante',
      (j) =>
          ((j['families'] as List).first as Map)['manufacturerId'] = 'missing');
  reject('componente sin familia',
      (j) => ((j['components'] as List).first as Map)['familyId'] = 'missing');
  reject(
      'especificación sin componente',
      (j) => ((j['specifications'] as List).first as Map)['componentId'] =
          'missing');
  reject(
      'especificación sin fuente',
      (j) =>
          ((j['specifications'] as List).first as Map)['sourceId'] = 'missing');
  reject('especificación con alcance inválido',
      (j) => ((j['specifications'] as List).first as Map).remove('scope'));
  reject('especificación sin unidad',
      (j) => ((j['specifications'] as List).first as Map).remove('unit'));
  reject('null no equivale a referencia editorial vacía',
      (j) => ((j['specifications'] as List).first as Map)['standardId'] = null);
  reject('compatibilidad sin destino',
      (j) => ((j['compatibilities'] as List).first as Map)['to'] = 'missing');
  reject(
      'compatibilidad con estado ambiguo',
      (j) =>
          ((j['compatibilities'] as List).first as Map)['result'] = 'probably');
  reject(
      'pares contradictorios',
      (j) => (j['compatibilities'] as List).add({
            'id': 'dev.conflict',
            'from': {'type': 'component', 'id': 'dev.b'},
            'to': {'type': 'component', 'id': 'dev.a'},
            'result': 'incompatible',
            'scope': 'test only',
            'sourceId': 'dev.source'
          }));
  reject(
      'fecha de revisión imposible',
      (j) =>
          ((j['sources'] as List).first as Map)['reviewedAt'] = '2026-02-30');
  reject('fuente sin URL segura',
      (j) => ((j['sources'] as List).first as Map)['url'] = 'file:///test');
  reject('rechaza lógica de reparación en componentes', (j) => j['steps'] = []);
}
