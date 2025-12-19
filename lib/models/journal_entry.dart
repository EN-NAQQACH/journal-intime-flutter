class JournalEntry {
  int? id;
  String title;
  String content;
  String date; 
  String mood; 

  JournalEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });


  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
    };
    if (id != null) map['id'] = id;
    return map;
  }

 
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
