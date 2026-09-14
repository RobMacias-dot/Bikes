import 'dart:convert';
import 'dart:io';
import 'package:bike_expert/data/xlsx_component_import.dart';
import 'package:bike_expert/data/component_import.dart';
import 'package:bike_expert/domain/knowledge/validation.dart';

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln(
        'Uso (desde mobile): dart run tool/import_xlsx.dart <python> <maestro.xlsx> <salida-nueva.json>');
    exitCode = 64;
    return;
  }
  try {
    final output = File(args[2]);
    if (output.existsSync()) {
      throw const FormatException(
          'La salida ya existe; usa una nueva ruta de revisión');
    }
    if (File(args[1]).uri.pathSegments.last !=
        'BiciFirme_Componentes_Master.xlsx') {
      throw const FormatException('Nombre de maestro incorrecto');
    }
    final reader = File('../tools/xlsx_master.py').absolute;
    final process = Process.runSync(
        args[0], [reader.path, File(args[1]).absolute.path],
        stdoutEncoding: utf8, stderrEncoding: utf8);
    if (process.exitCode != 0) {
      throw FormatException('OOXML rechazado: ${process.stderr}');
    }
    final result = XlsxComponentImport.transform(
        object(jsonDecode(process.stdout as String), 'xlsx'));
    output.parent.createSync(recursive: true);
    // All extraction and contract checks have completed before any catalog write.
    output.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(result)}\n',
        flush: true);
    stdout.writeln(jsonEncode({
      'status': result['status'],
      'contentVersion': result['contentVersion'],
      'sha256': (result['editorial'] as Map)['sha256'],
      for (final sheet in ComponentImport.sheets)
        sheet: (result[sheet] as List).length
    }));
  } catch (error) {
    stderr.writeln('RECHAZADO: $error');
    exitCode = 1;
  }
}
