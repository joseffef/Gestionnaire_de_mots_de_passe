class PasswordEntry {
  const PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
    required this.passwordChangedAt,
    this.url = '',
    this.notes = '',
  });

  final String id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Date du dernier changement du mot de passe (utile pour l'audit).
  final DateTime passwordChangedAt;

  PasswordEntry copyWith({
    String? title,
    String? username,
    String? password,
    String? url,
    String? notes,
    DateTime? updatedAt,
    DateTime? passwordChangedAt,
  }) {
    return PasswordEntry(
      id: id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      passwordChangedAt: passwordChangedAt ?? this.passwordChangedAt,
    );
  }
}