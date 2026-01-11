import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';
import '../models/photo.dart';
import '../models/user.dart';

class DBService {

  static final DBService instance = DBService._init();
  static Database? _database; 
  DBService._init();


  Future<Database> get database async { 
    if (_database != null) return _database!; 
    _database = await _initDB('journal.db'); 
    return _database!;
  }


  Future<Database> _initDB(String filePath) async { 
    final dbPath = await getDatabasesPath(); 
    final path = join(dbPath, filePath);  
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }


  Future _createDB(Database db, int version) async { 

    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType,
        email $textType,
        photoPath $textTypeNull,
        passwordHash $textTypeNull,
        createdAt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE entries (
        id $idType,
        userId INTEGER NOT NULL,
        title $textType,
        content $textType,
        date $textType,
        mood $textType,
        password $textTypeNull,
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id $idType,
        entryId INTEGER NOT NULL,
        imagePath $textType,
        createdAt $textType,
        FOREIGN KEY (entryId) REFERENCES entries (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<User> createUser(User user) async {
    final db = await instance.database; 
    final id = await db.insert('users', user.toMap()); 
    return user.copyWith(id: id);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]); 
  }

  Future<JournalEntry> createEntry(JournalEntry entry) async {
    final db = await instance.database;
    final id = await db.insert('entries', entry.toMap());
    return entry.copyWith(id: id);
  }

  Future<List<JournalEntry>> getEntriesByUser(int userId) async {
    final db = await instance.database;
    final maps = await db.query('entries', where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> searchEntries(int userId, String query) async {
    final db = await instance.database;
    final maps = await db.query(
      'entries',
      where: 'userId = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getEntriesByMood(int userId, String mood) async {
    final db = await instance.database;
    final maps = await db.query('entries', where: 'userId = ? AND mood = ?', whereArgs: [userId, mood], orderBy: 'date DESC');
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<List<JournalEntry>> getEntriesByDate(int userId, DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final maps = await db.query(
      'entries',
      where: 'userId = ? AND date >= ? AND date < ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await instance.database;
    return db.update('entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<Photo> createPhoto(Photo photo) async {
    final db = await instance.database;
    await db.insert('photos', photo.toMap());
    return photo;
  }

  Future<List<Photo>> getPhotosByEntry(int entryId) async {
    final db = await instance.database;
    final maps = await db.query('photos', where: 'entryId = ?', whereArgs: [entryId]);
    return maps.map((map) => Photo.fromMap(map)).toList();
  }

  Future<List<Photo>> getAllPhotosByMood(int userId, String mood) async {
    final db = await instance.database;
    final maps = await db.rawQuery('''
      SELECT p.* FROM photos p
      INNER JOIN entries e ON p.entryId = e.id
      WHERE e.userId = ? AND e.mood = ?
      ORDER BY p.createdAt DESC
    ''', [userId, mood]);
    return maps.map((map) => Photo.fromMap(map)).toList();
  }

  Future<List<Photo>> getAllPhotosByUser(int userId) async {
    final db = await instance.database;
    final maps = await db.rawQuery('''
      SELECT p.* FROM photos p
      INNER JOIN entries e ON p.entryId = e.id
      WHERE e.userId = ?
      ORDER BY p.createdAt DESC
    ''', [userId]);
    return maps.map((map) => Photo.fromMap(map)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await instance.database;
    return db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}