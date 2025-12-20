import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({Key? key}) : super(key: key);

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedMood = 'neutral';
  DateTime _selectedDate = DateTime.now();
  List<XFile> _selectedImages = [];
  bool _isSaving = false;

  // Liste des humeurs
  final List<Map<String, dynamic>> _moods = [
    {
      'value': 'happy',
      'emoji': '😁',
      'label': 'Joyeux',
      'color': const Color(0xFFFFD700),
    },
    {
      'value': 'content',
      'emoji': '😊',
      'label': 'Content',
      'color': const Color(0xFFFFA500),
    },
    {
      'value': 'neutral',
      'emoji': '😐',
      'label': 'Neutre',
      'color': const Color(0xFF808080),
    },
    {
      'value': 'sad',
      'emoji': '😢',
      'label': 'Triste',
      'color': const Color(0xFF4169E1),
    },
    {
      'value': 'angry',
      'emoji': '😡',
      'label': 'Énervé',
      'color': const Color(0xFFDC143C),
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Sélectionner des images depuis la galerie
  Future<void> _pickImagesFromGallery() async {
    if (_selectedImages.length >= 5) {
      _showMessage('Maximum 5 photos');
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          int remaining = 5 - _selectedImages.length;
          _selectedImages.addAll(images.take(remaining));
        });
      }
    } catch (e) {
      _showMessage('Erreur lors de la sélection');
    }
  }

  // Prendre une photo avec la caméra
  Future<void> _pickImageFromCamera() async {
    if (_selectedImages.length >= 5) {
      _showMessage('Maximum 5 photos');
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showMessage('Erreur lors de la capture');
    }
  }

  // Supprimer une image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Afficher un message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Sélectionner la date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Afficher le dialogue de sélection d'image
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ajouter une photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF6C63FF),
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    'Galerie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Choisir depuis vos photos'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImagesFromGallery();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF6C63FF),
                      size: 28,
                    ),
                  ),
                  title: const Text(
                    'Caméra',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text('Prendre une nouvelle photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sauvegarder (UI seulement)
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showMessage('Veuillez ajouter un titre');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulation de sauvegarde
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isSaving = false;
    });

    _showMessage('✅ Entrée créée avec succès !');
    
    // Retourner à la page précédente
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context, true);
    });
  }

  // Obtenir la couleur de l'humeur sélectionnée
  Color _getMoodColor() {
    return _moods.firstWhere((mood) => mood['value'] == _selectedMood)['color'];
  }

  // Formater la date en français
  String _formatDate(DateTime date) {
    const List<String> jours = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    const List<String> mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    String jourSemaine = jours[date.weekday - 1];
    String moisNom = mois[date.month - 1];
    
    return '$jourSemaine ${date.day} $moisNom ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header coloré selon l'humeur
            _buildColoredHeader(),
            
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date picker
                    _buildDatePicker(),
                    const SizedBox(height: 20),

                    // Sélecteur d'humeur
                    _buildMoodSelector(),
                    const SizedBox(height: 24),

                    // Champ titre
                    _buildTitleField(),
                    const SizedBox(height: 20),

                    // Champ contenu
                    _buildContentField(),
                    const SizedBox(height: 24),

                    // Galerie de photos
                    if (_selectedImages.isNotEmpty) ...[
                      _buildPhotoGallery(),
                      const SizedBox(height: 20),
                    ],

                    // Bouton ajouter photo
                    _buildAddPhotoButton(),
                    const SizedBox(height: 32),

                    // Bouton sauvegarder
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Nouvelle entrée',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  // Header coloré selon l'humeur
  Widget _buildColoredHeader() {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getMoodColor(),
            _getMoodColor().withOpacity(0.6),
          ],
        ),
      ),
    );
  }

  // Date picker
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF6C63FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: 'Donnez un titre à votre journée...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.title, color: Color(0xFF6C63FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        maxLength: 100,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
          return Padding(
            padding: const EdgeInsets.only(right: 12, top: 8),
            child: Text(
              '$currentLength/$maxLength',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildMoodSelector() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.mood, color: Color(0xFF6C63FF), size: 24),
            SizedBox(width: 8),
            Text(
              'Comment vous sentez-vous ?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Horizontal scrollable mood icons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['value'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood['value'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (mood['color'] as Color).withOpacity(0.2)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (mood['color'] as Color)
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: (mood['color'] as Color).withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            mood['emoji'] as String,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? mood['color'] as Color
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

  // Champ titre

  // Champ contenu
  Widget _buildContentField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _contentController,
        decoration: InputDecoration(
          hintText: 'Écrivez vos pensées, émotions, souvenirs du jour...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.6,
        ),
        maxLines: 12,
        minLines: 8,
      ),
    );
  }

  // Galerie de photos
  Widget _buildPhotoGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.photo_library, size: 20, color: Color(0xFF6C63FF)),
            const SizedBox(width: 8),
            Text(
              '${_selectedImages.length}/5 photos',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // Bouton ajouter photo
  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _selectedImages.length < 5 ? _showImageSourceDialog : null,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _selectedImages.length < 5
              ? const Color(0xFF6C63FF).withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedImages.length < 5
                ? const Color(0xFF6C63FF)
                : Colors.grey[400]!,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: _selectedImages.length < 5
                  ? const Color(0xFF6C63FF)
                  : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedImages.length < 5
                  ? 'Ajouter des photos'
                  : 'Maximum 5 photos atteint',
              style: TextStyle(
                color: _selectedImages.length < 5
                    ? const Color(0xFF6C63FF)
                    : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bouton sauvegarder
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF6C63FF).withOpacity(0.4),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Enregistrer l\'entrée',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}