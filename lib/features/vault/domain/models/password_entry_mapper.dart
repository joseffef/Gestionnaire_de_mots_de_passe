import '../../domain/entities/password_entry.dart';

class PasswordEntryMapper {
  static Map<String, dynamic> toMap(PasswordEntry e) => {
        'id': e.id,
        'title': e.title,
        'username': e.username,
        'password': e.password,
        'url': e.url,
        'notes': e.notes,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
        'passwordChangedAt': e.passwordChangedAt.toIso8601String(),
      };

  static PasswordEntry fromMap(Map<String, dynamic> m) => PasswordEntry(
        id: m['id'] as String,
        title: m['title'] as String,
        username: m['username'] as String,
        password: m['password'] as String,
        url: (m['url'] as String?) ?? '',
        notes: (m['notes'] as String?) ?? '',
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        passwordChangedAt: DateTime.parse(m['passwordChangedAt'] as String),
      );
}