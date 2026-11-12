import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gestionnaire_de_mot_de_passe/features/vault/data/datasources/vault_local_data_source.dart';
import 'package:gestionnaire_de_mot_de_passe/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:gestionnaire_de_mot_de_passe/features/vault/domain/entities/password_entry.dart';

void main() {
  late Directory dir;
  late VaultLocalDataSource dataSource;
  late VaultRepositoryImpl repo;

  final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
  final now = DateTime(2026, 11, 7);

  PasswordEntry sample() => PasswordEntry(
        id: '1',
        title: 'Mon site',
        username: 'sidi',
        password: 'MotDePasseTresSecret42',
        createdAt: now,
        updatedAt: now,
        passwordChangedAt: now,
      );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('vault_test');
    Hive.init(dir.path);
    dataSource = VaultLocalDataSource();
    await dataSource.open(key);
    repo = VaultRepositoryImpl(dataSource);
  });

  tearDown(() async {
    await dataSource.close();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('enregistrer, relire et supprimer une entrée', () async {
    await repo.save(sample());
    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.first.password, 'MotDePasseTresSecret42');

    await repo.delete('1');
    expect(await repo.getAll(), isEmpty);
  });

  test('le fichier sur disque ne contient pas le mot de passe en clair',
      () async {
    await repo.save(sample());
    await dataSource.close();

    final file = File('${dir.path}/vault_entries.hive');
    final content = String.fromCharCodes(await file.readAsBytes());
    expect(content.contains('MotDePasseTresSecret42'), isFalse);
    expect(content.contains('sidi'), isFalse);
  });
}