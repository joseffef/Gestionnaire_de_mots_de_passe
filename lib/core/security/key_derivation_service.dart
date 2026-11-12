import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Résultat d'une dérivation : deux clés indépendantes.
class DerivedKeys {
  const DerivedKeys({required this.encryptionKey, required this.verifier});

  /// 32 octets, utilisée pour chiffrer la base Hive. Ne jamais la stocker.
  final Uint8List encryptionKey;

  /// 32 octets, stockée pour vérifier le mot de passe maître.
  final Uint8List verifier;
}

class KeyDerivationService {
  // Paramètres minimaux recommandés par l'OWASP pour Argon2id.
  static final Argon2id _argon2 = Argon2id(
    memory: 19456, // en Kio (~19 Mio)
    parallelism: 1,
    iterations: 2,
    hashLength: 64,
  );

  Uint8List generateSalt([int length = 16]) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Future<DerivedKeys> derive(String masterPassword, Uint8List salt) async {
    final secretKey = await _argon2.deriveKeyFromPassword(
      password: masterPassword,
      nonce: salt,
    );
    final bytes = Uint8List.fromList(await secretKey.extractBytes());
    return DerivedKeys(
      encryptionKey: Uint8List.sublistView(bytes, 0, 32),
      verifier: Uint8List.sublistView(bytes, 32, 64),
    );
  }
}