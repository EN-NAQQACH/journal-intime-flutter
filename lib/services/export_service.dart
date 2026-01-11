import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'db_service.dart';

class ExportService {
  
  static final ExportService instance = ExportService._init();
  ExportService._init();

  Future<void> exportAndShare(int userId) async {
    try {
      final db = DBService.instance; 
      final entries = await db.getEntriesByUser(userId); 

      final List<Map<String, dynamic>> exportData = [];


    
      for (var entry in entries) {
        final photos = await db.getPhotosByEntry(entry.id!);
        exportData.add({
          'entry': entry.toMap(),
          'photos': photos.map((p) => p.toMap()).toList(),
        });
      }

     
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/journal_export_${DateTime.now().millisecondsSinceEpoch}.json';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: '📔 Export de mon journal intime',
      );
    } catch (e) {
      print('❌ Error exporting journal: $e');
    }
  }

  /// Import journal entries from a JSON file path
  // Future<bool> importFromJsonFile(String filePath, int userId) async {
  //   try {
  //     final file = File(filePath);
  //     final jsonString = await file.readAsString();
  //     final List<dynamic> importData = json.decode(jsonString);

  //     final db = DBService.instance;

  //     for (var item in importData) {
  //       final entryMap = item['entry'] as Map<String, dynamic>;
  //       final photosData = item['photos'] as List<dynamic>;

  //       final entry = JournalEntry.fromMap(entryMap).copyWith(
  //         id: null,
  //         userId: userId,
  //       );

  //       final createdEntry = await db.createEntry(entry);

  //       for (var photoMap in photosData) {
  //         final photo = Photo.fromMap(photoMap).copyWith(
  //           id: null,
  //           entryId: createdEntry.id!,
  //         );
  //         await db.createPhoto(photo);
  //       }
  //     }

  //     return true;
  //   } catch (e) {
  //     print('❌ Error importing journal: $e');
  //     return false;
  //   }
  // }


}
