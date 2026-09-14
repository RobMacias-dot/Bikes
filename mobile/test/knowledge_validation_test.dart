import 'package:flutter_test/flutter_test.dart';
import 'package:bike_expert/domain/knowledge/knowledge_bundle.dart';
import 'package:bike_expert/domain/knowledge/repair_catalog.dart';
import 'package:bike_expert/domain/knowledge/technical_catalog.dart';
import 'package:bike_expert/data/component_import.dart';
import 'knowledge_fixtures.dart';

void main() {
  void reject(String title, void Function(Map<String, dynamic>) change) {
    test(title, () {
      final j = fixtureJson('repairs');
      change(j);
      expect(
          () => RepairCatalog.parse(
              j,
              TechnicalCatalog.parse(fixtureJson('components'),
                  allowDevelopment: true),
              allowDevelopment: true),
          throwsFormatException);
    });
  }

  test('los paquetes aprobados vacíos son válidos y no incluyen fixtures', () {
    final bundle = KnowledgeBundle.parse(
        fixtureJson('manifest', edition: 'approved'),
        fixtureJson('components', edition: 'approved'),
        fixtureJson('repairs', edition: 'approved'));
    expect(bundle.repairs.procedures, isEmpty);
    expect(bundle.technical.components, isEmpty);
  });
  reject('rechaza rama de contexto inexistente',
      (j) => (node(j, 'context')['routes'] as Map)['route'] = 'missing');
  reject('rechaza contexto incompleto',
      (j) => (node(j, 'context')['routes'] as Map).remove('workshop'));
  reject('rechaza contexto que omite prueba final',
      (j) => (node(j, 'context')['routes'] as Map)['route'] = 'complete');
  reject(
      'rechaza versión de esquema no entera', (j) => j['schemaVersion'] = 1.0);
  test('fixtures rechazados por defecto', () {
    expect(
        () => KnowledgeBundle.parse(fixtureJson('manifest'),
            fixtureJson('components'), fixtureJson('repairs')),
        throwsFormatException);
  });
  test('manifiesto no permite versiones inconsistentes', () {
    final m = fixtureJson('manifest');
    m['repairsVersion'] = '2.0.0';
    expect(
        () => KnowledgeBundle.parse(
            m, fixtureJson('components'), fixtureJson('repairs'),
            allowDevelopment: true),
        throwsFormatException);
  });
  reject('rechaza schemaVersion futura', (j) => j['schemaVersion'] = 99);
  reject(
      'rechaza contentVersion inválida', (j) => j['contentVersion'] = 'latest');
  reject('rechaza dependencia técnica incorrecta',
      (j) => j['technicalVersion'] = '2.0.0');
  reject('rechaza ID de procedimiento duplicado',
      (j) => (j['procedures'] as List).add(firstProcedure(j)));
  reject('rechaza ID de nodo duplicado',
      (j) => (firstProcedure(j)['nodes'] as List).add(node(j, 'action')));
  reject(
      'rechaza ID de respuesta duplicado',
      (j) => (node(j, 'worked')['choices'] as List)
          .add((node(j, 'worked')['choices'] as List).first));
  reject(
      'rechaza referencia de rama inexistente',
      (j) => ((node(j, 'worked')['choices'] as List).first as Map)['next'] =
          'missing');
  reject('rechaza referencia de especificación inexistente',
      (j) => firstProcedure(j)['specificationIds'] = ['missing']);
  reject('rechaza fuente inexistente',
      (j) => firstProcedure(j)['sourceIds'] = ['missing']);
  reject('rechaza entrada inexistente',
      (j) => firstProcedure(j)['entry'] = 'missing');
  reject(
      'rechaza nodo inalcanzable',
      (j) => (firstProcedure(j)['nodes'] as List).add({
            'id': 'orphan',
            'kind': 'outcome',
            'text': 'Test',
            'result': 'unresolved',
            'restrictions': []
          }));
  reject('rechaza ciclo', (j) => node(j, 'action')['next'] = 'initial');
  reject('rechaza complete sin final',
      (j) => node(j, 'action')['next'] = 'complete');
  reject('rechaza resultado desconocido',
      (j) => node(j, 'complete')['result'] = 'maybe');
  reject(
      'rechaza final con pass duplicado',
      (j) => ((node(j, 'final')['choices'] as List).last as Map)['verdict'] =
          'pass');
  reject(
      'rechaza fallo final que termina en complete',
      (j) => ((node(j, 'final')['choices'] as List).last as Map)['next'] =
          'complete');
  reject('rechaza temporal sin restricciones',
      (j) => node(j, 'temporary')['restrictions'] = []);
  reject(
      'rechaza hard stop degradado',
      (j) => ((node(j, 'safety')['choices'] as List)[1] as Map)['next'] =
          'temporary');
  reject(
      'rechaza bandera roja desconocida',
      (j) => ((node(j, 'safety')['choices'] as List)[1] as Map)['hardStop'] =
          'optional');
  reject('rechaza seguridad incompleta',
      (j) => (node(j, 'safety')['choices'] as List).removeLast());
  reject('rechaza salto de la seguridad inicial',
      (j) => firstProcedure(j)['entry'] = 'identify');
  reject('rechaza campo no reconocido', (j) => node(j, 'action')['torque'] = 5);
  reject('rechaza fixture sin marca visible',
      (j) => firstProcedure(j)['title'] = 'Una guía');
  reject('rechaza dato de perfil fuera de contrato',
      (j) => node(j, 'identify')['profileKey'] = 'torque');
  reject('rechaza identificación sin desconocido',
      (j) => (node(j, 'identify')['choices'] as List).removeLast());
  test(
      'importador transforma hojas vacías sin inventar datos y de forma determinista',
      () {
    final input = {
      'formatVersion': 2,
      'contentVersion': '1.0.0',
      'status': 'approved',
      'sheets': {for (final name in ComponentImport.sheets) name: <dynamic>[]}
    };
    final output = ComponentImport.transform(input);
    expect(TechnicalCatalog.parse(output).components, isEmpty);
    expect(ComponentImport.transform(input), output);
  });
  test(
      'importador no publica hojas de desarrollo ni columnas fuera del contrato',
      () {
    final input = <String, dynamic>{
      'formatVersion': 2,
      'contentVersion': '1.0.0',
      'status': 'development',
      'sheets': {for (final name in ComponentImport.sheets) name: <dynamic>[]}
    };
    expect(() => ComponentImport.transform(input), throwsFormatException);
    input['status'] = 'approved';
    (input['sheets'] as Map)['procedures'] = [];
    expect(() => ComponentImport.transform(input), throwsFormatException);
  });
}
