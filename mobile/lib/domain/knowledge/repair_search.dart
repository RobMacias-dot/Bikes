import '../entities/bike.dart';
import 'repair_catalog.dart';

String normalizeSearch(String input) {
  var value = input.toLowerCase();
  const accented = 'áéíóúüñ';
  const plain = 'aeiouun';
  for (var i = 0; i < accented.length; i++) {
    value = value.replaceAll(accented[i], plain[i]);
  }
  return value
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class RepairSearch {
  RepairSearch(this.catalog);
  final RepairCatalog catalog;
  List<RepairProcedure> search(String query,
      {Bike? bike, String? context, String? category}) {
    final terms = normalizeSearch(query)
        .split(' ')
        .where((t) =>
            t.isNotEmpty &&
            !const ['el', 'la', 'los', 'las', 'de', 'un', 'una', 'mi', 'se']
                .contains(t))
        .toSet();
    final expanded = <String>{...terms};
    final normalizedQuery = normalizeSearch(query);
    for (final group in catalog.synonyms) {
      final normalized = group.map(normalizeSearch).toList();
      if (normalized.any((phrase) =>
          ' $normalizedQuery '.contains(' $phrase ') ||
          terms.contains(phrase))) {
        for (final phrase in normalized) {
          expanded.addAll(phrase.split(' '));
        }
      }
    }
    final scored = <(RepairProcedure, int)>[];
    for (final p in catalog.procedures.values) {
      if (bike != null &&
          p.bikeTypes.isNotEmpty &&
          !p.bikeTypes.contains(bike.type)) {
        continue;
      }
      if (context != null && !p.contexts.contains(context)) continue;
      if (category != null && p.category != category) continue;
      final title = normalizeSearch(p.title);
      final words =
          normalizeSearch('${p.title} ${p.problem} ${p.terms.join(' ')}')
              .split(' ')
              .toSet();
      final matches = expanded.where(words.contains).length;
      if (terms.isNotEmpty && matches == 0) continue;
      final score = matches +
          terms.where(words.contains).length * 3 +
          (normalizedQuery.isNotEmpty && title.contains(normalizedQuery)
              ? 10
              : 0);
      scored.add((p, score));
    }
    scored.sort((a, b) {
      final order = b.$2.compareTo(a.$2);
      return order != 0 ? order : a.$1.id.compareTo(b.$1.id);
    });
    return scored.map((r) => r.$1).toList();
  }
}
