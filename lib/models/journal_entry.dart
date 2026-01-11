class JournalEntry {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final String? password;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntry({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.password,
    DateTime? createdAt,
    DateTime? updatedAt,
  })
  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  JournalEntry.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['userId'],
        title = map['title'],
        content = map['content'],
        date = DateTime.parse(map['date']),
        mood = map['mood'],
        password = map['password'],
        createdAt =  DateTime.parse(map['createdAt']),
        updatedAt =  DateTime.parse(map['updatedAt']);


  JournalEntry copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    DateTime? date,
    String? mood,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}