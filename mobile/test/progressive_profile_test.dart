import 'package:bike_expert/data/database/bike_repository.dart';
import 'package:bike_expert/data/database/local_database.dart';
import 'package:bike_expert/domain/entities/bike.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'dato progresivo preserva el perfil más reciente y sobrevive a la lectura',
      () async {
    final db = LocalDatabase(NativeDatabase.memory());
    final repo = BikeRepository(db);
    try {
      await repo.save(Bike(
          id: 'a',
          name: 'Bici',
          type: 'MTB',
          profile: {'notes': 'Nota reciente', 'transmission': '1x12'}));
      await repo.saveProfileFact('a', 'tires', 'Tubeless');
      final saved = (await repo.list()).single;
      expect(saved.value('tires'), 'Tubeless');
      expect(saved.notes, 'Nota reciente');
      expect(saved.value('transmission'), '1x12');
      await expectLater(
          repo.saveProfileFact('a', 'torque', '5'), throwsArgumentError);
      await expectLater(repo.saveProfileFact('missing', 'tires', 'Tubeless'),
          throwsStateError);
      expect((await repo.list()).single.value('tires'), 'Tubeless');
    } finally {
      await db.close();
    }
  });
}
