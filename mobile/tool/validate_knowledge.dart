import 'dart:convert';
import 'dart:io';
import 'package:bike_expert/domain/knowledge/knowledge_bundle.dart';
import 'package:bike_expert/domain/knowledge/validation.dart';

void main(List<String> args) {
  if (args.isEmpty ||
      args.length > 2 ||
      (args.length == 2 && args[1] != '--development')) {
    stderr.writeln(
        'Uso: dart run tool/validate_knowledge.dart <carpeta> [--development]');
    exitCode = 64;
    return;
  }
  try {
    Map<String, dynamic> read(String name) => object(
        jsonDecode(File('${args[0]}/$name.json').readAsStringSync()), name);
    final bundle = KnowledgeBundle.parse(
        read('manifest'), read('components'), read('repairs'),
        allowDevelopment: args.contains('--development'));
    stdout.writeln(
        'OK: ${bundle.repairs.edition.status}, componentes ${bundle.technical.edition.version}, reparaciones ${bundle.repairs.edition.version}, ${bundle.repairs.procedures.length} procedimientos. Validación estructural; no certifica exactitud editorial.');
  } catch (error) {
    stderr.writeln('RECHAZADO: $error');
    exitCode = 1;
  }
}
