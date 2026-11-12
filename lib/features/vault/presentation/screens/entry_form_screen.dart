import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/password_entry.dart';
import '../providers/vault_controller.dart';
import '../widgets/password_generator_dialog.dart';

/// Ajout (entry == null) ou modification d'une entrée.
class EntryFormScreen extends ConsumerStatefulWidget {
  const EntryFormScreen({super.key, this.entry});

  final PasswordEntry? entry;

  @override
  ConsumerState<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends ConsumerState<EntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.entry?.title);
  late final _username = TextEditingController(text: widget.entry?.username);
  late final _password = TextEditingController(text: widget.entry?.password);
  late final _url = TextEditingController(text: widget.entry?.url);
  late final _notes = TextEditingController(text: widget.entry?.notes);

  bool _obscure = true;
  bool _saving = false;

  bool get _isEdit => widget.entry != null;

  @override
  void dispose() {
    _title.dispose();
    _username.dispose();
    _password.dispose();
    _url.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const PasswordGeneratorDialog(),
    );
    if (value != null) setState(() => _password.text = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final old = widget.entry;
    final entry = old == null
        ? PasswordEntry(
            id: generateId(),
            title: _title.text.trim(),
            username: _username.text.trim(),
            password: _password.text,
            url: _url.text.trim(),
            notes: _notes.text,
            createdAt: now,
            updatedAt: now,
            passwordChangedAt: now,
          )
        : old.copyWith(
            title: _title.text.trim(),
            username: _username.text.trim(),
            password: _password.text,
            url: _url.text.trim(),
            notes: _notes.text,
            updatedAt: now,
            passwordChangedAt: _password.text != old.password ? now : null,
          );

    await ref.read(vaultControllerProvider.notifier).save(entry);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette entrée ?'),
        content: Text(
            '« ${widget.entry!.title} » sera supprimée définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(vaultControllerProvider.notifier).delete(widget.entry!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier l\'entrée' : 'Nouvelle entrée'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Supprimer',
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _title,
                  autofocus: !_isEdit,
                  decoration: const InputDecoration(
                    labelText: 'Titre (ex. Gmail)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Le titre est obligatoire.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _username,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    labelText: 'Identifiant ou e-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          tooltip: _obscure ? 'Afficher' : 'Masquer',
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          tooltip: 'Générer',
                          onPressed: _generate,
                        ),
                      ],
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Le mot de passe est obligatoire.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Site web (facultatif)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes (facultatif)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}