class Photo {
  final int? id;
  final int entryId;
  final String imagePath;
  final DateTime createdAt;

  Photo({
    this.id,
    required this.entryId,
    required this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      entryId: map['entryId'],
      imagePath: map['imagePath'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  
  Photo copyWith({
    int? id,
    int? entryId,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Photo(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}