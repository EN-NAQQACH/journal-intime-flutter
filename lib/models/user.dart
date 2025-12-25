class User {
  final int? id;
  final String username;
  final String email;
  final String? photoPath;
  final String? passwordHash;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    this.photoPath,
    this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'photoPath': photoPath,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      photoPath: map['photoPath'],
      passwordHash: map['passwordHash'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? photoPath,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoPath: photoPath ?? this.photoPath,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}