import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/clipboard_service.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../domain/entities/password_entry.dart';
import '../providers/vault_controller.dart';
import 'entry_form_screen.dart';
import '../../../security_dashboard/presentation/screens/security_dashboard_screen.dart';

class VaultHomeScreen extends ConsumerWidget {
  const VaultHomeScreen({super.key});

  void _openForm(BuildContext context, [PasswordEntry? entry]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EntryFormScreen(entry: entry)),
    );
  }

  Future<void> _copyPassword(
      BuildContext context, WidgetRef ref, PasswordEntry entry) async {
    await ref.read(clipboardServiceProvider).copySensitive(entry.password);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe copié (effacé dans 30 secondes).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(vaultControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VaultKey'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Verrouiller',
            onPressed: () => ref.read(authControllerProvider.notifier).lock(),
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Tableau de bord de sécurité',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SecurityDashboardScreen(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Aucune entrée pour le moment.'));
          }
          final sorted = [...list]..sort((a, b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final entry = sorted[i];
              return ListTile(
                leading: const Icon(Icons.key),
                title: Text(entry.title),
                subtitle: Text(entry.username),
                onTap: () => _openForm(context, entry),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copier le mot de passe',
                  onPressed: () => _copyPassword(context, ref, entry),
                ),
              );
            },
          );
        },
      ),
    );
  }
}