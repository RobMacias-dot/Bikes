import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/diagnostic.dart';

final garageProvider =
    StateNotifierProvider<GarageNotifier, List<Bike>>((_) => GarageNotifier());

class GarageNotifier extends StateNotifier<List<Bike>> {
  GarageNotifier() : super(const []);
  void add(Bike bike) => state = [...state, bike];
}

class GaragePage extends ConsumerWidget {
  const GaragePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(garageProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi garaje')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
            context: context, builder: (_) => const _BikeDialog()),
        icon: const Icon(Icons.add),
        label: const Text('Añadir bicicleta'),
      ),
      body: bikes.isEmpty
          ? const Center(
              child: Text(
                  'Aún no hay bicicletas. Añade una para reutilizar sus datos.'))
          : ListView.builder(
              itemCount: bikes.length,
              itemBuilder: (context, index) {
                final bike = bikes[index];
                final brand = bike.brand.isEmpty ? '' : ' · ${bike.brand}';
                return ListTile(
                  leading: const Icon(Icons.pedal_bike),
                  title: Text(bike.name),
                  subtitle: Text('${bike.type}$brand'),
                );
              },
            ),
    );
  }
}

class _BikeDialog extends ConsumerStatefulWidget {
  const _BikeDialog();
  @override
  ConsumerState<_BikeDialog> createState() => _BikeDialogState();
}

class _BikeDialogState extends ConsumerState<_BikeDialog> {
  static const _types = <String>[
    'urbana',
    'hibrida',
    'ruta',
    'gravel',
    'mtb_ht',
    'mtb_full',
    'ebike_urbana',
    'ebike_mtb',
    'otra'
  ];
  final _nameController = TextEditingController();
  String _type = _types.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva bicicleta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre')),
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: _types
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    ref.read(garageProvider.notifier).add(Bike(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        type: _type));
    Navigator.of(context).pop();
  }
}
