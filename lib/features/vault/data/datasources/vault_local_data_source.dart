import 'dart:typed_data';

import 'package:hive/hive.dart';

class VaultLocalDataSource {
  static const _boxName = 'vault_entries';
  Box<String>? _box;

  bool get isOpen => _box?.isOpen ?? false;

  /// Ouvre la box chiffrée avec la clé dérivée du mot de passe maître.
  Future<void> open(Uint8List encryptionKey) async {
    _box = await Hive.openBox<String>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Ferme la box (utilisé au verrouillage).
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  Box<String> get _requireBox {
    final box = _box;
    if (box == null) throw StateError('Le coffre est verrouillé.');
    return box;
  }

  List<String> readAll() => _requireBox.values.toList();
  Future<void> write(String id, String json) => _requireBox.put(id, json);
  Future<void> remove(String id) => _requireBox.delete(id);
}