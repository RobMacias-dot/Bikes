import 'repair_visual.dart';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

import '../../domain/entities/bike.dart';

import '../../domain/knowledge/repair_catalog.dart';

import '../../domain/knowledge/repair_session.dart';

import 'problems_page.dart';

class RepairPage extends ConsumerStatefulWidget {
  const RepairPage(
      {super.key, required this.procedure, required this.contextId, this.bike});

  final RepairProcedure procedure;

  final String contextId;

  bool get development => procedure.development;

  final Bike? bike;

  @override
  ConsumerState<RepairPage> createState() => _RepairPageState();
}

class _RepairPageState extends ConsumerState<RepairPage> {
  late final RepairSession _session;

  bool _checked = false, _saveFact = false, _busy = false;

  @override
  void initState() {
    super.initState();

    _session = RepairSession(widget.procedure,
        context: widget.contextId,
        facts: factsFromBike(widget.bike,
            identifications: widget.procedure.nodes.values
                .map((n) => n.identification)
                .whereType<Identification>()),
        allowDevelopment: kDebugMode);
  }

  @override
  Widget build(BuildContext context) {
    final node = _session.current;

    final outcome = _session.visibleOutcome;

    final choices = [...node.choices];

    if (node.kind == NodeKind.safetyCheck) {
      final focus = widget.procedure.safetyFocus;

      choices.sort((a, b) => (focus.contains(a.hardStop) ? 0 : 1)
          .compareTo(focus.contains(b.hardStop) ? 0 : 1));
    }

    return Scaffold(
        appBar: AppBar(
            title: Text(widget.development && !widget.procedure.pilot
                ? 'Simulación de reparación'
                : 'Reparación guiada')),
        body: ListView(
            key: ValueKey(node.id),
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.development)
                DevelopmentNotice(pilot: widget.procedure.pilot),
              Text(widget.procedure.title,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                  '${widget.bike?.name ?? 'Modo invitado'} · ${widget.contextId == 'route' ? 'En ruta' : 'En casa / taller'}'),
              if (widget.bike != null)
                const Text(
                    'Se reutilizan únicamente datos identificados del perfil.'),
              const SizedBox(height: 16),
              ExpansionTile(
                  title: const Text('Qué ocurre y qué necesitas'),
                  children: [
                    ListTile(title: Text(widget.procedure.problem)),
                    ListTile(
                        title: const Text('Riesgo y tiempo aproximado'),
                        subtitle: Text('${switch (widget.procedure.risk) {
                          'low' => 'Bajo',
                          'moderate' => 'Moderado',
                          _ => 'Alto'
                        }} · ${widget.procedure.estimatedMinutes == null ? 'Sin estimación (simulación)' : '${widget.procedure.estimatedMinutes!.$1}–${widget.procedure.estimatedMinutes!.$2} min'}')),
                    ListTile(
                        title: const Text('Herramientas'),
                        subtitle: Text(widget.procedure.tools.isEmpty
                            ? 'No se requieren herramientas para esta comprobación.'
                            : widget.procedure.tools.join('\n'))),
                    ListTile(
                        title: const Text('Consumibles'),
                        subtitle: Text(widget.procedure.consumables.isEmpty
                            ? 'No se requieren consumibles en este procedimiento.'
                            : widget.procedure.consumables.join('\n'))),
                    for (final source in widget.procedure.sourceReferences)
                      ListTile(
                          title:
                              Text('${source.publisher}: ${source.document}'),
                          subtitle: SelectableText(
                              '${source.section}\n${source.url}')),
                  ]),
              const SizedBox(height: 16),
              if (outcome != null) ...[
                Card(
                    color: _color(context, outcome),
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${widget.development && !widget.procedure.pilot ? 'Simulación: ' : ''}${_label(outcome)}',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 12),
                              Text(node.text),
                              if (outcome == VisibleRepairOutcome.temporary)
                                const Text(
                                    'Solución temporal. La bicicleta todavía necesita reparación completa.'),
                              for (final restriction in node.restrictions)
                                Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('• $restriction')),
                            ]))),
                if (widget.bike == null && !widget.development)
                  const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                          'Guarda los datos de tu bici para que la próxima vez sea más rápido.')),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver a problemas')),
              ] else ...[
                Text(node.text, style: Theme.of(context).textTheme.titleLarge),
                for (final id in node.visualIds) RepairVisual(id: id),
                if (node.details != null)
                  ExpansionTile(
                      title: const Text('Detalles técnicos'),
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(node.details!))
                      ]),
                if (node.kind == NodeKind.identify &&
                    widget.bike != null &&
                    !widget.development)
                  CheckboxListTile(
                      value: _saveFact,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _saveFact = v ?? false),
                      title: const Text('Guardar este dato en mi bicicleta')),
                if (node.kind == NodeKind.identify && widget.development)
                  const Text(
                      'Las respuestas de esta simulación no se guardarán en tu bicicleta.'),
                const SizedBox(height: 16),
                if (node.kind == NodeKind.safetyCheck)
                  Text(widget.contextId == 'route'
                      ? 'Antes de seguir en ruta, revisa estas señales. Cualquiera obliga a detenerse.'
                      : 'Antes de intervenir en el taller, revisa estas señales. Una bandera roja impide continuar este procedimiento.'),
                for (final choice in choices)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OutlinedButton(
                          onPressed: _busy ? null : () => _choose(choice),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(choice.label)))),
                if (node.kind == NodeKind.step && widget.procedure.pilot)
                  FilledButton(
                      onPressed: () => setState(() {
                            _session.completeStep(checked: true);
                          }),
                      child: const Text('Paso hecho · continuar')),
                if (node.kind == NodeKind.step && !widget.procedure.pilot) ...[
                  CheckboxListTile(
                      value: _checked,
                      onChanged: (v) => setState(() => _checked = v ?? false),
                      title: Text(widget.development && !widget.procedure.pilot
                          ? 'He completado el paso simulado'
                          : 'He completado este paso')),
                  FilledButton(
                      onPressed: !_checked
                          ? null
                          : () => setState(() {
                                _session.completeStep(checked: _checked);

                                _checked = false;
                              }),
                      child: const Text('Continuar')),
                ],
                if (_session.canGoBack)
                  TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _session.goBack();

                                _checked = false;

                                _saveFact = false;
                              }),
                      child: const Text('Paso anterior')),
                const SizedBox(height: 16),
                TextButton.icon(
                    onPressed: _busy ? null : _reportStop,
                    icon: const Icon(Icons.warning_amber),
                    label: Text(widget.development && !widget.procedure.pilot
                        ? 'Simular una bandera roja ahora'
                        : 'Detecté una señal de detenerse')),
              ],
            ]));
  }

  Future<void> _choose(RepairChoice choice) async {
    setState(() => _busy = true);

    try {
      final definition = _session.current.identification;

      if (_saveFact &&
          !widget.development &&
          widget.bike != null &&
          definition != null &&
          choice.profileValue != 'unknown') {
        await ref.read(bikeRepositoryProvider).saveIdentification(
            widget.bike!.id, definition, choice.profileValue!);

        if (mounted) refreshBikes(ref);
      }

      if (mounted) {
        setState(() {
          _session.choose(choice.id);

          _checked = false;

          _saveFact = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'No se pudo guardar el dato. Puedes reintentar o continuar sin guardarlo.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reportStop() async {
    final flag = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
                child: ListView(shrinkWrap: true, children: [
              for (final item in const {
                'structural_damage': 'Daño estructural',
                'braking_loss': 'Pérdida efectiva de frenado',
                'steering_damage': 'Dirección dañada',
                'critical_part_broken': 'Pieza crítica rota'
              }.entries)
                ListTile(
                    title: Text(item.value),
                    onTap: () => Navigator.pop(context, item.key)),
            ])));

    if (flag != null && mounted) setState(() => _session.reportHardStop(flag));
  }

  String _label(VisibleRepairOutcome outcome) => switch (outcome) {
        VisibleRepairOutcome.complete => 'Reparación completa',
        VisibleRepairOutcome.temporary => 'Solución temporal',
        VisibleRepairOutcome.stop => 'No continuar circulando'
      };

  Color _color(BuildContext context, VisibleRepairOutcome outcome) =>
      switch (outcome) {
        VisibleRepairOutcome.stop =>
          Theme.of(context).colorScheme.errorContainer,
        VisibleRepairOutcome.temporary =>
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xff584500)
              : const Color(0xffffedb3),
        VisibleRepairOutcome.complete =>
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xff153d29)
              : const Color(0xffd5f5dd),
      };
}
