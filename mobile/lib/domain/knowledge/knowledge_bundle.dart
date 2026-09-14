import 'technical_catalog.dart';
import 'repair_catalog.dart';
import 'validation.dart';

class KnowledgeBundle {
  KnowledgeBundle._(this.technical, this.repairs);
  final TechnicalCatalog technical;
  final RepairCatalog repairs;
  factory KnowledgeBundle.parse(Map<String, dynamic> manifest,
      Map<String, dynamic> components, Map<String, dynamic> procedures,
      {bool allowDevelopment = false}) {
    keys(manifest, 'manifest',
        ['schemaVersion', 'componentsVersion', 'repairsVersion']);
    if (manifest['schemaVersion'] is! int || manifest['schemaVersion'] != 2) {
      throw KnowledgeError('manifest', 'versión no soportada');
    }
    final technical =
        TechnicalCatalog.parse(components, allowDevelopment: allowDevelopment);
    final repairs = RepairCatalog.parse(procedures, technical,
        allowDevelopment: allowDevelopment);
    if (manifest['componentsVersion'] != technical.edition.version ||
        manifest['repairsVersion'] != repairs.edition.version) {
      throw KnowledgeError('manifest', 'versiones del paquete no coinciden');
    }
    if (technical.edition.status != repairs.edition.status) {
      throw KnowledgeError(
          'manifest', 'no mezclar contenido aprobado y de desarrollo');
    }
    return KnowledgeBundle._(technical, repairs);
  }
}
