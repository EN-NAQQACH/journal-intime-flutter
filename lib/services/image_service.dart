import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {

  static final ImageService instance = ImageService._init();
  final ImagePicker _picker = ImagePicker();

  ImageService._init();

  Future<String?> pickImageFromGallery() async { 
    try {
      final XFile? image = await _picker.pickImage( 
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) return await _saveImage(image.path);
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String?> pickImageFromCamera() async { 
    try {
      final XFile? image = await _picker.pickImage( 
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) return await _saveImage(image.path);
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }


  Future<String?> _saveImage(String sourcePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory(); 
      final imagesDir = Directory('${directory.path}/images'); 
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
      
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final String newPath = '${imagesDir.path}/$fileName';
      
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(newPath);
      return newPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}