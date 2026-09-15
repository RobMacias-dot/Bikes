import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/knowledge/repair_knowledge_repository.dart';
import '../../data/providers.dart';
import '../../domain/entities/bike.dart';

import '../../domain/knowledge/repair_search.dart';
import 'repair_page.dart';

const categoryLabels = {
  'wheels': 'Ruedas y llantas',
  'brakes': 'Frenos',
  'drivetrain': 'Cadena y cambios',
  'steering': 'Manubrio y dirección',
  'frame': 'Cuadro'
};

class ProblemsPage extends ConsumerStatefulWidget {
  const ProblemsPage(
      {super.key,
      this.useBike = true,
      this.development = false,
      bool developmentToolsEnabled = kDebugMode,
      this.initialQuery = ''})
      : developmentToolsEnabled = developmentToolsEnabled && kDebugMode;
  final bool useBike, development, developmentToolsEnabled;
  final String initialQuery;
  @override
  ConsumerState<ProblemsPage> createState() => _ProblemsPageState();
}

class _ProblemsPageState extends ConsumerState<ProblemsPage> {
  late final TextEditingController _query;
  late bool _guest;
  String? _context, _category;
  @override
  void initState() {
    super.initState();
    _guest = !widget.useBike;
    _query = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final knowledge = ref.watch(repairKnowledgeProvider(widget.development));
    final bikes =
        _guest ? const AsyncData<List<Bike>>([]) : ref.watch(bikesProvider);
    final active = _guest
        ? const AsyncData<String?>(null)
        : ref.watch(activeBikeIdProvider);
    final bike =
        bikes.valueOrNull?.where((b) => b.id == active.valueOrNull).firstOrNull;
    final ready = !bikes.isLoading &&
        !active.isLoading &&
        !bikes.hasError &&
        !active.hasError;
    return Scaffold(
        appBar: AppBar(title: const Text('Resolver un problema')),
        body: knowledge.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text(
                          'No se pudo validar el conocimiento. No se mostrarán instrucciones de este paquete.'),
                      TextButton(
                          onPressed: () => ref.invalidate(
                              repairKnowledgeProvider(widget.development)),
                          child: const Text('Reintentar'))
                    ]))),
            data: (bundle) {
              final results = RepairSearch(bundle.repairs).search(_query.text,
                  bike: bike, context: _context, category: _category);
              return ListView(padding: const EdgeInsets.all(20), children: [
                if (bundle.repairs.edition.development)
                  DevelopmentNotice(
                      pilot:
                          bundle.repairs.procedures.values.any((p) => p.pilot)),
                Text(
                    bike == null ? 'Modo invitado' : 'Bicicleta: ${bike.name}'),
                if (!ready)
                  const Text(
                      'Esperando los datos de tu bicicleta. Puedes continuar como invitado.'),
                if (!_guest)
                  TextButton(
                      onPressed: () => setState(() => _guest = true),
                      child: const Text('Usar sin datos de bicicleta')),
                const SizedBox(height: 12),
                TextField(
                    controller: _query,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                        labelText: 'Buscar un problema',
                        hintText: 'Cadena brinca, llanta pierde aire…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () => setState(() => _query.clear()),
                            icon: const Icon(Icons.clear)))),
                const SizedBox(height: 20),
                const Text('¿Dónde estás?'),
                Wrap(spacing: 8, children: [
                  ChoiceChip(
                      label: const Text('Estoy en ruta'),
                      selected: _context == 'route',
                      onSelected: (_) => setState(() => _context = 'route')),
                  ChoiceChip(
                      label: const Text('En casa / taller'),
                      selected: _context == 'workshop',
                      onSelected: (_) => setState(() => _context = 'workshop')),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  ChoiceChip(
                      label: const Text('Todos'),
                      selected: _category == null,
                      onSelected: (_) => setState(() => _category = null)),
                  for (final entry in categoryLabels.entries)
                    ChoiceChip(
                        label: Text(entry.value),
                        selected: _category == entry.key,
                        onSelected: (_) =>
                            setState(() => _category = entry.key))
                ]),
                TextButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: const Text('No sé qué tiene'),
                    onPressed: () => _symptom(context)),
                if (bundle.repairs.procedures.isEmpty) ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                          'Todavía no hay guías de reparación aprobadas en esta versión. Tus bicicletas siguen disponibles sin conexión.')),
                  if (widget.developmentToolsEnabled && !widget.development)
                    OutlinedButton.icon(
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Abrir laboratorio de desarrollo'),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => ProblemsPage(
                                    useBike: !_guest,
                                    development: true,
                                    initialQuery: _query.text)))),
                ] else ...[
                  if (_context == null)
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child:
                            Text('Elige ruta o taller para abrir una guía.')),
                  if (results.isEmpty)
                    const Text(
                        'No encontramos ese problema. Prueba otra palabra o cambia la categoría.'),
                  for (final p in results)
                    Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                            title: Text(p.title),
                            subtitle: Text(categoryLabels[p.category]!),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _context == null || !ready
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) => RepairPage(
                                            procedure: p,
                                            contextId: _context!,
                                            bike: bike))))),
                ],
              ]);
            }));
  }

  Future<void> _symptom(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
                child: ListView(shrinkWrap: true, children: [
              const ListTile(title: Text('¿Qué notas?')),
              for (final symptom in [
                'Pedales giran sin avanzar',
                'Disco roza',
                'No frena',
                'Cadena brinca',
                'Llanta pierde aire',
                'Rueda chueca',
                'Cambio no entra'
              ])
                ListTile(
                    title: Text(symptom),
                    onTap: () => Navigator.pop(context, symptom)),
            ])));
    if (selected != null && mounted) {
      setState(() {
        _query.text = selected;
        _category = null;
      });
    }
  }
}

class DevelopmentNotice extends StatelessWidget {
  const DevelopmentNotice({super.key, this.pilot = false});
  final bool pilot;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12)),
      child: Text(pilot
          ? 'LABORATORIO · PILOTO DEVELOPMENT\nContenido mecánico en revisión editorial. No aprobado para publicación; evaluación supervisada. Las respuestas no se guardan en tu bicicleta.'
          : 'LABORATORIO · DATOS DE DESARROLLO\nSimulación de software. No es una guía mecánica aprobada. No realices reparaciones basándote en estos pasos.'));
}
