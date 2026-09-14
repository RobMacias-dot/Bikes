import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../domain/entities/bike.dart';

class GaragePage extends ConsumerWidget {
  const GaragePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(bikesProvider);
    final active = ref.watch(activeBikeIdProvider).valueOrNull;
    final defaultId = ref.watch(defaultBikeIdProvider).valueOrNull;
    return Scaffold(
        appBar: AppBar(title: const Text('Mis bicicletas')),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BikeEditor())),
            icon: const Icon(Icons.add),
            label: const Text('Añadir bicicleta')),
        body: bikes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
                child: TextButton(
                    onPressed: () => refreshBikes(ref),
                    child: const Text(
                        'No se pudieron leer tus bicicletas. Reintentar'))),
            data: (items) => items.isEmpty
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                            'Puedes resolver un problema sin registrar una bicicleta. Añádela cuando quieras guardar sus datos.')))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                        for (final bike in items)
                          Card(
                              child: Column(children: [
                            ListTile(
                                leading: const Icon(Icons.pedal_bike),
                                title: Text(bike.name),
                                subtitle: Text(
                                    '${bike.type}${defaultId == bike.id ? ' · Predeterminada' : ''}'),
                                trailing: IconButton(
                                    tooltip: 'Editar bicicleta',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                            builder: (_) =>
                                                BikeEditor(bike: bike))))),
                            Wrap(spacing: 8, children: [
                              TextButton(
                                  onPressed: () => _select(
                                      context, ref, 'activeBike', bike.id),
                                  child: Text(active == bike.id
                                      ? 'Bicicleta activa'
                                      : 'Usar esta bicicleta')),
                              if (defaultId != bike.id)
                                TextButton(
                                    onPressed: () => _select(
                                        context, ref, 'defaultBike', bike.id),
                                    child: const Text('Hacer predeterminada')),
                            ]),
                          ])),
                      ])));
  }

  Future<void> _select(
      BuildContext context, WidgetRef ref, String key, String id) async {
    try {
      await ref.read(bikeRepositoryProvider).setPreference(key, id);
      refreshBikes(ref);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo guardar el cambio.')));
      }
    }
  }
}

class BikeEditor extends ConsumerStatefulWidget {
  const BikeEditor({super.key, this.bike});
  final Bike? bike;
  @override
  ConsumerState<BikeEditor> createState() => _BikeEditorState();
}

class _BikeEditorState extends ConsumerState<BikeEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  final Map<String, TextEditingController> _fields = {};
  late String _type, _brakes, _tires;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.bike?.name);
    _type = widget.bike?.type ?? Bike.types.first;
    _brakes = widget.bike?.value('brakes') ?? 'No sé';
    _tires = widget.bike?.value('tires') ?? 'No sé';
    if (!Bike.brakeTypes.contains(_brakes)) _brakes = 'No sé';
    if (!Bike.tireTypes.contains(_tires)) _tires = 'No sé';
    for (final key in [
      'transmission',
      'brand',
      'model',
      'year',
      'wheel',
      'drivetrainFamily',
      'brakeFamily',
      'notes',
      'usage'
    ]) {
      _fields[key] = TextEditingController(text: widget.bike?.value(key));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title:
              Text(widget.bike == null ? 'Nueva bicicleta' : 'Mi bicicleta')),
      body: Form(
          key: _form,
          child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                    'Empieza con lo que sabes. Puedes completar los componentes después.'),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                        labelText: 'Nombre de tu bicicleta'),
                    maxLength: 80,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Escribe un nombre'
                        : null),
                _choice('Tipo', _type, Bike.types, (v) => _type = v),
                _choice('Frenos', _brakes, Bike.brakeTypes, (v) => _brakes = v),
                _choice('Llanta / neumático', _tires, Bike.tireTypes,
                    (v) => _tires = v),
                TextButton.icon(
                    onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const AlertDialog(
                            title: Text('Ayúdame a identificarlo'),
                            content: SingleChildScrollView(
                                child: Text(
                                    'Freno de rin: las zapatas tocan los lados del rin.\n\nDisco mecánico: un cable mueve una palanca en la pinza junto al centro de la rueda.\n\nHidráulico: una manguera entra en la pinza; no hay un cable expuesto que accione una palanca.\n\nLa válvula por sí sola no confirma si tienes cámara o tubeless. Si no conoces el montaje, elige «No sé».\n\nTransmisión: cuenta los platos delanteros y los piñones traseros. Un plato y once piñones se escribe 1x11. Esto no identifica por sí solo la compatibilidad de una cadena.')))),
                    icon: const Icon(Icons.help_outline),
                    label: const Text('Ayúdame a identificarlo')),
                _field(
                    'transmission', 'Transmisión (por ejemplo 1x11 o No sé)'),
                ExpansionTile(
                    title: const Text(
                        'Marca, componentes y otros datos opcionales'),
                    children: [
                      _field('brand', 'Marca'),
                      _field('model', 'Modelo'),
                      _field('year', 'Año'),
                      _field('wheel', 'Medida escrita en la llanta'),
                      _field('drivetrainFamily', 'Familia de transmisión'),
                      _field('brakeFamily', 'Familia de frenos'),
                      _field('usage', 'Uso: ocasional, semanal o intenso'),
                      _field('notes', 'Notas'),
                    ]),
                const SizedBox(height: 24),
                FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Guardando…' : 'Guardar bicicleta')),
              ])));
  Widget _field(String key, String label) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
          controller: _fields[key],
          maxLength: key == 'notes' ? 2000 : 120,
          decoration: InputDecoration(labelText: label)));
  Widget _choice(String label, String value, List<String> values,
          void Function(String) update) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
              initialValue: value,
              isExpanded: true,
              decoration: InputDecoration(labelText: label),
              items: values
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => update(v));
              }));
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(bikeRepositoryProvider).save(Bike(
              id: widget.bike?.id ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              name: _name.text,
              type: _type,
              profile: {
                ...?widget.bike?.profile,
                'brakes': _brakes,
                'tires': _tires,
                for (final entry in _fields.entries)
                  entry.key: entry.value.text.trim(),
              }));
      refreshBikes(ref);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'No se pudo guardar. Tus datos siguen en el formulario.')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
