import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/diagnostic.dart';

class KnowledgeRepository {
  Future<List<DiagnosticScenario>> loadScenarios() async {
    final raw = await rootBundle.loadString('assets/knowledge/v1/catalog.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['scenarios'] as List)
        .cast<Map<String, dynamic>>()
        .map(DiagnosticScenario.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> loadCatalog() async => jsonDecode(
          await rootBundle.loadString('assets/knowledge/v1/catalog.json'))
      as Map<String, dynamic>;
}
