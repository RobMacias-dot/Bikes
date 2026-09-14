import 'dart:convert';
import 'dart:io';
import 'package:bike_expert/domain/knowledge/knowledge_bundle.dart';

Map<String, dynamic> fixtureJson(String file,
        {String edition = 'development'}) =>
    jsonDecode(File('assets/knowledge/$edition/$file.json').readAsStringSync())
        as Map<String, dynamic>;
KnowledgeBundle fixtureBundle() => KnowledgeBundle.parse(
    fixtureJson('manifest'), fixtureJson('components'), fixtureJson('repairs'),
    allowDevelopment: true);
Map<String, dynamic> firstProcedure(Map<String, dynamic> json) =>
    (json['procedures'] as List).first as Map<String, dynamic>;
Map<String, dynamic> node(Map<String, dynamic> json, String id) =>
    (firstProcedure(json)['nodes'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((n) => n['id'] == id);
