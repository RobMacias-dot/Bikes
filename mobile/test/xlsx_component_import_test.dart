import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/data/xlsx_component_import.dart';
import 'package:bike_expert/domain/knowledge/technical_catalog.dart';
import 'package:bike_expert/domain/knowledge/repair_catalog.dart';
import 'knowledge_fixtures.dart';

void main() {
  late Map<String, dynamic> original;
  Map<String, dynamic> copy() =>
      jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
  List<dynamic> rows(Map<String, dynamic> j, String sheet) =>
      ((j['sheets'] as Map)[sheet] as Map)['rows'] as List;
  Map<String, dynamic> row(Map<String, dynamic> j, String sheet) =>
      rows(j, sheet).first as Map<String, dynamic>;
  setUpAll(() {
    final process = Process.runSync(
        Platform.environment['BICIFIRME_PYTHON'] ?? 'python',
        [
          '../tools/xlsx_master.py',
          '../knowledge/master/BiciFirme_Componentes_Master.xlsx'
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8);
    expect(process.exitCode, 0, reason: '${process.stderr}');
    original = jsonDecode(process.stdout as String) as Map<String, dynamic>;
  });
  test(
      'maestro real: importación completa, versionada, determinista y sin pérdida de filas',
      () {
    final output = XlsxComponentImport.transform(copy());
    final expected = {
      'sources': 59,
      'manufacturers': 11,
      'families': 21,
      'components': 61,
      'standards': 52,
      'specifications': 409,
      'compatibilities': 20,
      'consumables': 11,
      'componentConsumables': 8
    };
    for (final count in expected.entries) {
      expect((output[count.key] as List).length, count.value);
    }
    expect(output['status'], 'development');
    expect(output['contentVersion'], '0.1.0');
    expect((output['editorial'] as Map)['sha256'],
        'e3b4510f378b70c6e2758b24b1301124b49806b3299ad70612758fbdce706b1d');
    expect(XlsxComponentImport.transform(copy()), output);
    expect(
        jsonDecode(
            File('../knowledge/generated/development/0.1.0/components.json')
                .readAsStringSync()),
        output);
    expect(() => TechnicalCatalog.parse(output), throwsFormatException);
    final catalog = TechnicalCatalog.parse(output, allowDevelopment: true);
    expect(
        catalog.specifications.values.where((s) => s.unit.isEmpty).length, 244);
    expect(catalog.components.containsKey('ritchey.c260_stem'), isFalse);
    // Same spelling in different entity namespaces is intentional, never an inferred relation.
    expect(catalog.components.containsKey('trp.spyre'), isTrue);
    expect(catalog.families.containsKey('trp.spyre'), isTrue);
    final repairs = fixtureJson('repairs');
    repairs['technicalVersion'] = '0.1.0';
    expect(
        RepairCatalog.parse(repairs, catalog, allowDevelopment: true)
            .technicalVersion,
        '0.1.0');
  });
  void reject(String name, void Function(Map<String, dynamic>) mutate,
      {String? reason}) {
    test(name, () {
      final j = copy();
      mutate(j);
      expect(
          () => XlsxComponentImport.transform(j),
          reason == null
              ? throwsFormatException
              : throwsA(isA<FormatException>()
                  .having((e) => e.message, 'reason', contains(reason))));
    });
  }

  for (final sheet in XlsxComponentImport.names.keys) {
    reject('$sheet IDs duplicados, aunque el conteo se actualice', (j) {
      rows(j, sheet).add(Map<String, dynamic>.from(row(j, sheet)));
      for (final metadata in rows(j, 'README')) {
        if ((metadata as Map)['key'] == 'count.${sheet.toLowerCase()}') {
          metadata['value'] = rows(j, sheet).length.toString();
        }
      }
    }, reason: 'ID repetido');
  }
  for (final entry in {
    'FAMILIES': 'manufacturer_id',
    'COMPONENTS': 'family_id',
    'STANDARDS': 'source_id',
    'SPECIFICATIONS': 'standard_id',
    'CONSUMABLES': 'manufacturer_id',
    'COMPONENT_CONSUMABLES': 'consumable_id'
  }.entries) {
    reject('${entry.key} referencia rota',
        (j) => row(j, entry.key)[entry.value] = 'missing',
        reason: 'referencia inexistente');
  }
  reject('endpoint ausente',
      (j) => row(j, 'COMPATIBILITIES')['from_component_id'] = '',
      reason: 'exactamente un endpoint');
  reject(
      'endpoint ambiguo',
      (j) =>
          row(j, 'COMPATIBILITIES')['from_standard_id'] = 'standard.freehub.xd',
      reason: 'exactamente un endpoint');
  reject(
      'endpoint tipado inexistente',
      (j) => row(j, 'COMPATIBILITIES')['from_component_id'] =
          'standard.freehub.xd',
      reason: 'referencia inexistente');
  reject(
      'versión del maestro no soportada',
      (j) => rows(j, 'README')
          .firstWhere((r) => r['key'] == 'schema_version')['value'] = '2');
  reject(
      'versión de contenido inválida',
      (j) => rows(j, 'README')
              .firstWhere((r) => r['key'] == 'content_version')['value'] =
          'latest');
  reject(
      'no promover maestro a approved',
      (j) => rows(j, 'README')
          .firstWhere((r) => r['key'] == 'status')['value'] = 'approved');
  reject(
      'conteo editorial incorrecto',
      (j) => rows(j, 'README')
          .firstWhere((r) => r['key'] == 'count.components')['value'] = '60');
  reject('propiedad sin valor', (j) => row(j, 'SPECIFICATIONS')['value'] = '');
  reject('critical no booleano',
      (j) => row(j, 'SPECIFICATIONS')['critical'] = 'maybe');
  reject('unidad ficticia', (j) => row(j, 'SPECIFICATIONS')['unit'] = 'n/a');
  reject(
      'columna desconocida',
      (j) => ((j['sheets'] as Map)['SPECIFICATIONS']['columns'] as List)
          .add('torque_guess'));
  reject(
      'columna obligatoria ausente',
      (j) => ((j['sheets'] as Map)['SPECIFICATIONS']['columns'] as List)
          .remove('unit'));
  test('endpoints de familia desde columnas editoriales, sin crear proxies',
      () {
    final j = copy();
    final sheet = (j['sheets'] as Map)['COMPATIBILITIES'] as Map;
    (sheet['columns'] as List).add('to_family_id');
    for (final r in rows(j, 'COMPATIBILITIES')) {
      r['to_family_id'] = '';
    }
    final first = row(j, 'COMPATIBILITIES');
    first['to_component_id'] = '';
    first['to_family_id'] = row(j, 'FAMILIES')['family_id'];
    final result = XlsxComponentImport.transform(j);
    final c = TechnicalCatalog.parse(result, allowDevelopment: true);
    final match = c.compatibilities[first['compatibility_id']]!;
    expect(match.to.type, 'family');
    expect(c.compatibilityBetween(match.from, match.to, scope: match.scope),
        'compatible');
    expect(
        c.compatibilityBetween(
            match.from, CompatibilityEndpoint('component', match.to.id),
            scope: match.scope),
        'unknown');
  });
  test('catálogo editado rechaza versión runtime y metadatos inconsistentes',
      () {
    final j = XlsxComponentImport.transform(copy());
    j['schemaVersion'] = 1;
    expect(() => TechnicalCatalog.parse(j, allowDevelopment: true),
        throwsFormatException);
    j['schemaVersion'] = 2;
    j['contentVersion'] = '0.2.0';
    expect(() => TechnicalCatalog.parse(j, allowDevelopment: true),
        throwsFormatException);
  });
}
