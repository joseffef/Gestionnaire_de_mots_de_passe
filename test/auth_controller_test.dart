import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gestionnaire_de_mot_de_passe/features/auth/domain/auth_state.dart';
import 'package:gestionnaire_de_mot_de_passe/features/auth/presentation/providers/auth_controller.dart';

Future<void> settle(ProviderContainer c, AuthStatus expected) async {
  for (var i = 0;
      i < 50 && c.read(authControllerProvider).status != expected;
      i++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('auth_test');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test(
    'création, verrouillage, mauvais puis bon mot de passe',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final auth = container.read(authControllerProvider.notifier);
      AuthState current() => container.read(authControllerProvider);

      await settle(container, AuthStatus.needsSetup);
      expect(current().status, AuthStatus.needsSetup);

      await auth.createMasterPassword('court');
      expect(current().status, AuthStatus.needsSetup);
      expect(current().error, isNotNull);

      await auth.createMasterPassword('UnMotDePasseMaitre!2026');
      expect(current().status, AuthStatus.unlocked);

      await auth.lock();
      expect(current().status, AuthStatus.locked);

      await auth.unlock('mauvais-mot-de-passe');
      expect(current().status, AuthStatus.locked);
      expect(current().error, isNotNull);

      await auth.unlock('UnMotDePasseMaitre!2026');
      expect(current().status, AuthStatus.unlocked);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}