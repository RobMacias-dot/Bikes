/// Punto de integración para SQLite/Drift. Los repositorios de dominio no
/// dependen de esta clase y podrán sustituirse por una sincronización remota.
/// La generación de tablas Drift se añade cuando se habiliten DTOs definitivos.
abstract interface class LocalDatabase {
  Future<void> open();
  Future<void> close();
}
