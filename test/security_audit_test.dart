import 'package:flutter_test/flutter_test.dart';
import 'package:gestionnaire_de_mot_de_passe/features/security_dashboard/domain/password_strength_estimator.dart';
import 'package:gestionnaire_de_mot_de_passe/features/security_dashboard/domain/security_audit.dart';
import 'package:gestionnaire_de_mot_de_passe/features/vault/domain/entities/password_entry.dart';

const strongA = 'k9#Vx2!qLm8@Zr4TnB7%';
const strongB = 'Zp3\$wQ8!mN5&tR2@vL9#';

PasswordEntry entry(String id, String password, {DateTime? changed}) {
  final d = changed ?? DateTime(2026, 11, 1);
  return PasswordEntry(
    id: id,
    title: 'Site $id',
    username: 'user',
    password: password,
    createdAt: d,
    updatedAt: d,
    passwordChangedAt: d,
  );
}

void main() {
  final estimator = PasswordStrengthEstimator();
  final auditor = SecurityAuditor();
  final now = DateTime(2026, 11, 8);

  group('force des mots de passe', () {
    test('un mot de passe courant est très faible', () {
      expect(estimator.estimate('Password123!').level, StrengthLevel.veryWeak);
      expect(estimator.estimate('azerty').isWeak, isTrue);
    });

    test('les répétitions sont pénalisées', () {
      expect(estimator.estimate('aaaaaaaaaaaa').isWeak, isTrue);
    });

    test('un long mot de passe aléatoire est très fort', () {
      expect(estimator.estimate(strongA).level, StrengthLevel.veryStrong);
    });

    test('contenir l\'identifiant est pénalisé', () {
      final s = estimator.estimate('sidi2025Xy', personalTerms: ['sidi']);
      expect(s.isWeak, isTrue);
    });
  });

  group('audit', () {
    test('détecte la réutilisation', () {
      final report = auditor.audit(
        [entry('1', strongA), entry('2', strongA), entry('3', strongB)],
        now: now,
      );
      expect(report.reusedGroups.length, 1);
      expect(report.reusedGroups.first.entries.length, 2);
      expect(report.reusedCount, 2);
    });

    test('détecte les mots de passe anciens', () {
      final report = auditor.audit(
        [entry('1', strongA, changed: DateTime(2025, 1, 1)), entry('2', strongB)],
        now: now,
      );
      expect(report.old.length, 1);
      expect(report.old.first.id, '1');
    });

    test('calcule le score', () {
      final clean = auditor.audit(
        [entry('1', strongA), entry('2', strongB)],
        now: now,
      );
      expect(clean.score, 100);

      final withWeak = auditor.audit(
        [entry('1', strongA), entry('2', 'azerty')],
        now: now,
      );
      expect(withWeak.weak.length, 1);
      expect(withWeak.score, 80);
    });

    test('un coffre vide a un score de 100', () {
      expect(auditor.audit([], now: now).score, 100);
    });
  });
}