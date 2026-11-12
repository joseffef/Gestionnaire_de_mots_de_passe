import '../../vault/domain/entities/password_entry.dart';
import 'password_strength_estimator.dart';

class EntryAssessment {
  const EntryAssessment(this.entry, this.strength);

  final PasswordEntry entry;
  final PasswordStrength strength;
}

class ReusedGroup {
  const ReusedGroup(this.entries);

  final List<PasswordEntry> entries;
}

class SecurityReport {
  const SecurityReport({
    required this.total,
    required this.weak,
    required this.reusedGroups,
    required this.old,
    required this.score,
  });

  final int total;
  final List<EntryAssessment> weak;
  final List<ReusedGroup> reusedGroups;
  final List<PasswordEntry> old;

  /// Score global de 0 à 100.
  final int score;

  int get reusedCount =>
      reusedGroups.fold(0, (sum, group) => sum + group.entries.length);
}

class SecurityAuditor {
  SecurityAuditor({
    PasswordStrengthEstimator? estimator,
    this.maxAge = const Duration(days: 180),
  }) : _estimator = estimator ?? PasswordStrengthEstimator();

  final PasswordStrengthEstimator _estimator;
  final Duration maxAge;

  SecurityReport audit(List<PasswordEntry> entries, {DateTime? now}) {
    final current = now ?? DateTime.now();

    final weak = <EntryAssessment>[];
    final old = <PasswordEntry>[];
    final byPassword = <String, List<PasswordEntry>>{};

    for (final e in entries) {
      final strength = _estimator.estimate(
        e.password,
        personalTerms: [e.title, e.username.split('@').first],
      );
      if (strength.isWeak) weak.add(EntryAssessment(e, strength));
      byPassword.putIfAbsent(e.password, () => []).add(e);
      if (current.difference(e.passwordChangedAt) > maxAge) old.add(e);
    }

    final reusedGroups = [
      for (final group in byPassword.values)
        if (group.length > 1) ReusedGroup(group),
    ];

    weak.sort((a, b) =>
        a.strength.entropyBits.compareTo(b.strength.entropyBits));
    old.sort((a, b) => a.passwordChangedAt.compareTo(b.passwordChangedAt));

    final total = entries.length;
    final reusedCount =
        reusedGroups.fold(0, (sum, g) => sum + g.entries.length);

    final score = total == 0
        ? 100
        : (100 -
                40 * weak.length / total -
                40 * reusedCount / total -
                20 * old.length / total)
            .round()
            .clamp(0, 100)
            .toInt();

    return SecurityReport(
      total: total,
      weak: weak,
      reusedGroups: reusedGroups,
      old: old,
      score: score,
    );
  }
}