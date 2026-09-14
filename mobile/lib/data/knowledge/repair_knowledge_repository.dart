import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/knowledge/knowledge_bundle.dart';
import '../../domain/knowledge/validation.dart';

final repairKnowledgeProvider = FutureProvider.family<KnowledgeBundle, bool>(
    (ref, development) =>
        RepairKnowledgeRepository().load(development: development));

class RepairKnowledgeRepository {
  RepairKnowledgeRepository({AssetBundle? assets})
      : _assets = assets ?? rootBundle;
  final AssetBundle _assets;
  Future<KnowledgeBundle> load({bool development = false}) async {
    // Runtime policy cannot be enabled by a route, imported JSON or dart-define.
    if (development && !kDebugMode) {
      throw KnowledgeError(
          'knowledge', 'laboratorio deshabilitado fuera de debug');
    }
    final folder = development ? 'pilot' : 'approved';
    Future<Map<String, dynamic>> read(String file) async => object(
        jsonDecode(
            await _assets.loadString('assets/knowledge/$folder/$file.json')),
        '$folder/$file');
    final data = await Future.wait(
        [read('manifest'), read('components'), read('repairs')]);
    return KnowledgeBundle.parse(data[0], data[1], data[2],
        allowDevelopment: development && kDebugMode);
  }
}
