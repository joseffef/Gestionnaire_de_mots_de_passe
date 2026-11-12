import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/security_providers.dart';
import '../../../vault/presentation/providers/vault_providers.dart';
import '../../domain/auth_state.dart';

class AuthController extends Notifier<AuthState> {
  static const minPasswordLength = 12;

  @override
  AuthState build() {
    _init();
    return const AuthState(AuthStatus.loading);
  }

  Future<void> _init() async {
    final initialized =
        await ref.read(masterKeyServiceProvider).isInitialized();
    state = AuthState(initialized ? AuthStatus.locked : AuthStatus.needsSetup);
  }

  /// Première utilisation : crée le mot de passe maître et ouvre le coffre.
  Future<void> createMasterPassword(String password) async {
    if (state.busy) return;
    if (password.length < minPasswordLength) {
      state = AuthState(
        state.status,
        error:
            'Le mot de passe maître doit faire au moins $minPasswordLength caractères.',
      );
      return;
    }
    state = AuthState(state.status, busy: true);
    final key =
        await ref.read(masterKeyServiceProvider).createMasterPassword(password);
    await ref.read(vaultDataSourceProvider).open(key);
    state = const AuthState(AuthStatus.unlocked);
  }

  /// Déverrouille le coffre avec le mot de passe maître.
  Future<void> unlock(String password) async {
    if (state.busy) return;
    state = AuthState(state.status, busy: true);
    final key = await ref.read(masterKeyServiceProvider).unlock(password);
    if (key == null) {
      state = const AuthState(AuthStatus.locked,
          error: 'Mot de passe maître incorrect.');
      return;
    }
    await ref.read(vaultDataSourceProvider).open(key);
    state = const AuthState(AuthStatus.unlocked);
  }

  /// Verrouille : ferme la box chiffrée (la clé n'est plus utilisable).
  Future<void> lock() async {
    if (state.status != AuthStatus.unlocked) return;
    await ref.read(vaultDataSourceProvider).close();
    state = const AuthState(AuthStatus.locked);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);