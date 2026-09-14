import 'dart:convert';
import '../domain/knowledge/technical_catalog.dart';
import '../domain/knowledge/validation.dart';

/// The XLSX adapter will export these normalized sheet records. No repair logic.
class ComponentImport {
  static const sheets = [
    'sources',
    'manufacturers',
    'families',
    'components',
    'specifications',
    'compatibilities',
    'standards',
    'consumables',
    'componentConsumables'
  ];
  static Map<String, dynamic> transform(Map<String, dynamic> workbook,
      {bool allowDevelopment = false}) {
    keys(workbook, 'workbook',
        ['formatVersion', 'contentVersion', 'status', 'sheets'], ['editorial']);
    if (workbook['formatVersion'] is! int || workbook['formatVersion'] != 2) {
      throw KnowledgeError('workbook', 'formato de intercambio desconocido');
    }
    final rows = object(workbook['sheets'], 'sheets');
    keys(rows, 'sheets', sheets);
    final output = <String, dynamic>{
      'kind': 'components',
      'schemaVersion': 2,
      'contentVersion': workbook['contentVersion'],
      'status': workbook['status'],
      if (workbook.containsKey('editorial')) 'editorial': workbook['editorial'],
      for (final sheet in sheets)
        sheet: (array(rows[sheet], sheet)
            .map((row) => Map<String, dynamic>.of(object(row, sheet)))
            .toList()
          ..sort((a, b) =>
              identifier(a['id'], sheet).compareTo(identifier(b['id'], sheet))))
    };
    // Production importer accepts approved editorial exports only.
    TechnicalCatalog.parse(output, allowDevelopment: allowDevelopment);
    return jsonDecode(jsonEncode(_canonical(output))) as Map<String, dynamic>;
  }

  static Object? _canonical(Object? value) {
    if (value is Map<String, dynamic>) {
      final names = value.keys.toList()..sort();
      return {for (final name in names) name: _canonical(value[name])};
    }
    if (value is List) return value.map(_canonical).toList();
    return value;
  }
}
