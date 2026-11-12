import 'package:flutter_test/flutter_test.dart';
import 'package:gestionnaire_de_mot_de_passe/features/vault/domain/services/password_generator.dart';

void main() {
  final generator = PasswordGenerator();

  test('respecte la longueur demandée', () {
    final p = generator.generate(const PasswordGeneratorOptions(length: 32));
    expect(p.length, 32);
  });

  test('contient au moins un caractère de chaque type choisi', () {
    for (var i = 0; i < 200; i++) {
      final p = generator.generate(const PasswordGeneratorOptions(length: 8));
      expect(RegExp(r'[a-z]').hasMatch(p), isTrue);
      expect(RegExp(r'[A-Z]').hasMatch(p), isTrue);
      expect(RegExp(r'[0-9]').hasMatch(p), isTrue);
      expect(RegExp(r'[^a-zA-Z0-9]').hasMatch(p), isTrue);
    }
  });

  test('refuse une configuration sans aucun type de caractère', () {
    expect(
      () => generator.generate(const PasswordGeneratorOptions(
        lowercase: false,
        uppercase: false,
        digits: false,
        symbols: false,
      )),
      throwsArgumentError,
    );
  });
}