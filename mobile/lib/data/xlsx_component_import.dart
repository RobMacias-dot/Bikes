import '../domain/knowledge/validation.dart';
import 'component_import.dart';

/// Pure editorial transformation of OOXML rows. Never imported by the app.
class XlsxComponentImport {
  static const columns = {
    'SOURCES':
        'source_id publisher document revision url section reviewed_at source_type notes',
    'MANUFACTURERS': 'manufacturer_id name website notes',
    'FAMILIES': 'family_id manufacturer_id name component_category notes',
    'COMPONENTS':
        'component_id family_id manufacturer_id category subcategory name model variant bike_use identification standard_primary_id source_id notes',
    'STANDARDS':
        'standard_id category name designation description dimension_1 dimension_1_unit dimension_2 dimension_2_unit thread source_id notes',
    'SPECIFICATIONS':
        'specification_id component_id property value unit standard_id scope source_id critical notes',
    'COMPATIBILITIES':
        'compatibility_id from_component_id to_component_id from_standard_id to_standard_id result scope source_id notes',
    'CONSUMABLES':
        'consumable_id manufacturer_id category name variant specification unit standard_id source_id notes',
    'COMPONENT_CONSUMABLES':
        'relation_id component_id consumable_id relation_type scope source_id notes',
    'README': 'key value notes',
  };
  static const names = {
    'SOURCES': 'sources',
    'MANUFACTURERS': 'manufacturers',
    'FAMILIES': 'families',
    'COMPONENTS': 'components',
    'STANDARDS': 'standards',
    'SPECIFICATIONS': 'specifications',
    'COMPATIBILITIES': 'compatibilities',
    'CONSUMABLES': 'consumables',
    'COMPONENT_CONSUMABLES': 'componentConsumables'
  };
  static String camel(String key) =>
      key.replaceAllMapped(RegExp(r'_([a-z0-9])'), (m) => m[1]!.toUpperCase());
  static Map<String, dynamic> transform(Map<String, dynamic> extracted) {
    keys(extracted, 'xlsx', ['sha256', 'sheets']);
    final sheets = object(extracted['sheets'], 'sheets');
    keys(sheets, 'sheets', columns.keys.toList());
    final rows = <String, List<Map<String, dynamic>>>{};
    for (final name in columns.keys) {
      final sheet = object(sheets[name], name);
      keys(sheet, name, ['columns', 'rows']);
      final required = columns[name]!.split(' ');
      final optional = name == 'COMPATIBILITIES'
          ? ['from_family_id', 'to_family_id']
          : <String>[];
      final headers = strings(sheet['columns'], '$name.columns');
      keys({for (final h in headers) h: ''}, name, required, optional);
      rows[name] = array(sheet['rows'], name).map((v) {
        final r = object(v, name);
        keys(r, name, headers);
        for (final field in headers) {
          optionalText(r[field], '$name.$field');
        }
        return r;
      }).toList();
    }
    final metadata = <String, dynamic>{};
    final metadataNotes = <String, dynamic>{};
    for (final r in rows['README']!) {
      final key = textValue(r['key'], 'README.key');
      if (metadata.containsKey(key)) {
        throw KnowledgeError('README', 'clave repetida $key');
      }
      metadata[key] = r['value'];
      if (r['notes'] != '') metadataNotes['note.$key'] = r['notes'];
    }
    if (metadata['schema_version'] != '1' ||
        metadata['status'] != 'development' ||
        metadata['locale'] != 'es-MX') {
      throw KnowledgeError(
          'README', 'maestro incompatible; solo development schema 1 es-MX');
    }
    for (final key in metadataNotes.keys) {
      if (metadata.containsKey(key)) {
        throw KnowledgeError('README', 'clave reservada $key');
      }
    }
    final output = <String, dynamic>{};
    for (final name in names.keys) {
      final target = names[name]!;
      final records = <Map<String, dynamic>>[];
      for (final row in rows[name]!) {
        final r = <String, dynamic>{};
        final idColumn = columns[name]!.split(' ').first;
        for (final field in row.keys) {
          if (name == 'COMPATIBILITIES' &&
              (field.startsWith('from_') || field.startsWith('to_'))) {
            continue;
          }
          r[field == idColumn ? 'id' : camel(field)] = row[field];
        }
        if (name == 'SPECIFICATIONS') {
          if (!['0', '1'].contains(row['critical'])) {
            throw KnowledgeError(r['id'] as String, 'critical debe ser 0 o 1');
          }
          r['critical'] = row['critical'] == '1';
        }
        if (name == 'COMPATIBILITIES') {
          for (final side in ['from', 'to']) {
            final endpoints = [
              for (final type in ['component', 'standard', 'family'])
                if ((row['${side}_${type}_id'] ?? '') != '')
                  {'type': type, 'id': row['${side}_${type}_id']}
            ];
            if (endpoints.length != 1) {
              throw KnowledgeError(
                  r['id'] as String, '$side requiere exactamente un endpoint');
            }
            r[side] = endpoints.single;
          }
        }
        records.add(r);
      }
      final count = metadata['count.${name.toLowerCase()}'];
      if (count != null && count != records.length.toString()) {
        throw KnowledgeError(
            name, 'conteo distinto al declarado: $count != ${records.length}');
      }
      output[target] = records;
    }
    return ComponentImport.transform({
      'formatVersion': 2,
      'contentVersion': metadata['content_version'],
      'status': metadata['status'],
      'sheets': output,
      'editorial': {
        'sourceFile': 'BiciFirme_Componentes_Master.xlsx',
        'sha256': extracted['sha256'],
        'metadata': {...metadata, ...metadataNotes}
      }
    }, allowDevelopment: true);
  }
}
