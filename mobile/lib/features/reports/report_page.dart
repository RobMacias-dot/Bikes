import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/diagnostic.dart';
import '../../domain/services/diagnostic_engine.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key, required this.result});
  final DiagnosticResult result;
  String get summary =>
      'Bike Expert\nRiesgo: ${result.risk.label}${result.stopUse ? ' — NO UTILIZAR' : ''}\nDiagnóstico probable: ${result.scenario.diagnosis}\nAcción: ${result.scenario.action}\n\nOrientación educativa: requiere inspección física y manual exacto.';
  Future<Uint8List> _pdf() async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
        build: (_) => pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Text(summary, style: const pw.TextStyle(fontSize: 14)))));
    return doc.save();
  }

  Future<File> _savePdf() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/diagnostico_bike_expert_${DateTime.now().millisecondsSinceEpoch}.pdf');
    return file.writeAsBytes(await _pdf());
  }

  @override
  Widget build(BuildContext context) {
    final bayes = result.scenario.bayes == null
        ? null
        : updateBayes(result.scenario.bayes!, true);
    final fuzzy = mamdani(
        experience: 0, tools: 0, complexity: result.scenario.complexity);
    return Scaffold(
        appBar: AppBar(title: const Text('Resultado')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
              color: result.stopUse
                  ? Theme.of(context).colorScheme.errorContainer
                  : null,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            result.stopUse
                                ? 'NO UTILIZAR'
                                : 'RIESGO ${result.risk.label}',
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text(result.stopUse
                            ? 'Existe un riesgo crítico: suspende el uso hasta inspección y reparación.'
                            : '${result.risk.label}: verifica antes del siguiente uso.')
                      ]))),
          ListTile(
              title: const Text('Diagnóstico probable'),
              subtitle: Text(result.scenario.diagnosis)),
          ListTile(
              title: const Text('Acción recomendada'),
              subtitle: Text(result.scenario.action)),
          ExpansionTile(
              title: const Text('Compatibilidad'),
              children: result.compatibility
                  .map((x) => ListTile(title: Text(x)))
                  .toList()),
          if (bayes != null)
            ListTile(
                title: const Text('Bayes orientativo'),
                subtitle: Text(
                    '${bayes.hypothesis}: inicial ${(bayes.prior * 100).round()}%, posterior ${(bayes.posterior * 100).round()}%. No confirma daño físico.')),
          ListTile(
              title: const Text('Mamdani'),
              subtitle: Text(
                  'Facilidad ${fuzzy.score.toStringAsFixed(0)}/100 — ${fuzzy.label}. La facilidad no autoriza uso inseguro.')),
          ExpansionTile(
              title: const Text('Traza técnica'),
              children: result.ruleTrace
                  .map((x) => ListTile(title: Text(x)))
                  .toList()),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: () => Share.share(summary),
              icon: const Icon(Icons.ios_share),
              label: const Text('Compartir resumen')),
          OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: summary));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resultado copiado.')));
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar resultado')),
          OutlinedButton.icon(
              onPressed: () async {
                final bytes = await _pdf();
                await Printing.sharePdf(
                    bytes: bytes, filename: 'diagnostico_bike_expert.pdf');
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar y compartir PDF')),
          OutlinedButton.icon(
              onPressed: () async {
                final file = await _savePdf();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF guardado en ${file.path}')));
                }
              },
              icon: const Icon(Icons.save_alt),
              label: const Text('Guardar PDF')),
          const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                  'Alcance: orientación educativa. No confirma seguridad, compatibilidad ni reparación sin inspección física y manual del componente.'))
        ]));
  }
}
