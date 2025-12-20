import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/photo.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _database;

  // =======================
  // INITIALISATION DATABASE
  // =======================
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'journal_intime.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        date TEXT,
        mood TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entryId INTEGER,
        imagePath TEXT,
        FOREIGN KEY (entryId) REFERENCES entries(id) ON DELETE CASCADE
      )
    ''');
  }

  // =======================
  // JOURNAL ENTRY METHODS
  // =======================

  /// Créer une nouvelle entrée AVEC 1 à 5 photos
  Future<int> insertEntry(
    JournalEntry entry,
    List<String> imagePaths,
  ) async {
    if (imagePaths.isEmpty || imagePaths.length > 5) {
      throw Exception('Une entrée doit contenir entre 1 et 5 photos');
    }

    final db = await database;

    return await db.transaction((txn) async {
      // Insert entry
      int entryId = await txn.insert('entries', entry.toMap());

      // Insert photos
      for (String path in imagePaths) {
        await txn.insert('photos', {
          'entryId': entryId,
          'imagePath': path,
        });
      }

      return entryId;
    });
  }

  /// Récupérer toutes les entrées (du plus récent au plus ancien)
  Future<List<JournalEntry>> getAllEntries() async {
    final db = await database;
    final result =
        await db.query('entries', orderBy: 'date DESC');

    return result.map((e) => JournalEntry.fromMap(e)).toList();
  }

  /// Récupérer une entrée par ID
  Future<JournalEntry?> getEntryById(int id) async {
    final db = await database;
    final result =
        await db.query('entries', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return JournalEntry.fromMap(result.first);
    }
    return null;
  }

  /// Mettre à jour une entrée
  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Supprimer une entrée (photos supprimées automatiquement)
  Future<int> deleteEntry(int entryId) async {
    final db = await database;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [entryId],
    );
  }

  /// Rechercher des entrées par titre ou contenu
  Future<List<JournalEntry>> searchEntries(String keyword) async {
    final db = await database;
    final result = await db.query(
      'entries',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
      orderBy: 'date DESC',
    );

    return result.map((e) => JournalEntry.fromMap(e)).toList();
  }

  // =======================
  // PHOTO METHODS
  // =======================

  /// Ajouter 1 à 5 photos à une entrée
  // Future<void> insertPhotos(
  //   int entryId,
  //   List<String> imagePaths,
  // ) async {
  //   if (imagePaths.isEmpty || imagePaths.length > 5) {
  //     throw Exception('Entre 1 et 5 photos autorisées');
  //   }

  //   final db = await database;
  //   Batch batch = db.batch();

  //   for (String path in imagePaths) {
  //     batch.insert('photos', {
  //       'entryId': entryId,
  //       'imagePath': path,
  //     });
  //   }

  //   await batch.commit(noResult: true);
  // }

  /// Récupérer toutes les photos d'une entrée
  Future<List<Photo>> getPhotosByEntry(int entryId) async {
    final db = await database;
    final result = await db.query(
      'photos',
      where: 'entryId = ?',
      whereArgs: [entryId],
    );

    return result.map((e) => Photo.fromMap(e)).toList();
  }

  /// Supprimer une photo spécifique
  Future<int> deletePhoto(int photoId) async {
    final db = await database;
    return await db.delete(
      'photos',
      where: 'id = ?',
      whereArgs: [photoId],
    );
  }

  /// Supprimer toutes les photos d'une entrée
  Future<int> deletePhotosByEntry(int entryId) async {
    final db = await database;
    return await db.delete(
      'photos',
      where: 'entryId = ?',
      whereArgs: [entryId],
    );
  }
}
