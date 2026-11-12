import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'key_derivation_service.dart';

class MasterKeyService {
  MasterKeyService(this._storage, this._kdf);

  static const _saltKey = 'vault_salt';
  static const _verifierKey = 'vault_verifier';

  final FlutterSecureStorage _storage;
  final KeyDerivationService _kdf;

  /// Vrai si un mot de passe maître a déjà été créé.
  Future<bool> isInitialized() async =>
      (await _storage.read(key: _saltKey)) != null;

  /// Première utilisation : crée le sel et le vérificateur, renvoie la clé Hive.
  Future<Uint8List> createMasterPassword(String password) async {
    final salt = _kdf.generateSalt();
    final keys = await _kdf.derive(password, salt);
    await _storage.write(key: _saltKey, value: base64Encode(salt));
    await _storage.write(key: _verifierKey, value: base64Encode(keys.verifier));
    return keys.encryptionKey;
  }

  /// Déverrouillage : renvoie la clé Hive, ou null si le mot de passe est faux.
  Future<Uint8List?> unlock(String password) async {
    final saltB64 = await _storage.read(key: _saltKey);
    final verifierB64 = await _storage.read(key: _verifierKey);
    if (saltB64 == null || verifierB64 == null) return null;

    final keys = await _kdf.derive(password, base64Decode(saltB64));
    final valid = _constantTimeEquals(keys.verifier, base64Decode(verifierB64));
    return valid ? keys.encryptionKey : null;
  }

  /// Comparaison en temps constant, pour éviter les attaques par chronométrage.
  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}