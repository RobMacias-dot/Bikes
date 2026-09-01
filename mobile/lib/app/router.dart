import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/diagnosis/diagnosis.dart';
import '../features/garage/garage.dart';

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const HomePage()),
  GoRoute(path: '/garage', builder: (_, __) => const GaragePage()),
  GoRoute(path: '/diagnosis', builder: (_, __) => const DiagnosisPage())
]);

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Bike Expert')),
      body: Padding(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Diagnóstico de bicicletas sin conexión',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            const Text(
                'Orientación educativa; ante señales de seguridad, suspende el uso y busca revisión profesional.'),
            const Spacer(),
            FilledButton.icon(
                onPressed: () => context.go('/diagnosis'),
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Iniciar diagnóstico')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: () => context.go('/garage'),
                icon: const Icon(Icons.pedal_bike),
                label: const Text('Mi garaje'))
          ])));
}
