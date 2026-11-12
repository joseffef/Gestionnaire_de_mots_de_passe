import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/domain/entities/password_entry.dart';
import '../../../vault/presentation/providers/vault_controller.dart';
import '../../domain/security_audit.dart';

final securityAuditorProvider =
    Provider<SecurityAuditor>((ref) => SecurityAuditor());

/// Rapport recalculé automatiquement à chaque changement du coffre.
/// Null tant que les entrées ne sont pas chargées.
final securityReportProvider = Provider<SecurityReport?>((ref) {
  final entries = ref.watch(vaultControllerProvider);
  if (entries is! AsyncData<List<PasswordEntry>>) return null;
  return ref.watch(securityAuditorProvider).audit(entries.value);
});