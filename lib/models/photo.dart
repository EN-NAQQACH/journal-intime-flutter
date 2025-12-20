class Photo {
  int? id; // AUTOINCREMENT
  int entryId; // Foreign key -> JournalEntry.id
  String imagePath; // Local file path

  Photo({
    this.id,
    required this.entryId,
    required this.imagePath,
  });

  // Convert object to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'imagePath': imagePath,
    };
  }

  // Convert Map to object (from SQLite)
  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      entryId: map['entryId'],
      imagePath: map['imagePath'],
    );
  }
}
