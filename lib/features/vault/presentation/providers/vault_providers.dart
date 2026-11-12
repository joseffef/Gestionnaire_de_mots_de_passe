import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/vault_local_data_source.dart';
import '../../data/repositories/vault_repository_impl.dart';
import '../../domain/repositories/vault_repository.dart';

final vaultDataSourceProvider =
    Provider<VaultLocalDataSource>((ref) => VaultLocalDataSource());

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepositoryImpl(ref.watch(vaultDataSourceProvider));
});