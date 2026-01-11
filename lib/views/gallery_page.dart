import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/mood_provider.dart';
import '../services/db_service.dart';
import '../models/photo.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  
  List<Photo> _allPhotos = [];
  Map<String, List<Photo>> _photosByMood = {};
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      final db = DBService.instance;
      final photos = await db.getAllPhotosByUser(authProvider.currentUser!.id!);
      
      final photosByMood = <String, List<Photo>>{};
      for (var mood in ['happy', 'content', 'neutral', 'sad', 'angry']) {
        final List<Photo> moodPhotos = await db.getAllPhotosByMood(authProvider.currentUser!.id!, mood);
        if (moodPhotos.isNotEmpty) {
          photosByMood[mood] = moodPhotos;
        }
      }
      
      setState(() {
        _allPhotos = photos;
        _photosByMood = photosByMood;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategoryFilter(),
                Expanded(child: _buildGalleryGrid()),
              ],
            ),
    );
  }

  Widget _buildCategoryFilter() {
    final moodProvider = Provider.of<MoodProvider>(context);
    final categories = ['all', ..._photosByMood.keys];

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                children: [
                  if (category != 'all')
                    Text(moodProvider.getMoodEmoji(category), style: const TextStyle(fontSize: 18))
                  else
                    const Icon(Icons.photo_library, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    category == 'all' ? 'Toutes' : moodProvider.getMoodLabel(category),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${category == 'all' ? _allPhotos.length : _photosByMood[category]?.length ?? 0})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryGrid() {
    final photos = _selectedCategory == 'all' ? _allPhotos : (_photosByMood[_selectedCategory] ?? []);

    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Aucune photo', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) => _buildPhotoTile(photos[index]),
    );
  }

  Widget _buildPhotoTile(Photo photo) {
    return GestureDetector(
      onTap: () => _showFullImage(photo),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(photo.imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }

  void _showFullImage(Photo photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(photo.imagePath)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}