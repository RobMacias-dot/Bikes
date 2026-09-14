import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/bike.dart';
import 'database/local_database.dart';
import 'database/bike_repository.dart';

final databaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase.device();
  ref.onDispose(db.close);
  return db;
});
final bikeRepositoryProvider =
    Provider((ref) => BikeRepository(ref.watch(databaseProvider)));
final bikesProvider = FutureProvider<List<Bike>>(
    (ref) => ref.watch(bikeRepositoryProvider).list());
final activeBikeIdProvider = FutureProvider<String?>(
    (ref) => ref.watch(bikeRepositoryProvider).preference('activeBike'));
final defaultBikeIdProvider = FutureProvider<String?>(
    (ref) => ref.watch(bikeRepositoryProvider).preference('defaultBike'));
void refreshBikes(WidgetRef ref) {
  ref.invalidate(bikesProvider);
  ref.invalidate(activeBikeIdProvider);
  ref.invalidate(defaultBikeIdProvider);
}
