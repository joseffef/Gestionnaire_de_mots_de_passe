import 'package:flutter/material.dart';

import '../../domain/services/password_generator.dart';

/// Renvoie le mot de passe choisi, ou null si l'utilisateur annule.
class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  final _generator = PasswordGenerator();
  PasswordGeneratorOptions _options = const PasswordGeneratorOptions();
  late String _value = _generator.generate(_options);

  void _update(PasswordGeneratorOptions options) {
    if (!options.hasAnyClass) return; // au moins un type reste coché
    setState(() {
      _options = options;
      _value = _generator.generate(options);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Générer un mot de passe'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _value,
                style: const TextStyle(fontFamily: 'Consolas', fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Text('Longueur : ${_options.length}'),
            Slider(
              min: 8,
              max: 64,
              divisions: 56,
              value: _options.length.toDouble(),
              label: '${_options.length}',
              onChanged: (v) => _update(_options.copyWith(length: v.round())),
            ),
            CheckboxListTile(
              dense: true,
              title: const Text('Minuscules (a-z)'),
              value: _options.lowercase,
              onChanged: (v) => _update(_options.copyWith(lowercase: v)),
            ),
            CheckboxListTile(
              dense: true,
              title: const Text('Majuscules (A-Z)'),
              value: _options.uppercase,
              onChanged: (v) => _update(_options.copyWith(uppercase: v)),
            ),
            CheckboxListTile(
              dense: true,
              title: const Text('Chiffres (0-9)'),
              value: _options.digits,
              onChanged: (v) => _update(_options.copyWith(digits: v)),
            ),
            CheckboxListTile(
              dense: true,
              title: const Text('Symboles (!@#...)'),
              value: _options.symbols,
              onChanged: (v) => _update(_options.copyWith(symbols: v)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => _update(_options),
          child: const Text('Régénérer'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('Utiliser'),
        ),
      ],
    );
  }
}