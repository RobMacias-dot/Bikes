import 'dart:convert';
import 'dart:io';
import 'package:bike_expert/data/component_import.dart';
import 'package:bike_expert/domain/knowledge/validation.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln(
        'Uso: dart run tool/import_components.dart <hojas-normalizadas.json> <salida-nueva.json>');
    exitCode = 64;
    return;
  }
  try {
    final output = File(args[1]);
    if (output.existsSync()) {
      throw const FormatException(
          'La salida ya existe; usa un archivo nuevo para revisión');
    }
    final result = ComponentImport.transform(
        object(jsonDecode(File(args[0]).readAsStringSync()), 'workbook'));
    output.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(result)}\n',
        flush: true);
    stdout.writeln(
        'Catálogo validado generado para revisión. No se modificaron los assets de la app.');
  } catch (error) {
    stderr.writeln('RECHAZADO: $error');
    exitCode = 1;
  }
}
