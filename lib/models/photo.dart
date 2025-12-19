class Photo {
  int? id;
  int entryId; // foreign key
  String imagePath;

  Photo({
    this.id,
    required this.entryId,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'entryId': entryId,
      'imagePath': imagePath,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      entryId: map['entryId'],
      imagePath: map['imagePath'],
    );
  }
}
