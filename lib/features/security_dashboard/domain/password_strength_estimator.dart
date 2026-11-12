import 'dart:math';

enum StrengthLevel { veryWeak, weak, fair, strong, veryStrong }

class PasswordStrength {
  const PasswordStrength({
    required this.level,
    required this.entropyBits,
    this.warnings = const [],
  });

  final StrengthLevel level;
  final double entropyBits;
  final List<String> warnings;

  bool get isWeak =>
      level == StrengthLevel.veryWeak || level == StrengthLevel.weak;
}

class PasswordStrengthEstimator {
  static const _commonWords = <String>{
    'password', 'motdepasse', 'azerty', 'qwerty', 'admin', 'welcome',
    'bienvenue', 'letmein', 'football', 'monkey', 'dragon', 'master',
    'login', 'soleil', 'maroc', 'iloveyou', 'secret', 'azertyuiop',
    'qwertyuiop', 'abc123', '123456', '12345678', '000000', '111111', '1234',
  };

  static const _leet = <String, String>{
    '@': 'a', '4': 'a', '3': 'e', '0': 'o', '1': 'i',
    '!': 'i', r'$': 's', '5': 's', '7': 't',
  };

  PasswordStrength estimate(
    String password, {
    List<String> personalTerms = const [],
  }) {
    final warnings = <String>[];
    var bits = _entropyBits(password);

    if (password.length < 8) {
      warnings.add('Trop court (moins de 8 caractères).');
    }

    final lower = password.toLowerCase();
    final normalized = _normalize(password);

    if (_isCommon(lower, normalized)) {
      warnings.add('Contient un mot ou un motif très courant.');
      bits = min(bits, 20.0);
    }
    if (_hasSequence(lower)) {
      warnings.add('Contient une suite de caractères (abcd, 1234...).');
      bits = max(0.0, bits - 12);
    }
    for (final term in personalTerms) {
      final t = _normalize(term);
      if (t.length >= 3 && normalized.contains(t)) {
        warnings.add('Contient l\'identifiant ou le titre du compte.');
        bits = min(bits, 25.0);
        break;
      }
    }

    return PasswordStrength(
      level: _levelFor(bits),
      entropyBits: bits,
      warnings: warnings,
    );
  }

  double _entropyBits(String p) {
    if (p.isEmpty) return 0;
    var pool = 0;
    if (RegExp(r'[a-z]').hasMatch(p)) pool += 26;
    if (RegExp(r'[A-Z]').hasMatch(p)) pool += 26;
    if (RegExp(r'[0-9]').hasMatch(p)) pool += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(p)) pool += 33;

    // Les caractères répétés comptent pour un quart.
    final length = p.runes.length;
    final distinct = p.runes.toSet().length;
    final effectiveLength = distinct + (length - distinct) * 0.25;
    return effectiveLength * (log(pool) / ln2);
  }

  String _normalize(String s) =>
      s.toLowerCase().split('').map((c) => _leet[c] ?? c).join();

  bool _isCommon(String lower, String normalized) {
    for (final word in _commonWords) {
      final inLower = lower.contains(word) && lower.length - word.length <= 6;
      final inNormalized =
          normalized.contains(word) && normalized.length - word.length <= 6;
      if (inLower || inNormalized) return true;
    }
    return false;
  }

  bool _hasSequence(String s, {int run = 4}) {
    final u = s.codeUnits;
    var up = 1;
    var down = 1;
    for (var i = 1; i < u.length; i++) {
      up = (u[i] - u[i - 1] == 1) ? up + 1 : 1;
      down = (u[i] - u[i - 1] == -1) ? down + 1 : 1;
      if (up >= run || down >= run) return true;
    }
    return false;
  }

  StrengthLevel _levelFor(double bits) {
    if (bits < 28) return StrengthLevel.veryWeak;
    if (bits < 36) return StrengthLevel.weak;
    if (bits < 60) return StrengthLevel.fair;
    if (bits < 80) return StrengthLevel.strong;
    return StrengthLevel.veryStrong;
  }
}