import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/entities/password_entry.dart';
import 'vault_providers.dart';

class VaultController extends AsyncNotifier<List<PasswordEntry>> {
  @override
  Future<List<PasswordEntry>> build() async {
    // Se reconstruit à chaque changement de statut : vide quand verrouillé.
    final status = ref.watch(authControllerProvider.select((s) => s.status));
    if (status != AuthStatus.unlocked) return const [];
    return ref.read(vaultRepositoryProvider).getAll();
  }

  Future<void> save(PasswordEntry entry) async {
    final repo = ref.read(vaultRepositoryProvider);
    await repo.save(entry);
    state = AsyncData(await repo.getAll());
  }

  Future<void> delete(String id) async {
    final repo = ref.read(vaultRepositoryProvider);
    await repo.delete(id);
    state = AsyncData(await repo.getAll());
  }
}

final vaultControllerProvider =
    AsyncNotifierProvider<VaultController, List<PasswordEntry>>(
        VaultController.new);