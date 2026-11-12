import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/providers/auth_controller.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'core/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class VaultApp extends ConsumerWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Au verrouillage : ferme formulaires et dialogues ouverts.
    ref.listen(authControllerProvider.select((s) => s.status), (_, next) {
      if (next == AuthStatus.locked) {
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'VaultKey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // la bascule claire/sombre viendra en D5
      home: const AuthGate(),
    );
  }
}