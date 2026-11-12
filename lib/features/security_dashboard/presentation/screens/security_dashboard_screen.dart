import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/domain/entities/password_entry.dart';
import '../../../vault/presentation/screens/entry_form_screen.dart';
import '../../domain/password_strength_estimator.dart';
import '../../domain/security_audit.dart';
import '../providers/security_providers.dart';

String _levelLabel(StrengthLevel level) => switch (level) {
      StrengthLevel.veryWeak => 'Très faible',
      StrengthLevel.weak => 'Faible',
      StrengthLevel.fair => 'Moyen',
      StrengthLevel.strong => 'Fort',
      StrengthLevel.veryStrong => 'Très fort',
    };

Color _scoreColor(int score) {
  if (score >= 80) return Colors.green;
  if (score >= 60) return Colors.amber;
  if (score >= 40) return Colors.orange;
  return Colors.red;
}

String _scoreLabel(int score) {
  if (score >= 80) return 'Excellent';
  if (score >= 60) return 'Correct';
  if (score >= 40) return 'À améliorer';
  return 'Critique';
}

void _edit(BuildContext context, PasswordEntry entry) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => EntryFormScreen(entry: entry)),
  );
}

class SecurityDashboardScreen extends ConsumerWidget {
  const SecurityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(securityReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord de sécurité')),
      body: report == null
          ? const Center(child: CircularProgressIndicator())
          : report.total == 0
              ? const Center(
                  child: Text('Ajoutez des entrées pour lancer l\'audit.'))
              : _Content(report: report),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.report});

  final SecurityReport report;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ScoreCard(report: report),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Faibles',
                    value: report.weak.length,
                    icon: Icons.warning_amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Réutilisés',
                    value: report.reusedCount,
                    icon: Icons.copy_all,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Anciens',
                    value: report.old.length,
                    icon: Icons.history,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Mots de passe faibles',
              emptyText: 'Aucun mot de passe faible.',
              children: [
                for (final a in report.weak)
                  ListTile(
                    leading:
                        const Icon(Icons.warning_amber, color: Colors.orange),
                    title: Text(a.entry.title),
                    subtitle: Text(
                      [_levelLabel(a.strength.level), ...a.strength.warnings]
                          .join(' · '),
                    ),
                    onTap: () => _edit(context, a.entry),
                  ),
              ],
            ),
            _Section(
              title: 'Mots de passe réutilisés',
              emptyText: 'Aucun mot de passe réutilisé.',
              children: [
                for (final group in report.reusedGroups) ...[
                  ListTile(
                    dense: true,
                    title: Text(
                      'Même mot de passe sur ${group.entries.length} comptes',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (final e in group.entries)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.subdirectory_arrow_right),
                      title: Text(e.title),
                      subtitle: Text(e.username),
                      onTap: () => _edit(context, e),
                    ),
                ],
              ],
            ),
            _Section(
              title: 'Mots de passe anciens (plus de 180 jours)',
              emptyText: 'Tous vos mots de passe sont récents.',
              children: [
                for (final e in report.old)
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(e.title),
                    subtitle: Text(
                      'Changé il y a ${now.difference(e.passwordChangedAt).inDays} jours',
                    ),
                    onTap: () => _edit(context, e),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.report});

  final SecurityReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _scoreColor(report.score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: report.score / 100,
                    strokeWidth: 8,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.2),
                  ),
                  Center(
                    child: Text('${report.score}',
                        style: theme.textTheme.headlineMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_scoreLabel(report.score),
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('${report.total} mots de passe analysés'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text('$value', style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          child: children.isEmpty
              ? ListTile(
                  leading:
                      const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(emptyText),
                )
              : Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}