import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../models/photo.dart';
import '../services/db_service.dart';

class EntryProvider with ChangeNotifier {

  List<JournalEntry> entries = [];
  bool isLoading = false;

  Future<void> loadEntries(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = DBService.instance;
    entries = await db.getEntriesByUser(userId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> searchEntries(int userId, String query) async {
    if (query.isEmpty) {
      await loadEntries(userId);
      return;
    }
    isLoading = true;
    notifyListeners();
    final db = DBService.instance;
    entries = await db.searchEntries(userId, query);
    isLoading = false;
    notifyListeners();
  }

  Future<void> filterByMood(int userId, String mood) async {
    isLoading = true;
    notifyListeners();
    final db = DBService.instance;
    entries = await db.getEntriesByMood(userId, mood);
    isLoading = false;
    notifyListeners();
  }

  Future<List<JournalEntry>> getEntriesByDate(int userId, DateTime date) async {
    final db = DBService.instance;
    return await db.getEntriesByDate(userId, date);
  }

  Future<List<Photo>> getPhotosForEntry(int entryId) async {
    final db = DBService.instance;
    return await db.getPhotosByEntry(entryId);
  }

  Future<JournalEntry?> createEntry(JournalEntry entry, List<String> imagePaths) async {
    try {
      final db = DBService.instance;
      final createdEntry = await db.createEntry(entry);

      for (String imagePath in imagePaths) {
        final photo = Photo(entryId: createdEntry.id!, imagePath: imagePath);
        await db.createPhoto(photo);
      }

      await loadEntries(entry.userId);
      return createdEntry;
    } catch (e) {
      print('Error creating entry: $e');
      return null;
    }
  }

  Future<bool> updateEntry(JournalEntry entry, List<String> imagePaths) async {
    try {
      final db = DBService.instance;
      await db.updateEntry(entry);

      final existingPhotos = await db.getPhotosByEntry(entry.id!);
      for (var photo in existingPhotos) {
        if (photo.id != null) await db.deletePhoto(photo.id!);
      }

      for (String imagePath in imagePaths) {
        final photo = Photo(entryId: entry.id!, imagePath: imagePath);
        await db.createPhoto(photo);
      }

      await loadEntries(entry.userId);
      return true;
    } catch (e) {
      print('Error updating entry: $e');
      return false;
    }
  }

  Future<bool> deleteEntry(int entryId, int userId) async {
    try {
      final db = DBService.instance;
      await db.deleteEntry(entryId);
      await loadEntries(userId);
      return true;
    } catch (e) {
      print('Error deleting entry: $e');
      return false;
    }
  }
}