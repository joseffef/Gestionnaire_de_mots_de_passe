import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/presentation/screens/vault_home_screen.dart';
import '../../domain/auth_state.dart';
import '../providers/auth_controller.dart';
import 'setup_screen.dart';
import 'unlock_screen.dart';

/// Affiche l'écran qui correspond à l'état d'authentification.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authControllerProvider.select((s) => s.status));
    return switch (status) {
      AuthStatus.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.needsSetup => const SetupScreen(),
      AuthStatus.locked => const UnlockScreen(),
      AuthStatus.unlocked => const VaultHomeScreen(),
    };
  }
}