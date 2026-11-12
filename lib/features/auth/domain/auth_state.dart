enum AuthStatus { loading, needsSetup, locked, unlocked }

class AuthState {
  const AuthState(this.status, {this.busy = false, this.error});

  final AuthStatus status;

  /// Vrai pendant la dérivation de clé (quelques secondes).
  final bool busy;

  /// Message d'erreur à afficher dans l'interface.
  final String? error;
}