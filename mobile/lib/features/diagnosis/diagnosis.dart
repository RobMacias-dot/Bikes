import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/knowledge/knowledge_repository.dart';
import '../../domain/entities/diagnostic.dart';
import '../../domain/services/diagnostic_engine.dart';
import '../reports/report_page.dart';

final scenariosProvider = FutureProvider<List<DiagnosticScenario>>(
  (_) => KnowledgeRepository().loadScenarios(),
);

class DiagnosisPage extends ConsumerStatefulWidget {
  const DiagnosisPage({super.key});
  @override
  ConsumerState<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends ConsumerState<DiagnosisPage> {
  static const _noRedFlag = 'none';
  int _step = 0;
  AffectedSystem? _system;
  DiagnosticScenario? _scenario;
  String _triageChoice = _noRedFlag;
  final _brandController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = ref.watch(scenariosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
      body: scenarios.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('No se pudo cargar el conocimiento: $error'),
        ),
        data: (allScenarios) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: (_step + 1) / 4),
              const SizedBox(height: 18),
              Expanded(child: _question(allScenarios)),
              _navigationBar(allScenarios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigationBar(List<DiagnosticScenario> scenarios) {
    return Row(
      children: [
        if (_step > 0)
          TextButton(
            onPressed: () => setState(() => _step--),
            child: const Text('Regresar'),
          ),
        const Spacer(),
        FilledButton(
          onPressed: _canContinue ? () => _next(scenarios) : null,
          child: Text(_step == 3 ? 'Ver resultado' : 'Continuar'),
        ),
      ],
    );
  }

  bool get _canContinue => switch (_step) {
        0 => _system != null,
        1 => _scenario != null,
        _ => true,
      };

  Widget _question(List<DiagnosticScenario> scenarios) => switch (_step) {
        0 => _systems(),
        1 => _symptoms(scenarios),
        2 => _triage(),
        _ => _details(),
      };

  Widget _systems() {
    return RadioGroup<AffectedSystem>(
      groupValue: _system,
      onChanged: (value) => setState(() => _system = value),
      child: ListView(
        children: [
          Text('¿Qué sistema presenta el problema?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...AffectedSystem.values.map(
            (system) => _radioOption<AffectedSystem>(
              value: system,
              label: _systemLabel(system),
              onTap: () => setState(() => _system = system),
            ),
          ),
        ],
      ),
    );
  }

  Widget _symptoms(List<DiagnosticScenario> scenarios) {
    final choices = scenarios.where((item) => item.system == _system).toList();
    return RadioGroup<DiagnosticScenario>(
      groupValue: _scenario,
      onChanged: (value) => setState(() => _scenario = value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selecciona el síntoma principal',
              style: Theme.of(context).textTheme.headlineSmall),
          Expanded(
            child: ListView.builder(
              itemCount: choices.length,
              itemBuilder: (context, index) {
                final item = choices[index];
                return _radioOption<DiagnosticScenario>(
                  value: item,
                  label: item.label,
                  onTap: () => setState(() => _scenario = item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _triage() {
    const options = <(String, String)>[
      (_noRedFlag, 'Ninguna'),
      ('brakes', 'Pérdida total de frenado'),
      ('steering', 'Dirección suelta/trabada'),
      ('structure', 'Grieta o impacto fuerte'),
      ('battery', 'Batería caliente, hinchada, olor o humo'),
      ('wet_electric', 'Componente eléctrico mojado'),
    ];
    return RadioGroup<String>(
      groupValue: _triageChoice,
      onChanged: (value) {
        if (value != null) {
          setState(() => _triageChoice = value);
        }
      },
      child: ListView(
        children: [
          Text('Triaje de seguridad',
              style: Theme.of(context).textTheme.headlineSmall),
          const Text('Cualquier bandera roja impide continuar con el uso.'),
          const SizedBox(height: 12),
          ...options.map(
            (option) => _radioOption<String>(
              value: option.$1,
              label: option.$2,
              onTap: () => setState(() => _triageChoice = option.$1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Identificación del componente',
            style: Theme.of(context).textTheme.headlineSmall),
        const Text(
            'La compatibilidad no se deduce por marca. Escribe marca, modelo o serie si se conoce.'),
        TextField(
            controller: _brandController,
            decoration:
                const InputDecoration(labelText: 'Marca / modelo (opcional)')),
      ],
    );
  }

  Widget _radioOption<T>(
      {required T value, required String label, required VoidCallback onTap}) {
    return ListTile(
        leading: Radio<T>(value: value), title: Text(label), onTap: onTap);
  }

  void _next(List<DiagnosticScenario> scenarios) {
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    final result = const DiagnosticEngine().diagnose(
      scenario: _scenario!,
      redFlag: _triageChoice == _noRedFlag ? null : _triageChoice,
      brand: _brandController.text,
    );
    Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ReportPage(result: result)));
  }

  String _systemLabel(AffectedSystem system) => switch (system) {
        AffectedSystem.wheels => 'Ruedas y neumáticos',
        AffectedSystem.brakes => 'Frenos',
        AffectedSystem.drivetrain => 'Transmisión',
        AffectedSystem.steering => 'Dirección y cockpit',
        AffectedSystem.suspension => 'Suspensión',
        AffectedSystem.frame => 'Cuadro y pivotes',
        AffectedSystem.electric => 'Motor, batería y eléctrico',
      };
}
