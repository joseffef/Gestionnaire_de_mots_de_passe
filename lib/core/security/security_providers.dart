import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'key_derivation_service.dart';
import 'master_key_service.dart';

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final keyDerivationServiceProvider =
    Provider<KeyDerivationService>((ref) => KeyDerivationService());

final masterKeyServiceProvider = Provider<MasterKeyService>((ref) {
  return MasterKeyService(
    ref.watch(secureStorageProvider),
    ref.watch(keyDerivationServiceProvider),
  );
});