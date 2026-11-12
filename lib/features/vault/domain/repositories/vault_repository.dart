import '../entities/password_entry.dart';

abstract class VaultRepository {
  Future<List<PasswordEntry>> getAll();
  Future<void> save(PasswordEntry entry);
  Future<void> delete(String id);
}