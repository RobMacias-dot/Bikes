import 'dart:convert';

class Bike {
  Bike(
      {required this.id,
      required String name,
      required this.type,
      Map<String, String> profile = const {}})
      : name = name.trim(),
        profile = Map.unmodifiable(profile) {
    if (id.isEmpty || this.name.isEmpty || !types.contains(type)) {
      throw const FormatException('Nombre o tipo de bicicleta no válido');
    }
  }
  static const types = [
    'MTB',
    'Ruta',
    'Gravel',
    'Urbana',
    'Fixie / single speed'
  ];
  static const brakeTypes = [
    'No sé',
    'De rin con cable',
    'Disco mecánico',
    'Disco hidráulico',
    'Contrapedal / tambor'
  ];
  static const tireTypes = ['No sé', 'Con cámara', 'Tubeless'];
  final String id, name, type;
  final Map<String, String> profile;
  String value(String key) => profile[key] ?? '';
  String get brand => value('brand');
  String get model => value('model');
  String get notes => value('notes');
  Map<String, Object?> toRow() =>
      {'id': id, 'name': name, 'type': type, 'profile': jsonEncode(profile)};
  factory Bike.fromRow(Map<String, dynamic> row) => Bike(
      id: row['id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      profile: Map<String, String>.from(
          jsonDecode(row['profile'] as String) as Map));
}
