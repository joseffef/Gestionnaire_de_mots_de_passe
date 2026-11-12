import 'dart:math';

class PasswordGeneratorOptions {
  const PasswordGeneratorOptions({
    this.length = 20,
    this.lowercase = true,
    this.uppercase = true,
    this.digits = true,
    this.symbols = true,
  });

  final int length;
  final bool lowercase;
  final bool uppercase;
  final bool digits;
  final bool symbols;

  bool get hasAnyClass => lowercase || uppercase || digits || symbols;

  PasswordGeneratorOptions copyWith({
    int? length,
    bool? lowercase,
    bool? uppercase,
    bool? digits,
    bool? symbols,
  }) {
    return PasswordGeneratorOptions(
      length: length ?? this.length,
      lowercase: lowercase ?? this.lowercase,
      uppercase: uppercase ?? this.uppercase,
      digits: digits ?? this.digits,
      symbols: symbols ?? this.symbols,
    );
  }
}

class PasswordGenerator {
  PasswordGenerator([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits = '0123456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{};:,.?';

  String generate(PasswordGeneratorOptions options) {
    final pools = <String>[
      if (options.lowercase) _lower,
      if (options.uppercase) _upper,
      if (options.digits) _digits,
      if (options.symbols) _symbols,
    ];
    if (pools.isEmpty) {
      throw ArgumentError('Au moins un type de caractère est requis.');
    }

    final length = max(options.length, pools.length);
    final all = pools.join();

    // Un caractère de chaque type choisi, puis on complète.
    final chars = <String>[
      for (final pool in pools) pool[_random.nextInt(pool.length)],
    ];
    while (chars.length < length) {
      chars.add(all[_random.nextInt(all.length)]);
    }

    // Mélange de Fisher-Yates avec un générateur sécurisé.
    for (var i = chars.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = chars[i];
      chars[i] = chars[j];
      chars[j] = tmp;
    }
    return chars.join();
  }
}