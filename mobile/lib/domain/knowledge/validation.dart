// Strict readers shared by editorial tools and the offline runtime.
class KnowledgeError extends FormatException {
  KnowledgeError(String path, String reason) : super('$path: $reason');
}

Map<String, dynamic> object(Object? value, String path) {
  if (value is! Map<String, dynamic>) {
    throw KnowledgeError(path, 'se esperaba un objeto');
  }
  return value;
}

void keys(Map<String, dynamic> value, String path, List<String> required,
    [List<String> optional = const []]) {
  for (final key in required) {
    if (!value.containsKey(key)) throw KnowledgeError(path, 'falta $key');
  }
  for (final key in value.keys) {
    if (!required.contains(key) && !optional.contains(key)) {
      throw KnowledgeError(path, 'campo desconocido $key');
    }
  }
}

String textValue(Object? value, String path) {
  if (value is! String || value.trim().isEmpty || value.length > 8000) {
    throw KnowledgeError(path, 'texto vacío o no válido');
  }
  return value;
}

String identifier(Object? value, String path) {
  final id = textValue(value, path);
  if (!RegExp(r'^[a-z][a-z0-9_.-]{0,95}$').hasMatch(id)) {
    throw KnowledgeError(path, 'ID no válido');
  }
  return id;
}

String optionalText(Object? value, String path) {
  if (value == '') return '';
  return textValue(value, path);
}

String unitValue(Object? value, String path) {
  final unit = optionalText(value, path);
  if (['none', 'n/a', 'not-applicable'].contains(unit.trim().toLowerCase())) {
    throw KnowledgeError(path, 'no usar unidades ficticias; dejar vacío');
  }
  return unit;
}

List<dynamic> array(Object? value, String path) {
  if (value is! List || value.length > 10000) {
    throw KnowledgeError(path, 'lista no válida');
  }
  return value;
}

List<String> strings(Object? value, String path) {
  final result = array(value, path).map((v) => textValue(v, path)).toList();
  if (result.toSet().length != result.length) {
    throw KnowledgeError(path, 'valores repetidos');
  }
  return List.unmodifiable(result);
}

String oneOf(Object? value, String path, List<String> values) {
  final result = textValue(value, path);
  if (!values.contains(result)) {
    throw KnowledgeError(path, 'valor no admitido: $result');
  }
  return result;
}

Map<String, T> indexed<T>(List<T> items, String Function(T) id, String path) {
  final result = <String, T>{};
  for (final item in items) {
    if (result.containsKey(id(item))) {
      throw KnowledgeError(path, 'ID repetido ${id(item)}');
    }
    result[id(item)] = item;
  }
  return Map.unmodifiable(result);
}

void reference(String id, Map<String, dynamic> values, String path) {
  if (!values.containsKey(id)) {
    throw KnowledgeError(path, 'referencia inexistente $id');
  }
}

class Edition {
  Edition(Map<String, dynamic> json, String expectedKind,
      {required bool allowDevelopment}) {
    if (json['schemaVersion'] is! int || json['schemaVersion'] != 2) {
      throw KnowledgeError(expectedKind, 'schemaVersion no soportada');
    }
    if (json['kind'] != expectedKind) {
      throw KnowledgeError(expectedKind, 'tipo de catálogo incorrecto');
    }
    version = textValue(json['contentVersion'], '$expectedKind.contentVersion');
    if (!RegExp(r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$')
        .hasMatch(version)) {
      throw KnowledgeError(expectedKind, 'versión semántica no válida');
    }
    status = oneOf(
        json['status'], '$expectedKind.status', ['approved', 'development']);
    if (status == 'development' && !allowDevelopment) {
      throw KnowledgeError(expectedKind, 'fixtures prohibidos en producción');
    }
  }
  late final String version, status;
  bool get development => status == 'development';
}

class SourceReference {
  SourceReference(Map<String, dynamic> j) {
    keys(j, 'source', [
      'id',
      'publisher',
      'document',
      'revision',
      'url',
      'section',
      'reviewedAt'
    ], [
      'sourceType',
      'notes'
    ]);
    for (final field in ['sourceType', 'notes']) {
      if (j.containsKey(field)) optionalText(j[field], 'source.$field');
    }
    sourceType = j['sourceType'] as String? ?? '';
    notes = j['notes'] as String? ?? '';
    id = identifier(j['id'], 'source.id');
    publisher = textValue(j['publisher'], 'source.publisher');
    document = textValue(j['document'], 'source.document');
    revision = textValue(j['revision'], 'source.revision');
    section = textValue(j['section'], 'source.section');
    url = textValue(j['url'], 'source.url');
    final parsedUrl = Uri.tryParse(url);
    if (parsedUrl == null ||
        parsedUrl.scheme != 'https' ||
        parsedUrl.host.isEmpty) {
      throw KnowledgeError(id, 'URL HTTPS requerida');
    }
    reviewedAt = textValue(j['reviewedAt'], 'source.reviewedAt');
    final date = reviewedAt;
    final parsed = DateTime.tryParse(date);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        parsed == null ||
        parsed.toIso8601String().substring(0, 10) != date) {
      throw KnowledgeError(id, 'fecha inválida');
    }
  }
  late final String id, publisher, document, revision, url, section, reviewedAt;
  late final String sourceType, notes;
}
