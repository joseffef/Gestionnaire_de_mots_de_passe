import 'dart:convert';

import 'package:gestionnaire_de_mot_de_passe/features/vault/data/datasources/vault_local_data_source.dart';

import '../../domain/entities/password_entry.dart';
import '../../domain/repositories/vault_repository.dart';
import '../models/password_entry_mapper.dart';

class VaultRepositoryImpl implements VaultRepository {
  VaultRepositoryImpl(this._dataSource);

  final VaultLocalDataSource _dataSource;

  @override
  Future<List<PasswordEntry>> getAll() async {
    return _dataSource
        .readAll()
        .map((s) => PasswordEntryMapper.fromMap(
            jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(PasswordEntry entry) =>
      _dataSource.write(entry.id, jsonEncode(PasswordEntryMapper.toMap(entry)));

  @override
  Future<void> delete(String id) => _dataSource.remove(id);
}