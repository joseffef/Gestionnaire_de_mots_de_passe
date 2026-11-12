import 'dart:math';

/// Identifiant aléatoire de 128 bits, en hexadécimal.
String generateId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}