import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers.dart';
import '../features/repairs/problems_page.dart';
import '../features/garage/garage.dart';

final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const HomePage()),
  GoRoute(path: '/garage', builder: (_, __) => const GaragePage()),
  GoRoute(
      path: '/diagnosis',
      builder: (_, state) => ProblemsPage(
          useBike: state.uri.queryParameters['guest'] != '1',
          initialQuery: state.uri.queryParameters['q'] ?? ''))
]);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(bikesProvider);
    final activeId = ref.watch(activeBikeIdProvider).valueOrNull;
    final items = bikes.valueOrNull ?? [];
    final selected = items.where((bike) => bike.id == activeId).firstOrNull;
    return Scaffold(
        appBar: AppBar(title: const Text('BiciFirme'), actions: [
          IconButton(
              tooltip: 'Acerca de',
              onPressed: () => showAboutDialog(
                      context: context,
                      applicationName: 'BiciFirme',
                      applicationVersion: '0.1.0',
                      children: const [
                        Text('Una app de RobMac'),
                        SizedBox(height: 12),
                        Text(
                            'Asistente de bicicletas sin conexión. Sin cuentas, anuncios ni telemetría.'),
                        SizedBox(height: 12),
                        Text(
                            'Versión en desarrollo. La migración a reparaciones guiadas todavía está en curso.')
                      ]),
              icon: const Icon(Icons.info_outline))
        ]),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  Text('Tu bici.\nLista para rodar.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const Text(
                      'Consulta un problema y guarda los datos de tus bicicletas, incluso sin señal.'),
                  const SizedBox(height: 28),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(Icons.pedal_bike),
                                    title: Text('Bicicleta activa')),
                                bikes.when(
                                    loading: () =>
                                        const LinearProgressIndicator(),
                                    error: (_, __) => TextButton(
                                        onPressed: () => refreshBikes(ref),
                                        child: const Text(
                                            'No se pudo abrir el garaje. Reintentar')),
                                    data: (all) => DropdownButtonFormField<
                                            String>(
                                        key: ValueKey(
                                            '${activeId}_${all.length}'),
                                        initialValue: selected?.id ?? '',
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                            labelText: 'Usar datos de'),
                                        items: [
                                          const DropdownMenuItem(
                                              value: '',
                                              child: Text(
                                                  'Sin bicicleta registrada')),
                                          for (final bike in all)
                                            DropdownMenuItem(
                                                value: bike.id,
                                                child: Text(bike.name,
                                                    overflow:
                                                        TextOverflow.ellipsis))
                                        ],
                                        onChanged: (id) async {
                                          if (id == null) return;
                                          try {
                                            await ref
                                                .read(bikeRepositoryProvider)
                                                .setPreference(
                                                    'activeBike', id);
                                            refreshBikes(ref);
                                          } catch (_) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'No se pudo cambiar de bicicleta.')));
                                            }
                                          }
                                        })),
                                TextButton(
                                    onPressed: () => context.push('/garage'),
                                    child: const Text(
                                        'Administrar mis bicicletas')),
                              ]))),
                  const SizedBox(height: 24),
                  TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) => context.push(
                          '/diagnosis?q=${Uri.encodeQueryComponent(query)}'),
                      decoration: const InputDecoration(
                          labelText: 'Buscar un problema',
                          prefixIcon: Icon(Icons.search))),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                      onPressed: () => context.push('/diagnosis'),
                      icon: const Icon(Icons.build_outlined),
                      label: const Text('Resolver un problema')),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () => context.push('/diagnosis?guest=1'),
                      child: const Text('Continuar sin registrar bicicleta')),
                  const SizedBox(height: 24),
                  const Row(children: [
                    Icon(Icons.offline_bolt_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Disponible sin conexión')
                  ]),
                ]))));
  }
}
