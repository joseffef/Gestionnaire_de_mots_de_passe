import 'package:flutter_test/flutter_test.dart';
import 'package:gestionnaire_de_mot_de_passe/core/security/key_derivation_service.dart';

void main() {
  final kdf = KeyDerivationService();

  test('même mot de passe + même sel = mêmes clés', () async {
    final salt = kdf.generateSalt();
    final a = await kdf.derive('MotDePasse!123', salt);
    final b = await kdf.derive('MotDePasse!123', salt);
    expect(a.encryptionKey, b.encryptionKey);
    expect(a.verifier, b.verifier);
  });

  test('mot de passe différent = clés différentes', () async {
    final salt = kdf.generateSalt();
    final a = await kdf.derive('MotDePasse!123', salt);
    final b = await kdf.derive('MotDePasse!124', salt);
    expect(a.encryptionKey, isNot(b.encryptionKey));
  });

  test('sel différent = clés différentes, clé de 32 octets', () async {
    final a = await kdf.derive('MotDePasse!123', kdf.generateSalt());
    final b = await kdf.derive('MotDePasse!123', kdf.generateSalt());
    expect(a.encryptionKey, isNot(b.encryptionKey));
    expect(a.encryptionKey.length, 32);
  });
}