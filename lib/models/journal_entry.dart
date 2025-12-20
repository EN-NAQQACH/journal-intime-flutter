class JournalEntry {
  int? id; // AUTOINCREMENT
  String title;
  String content;
  String date; // ISO string
  String mood; // happy, sad, neutral, angry, excited

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });

  // Convert object to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
    };
  }

  // Convert Map to object (from SQLite)
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      mood: map['mood'],
    );
  }
}
