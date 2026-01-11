import 'package:flutter/material.dart';

class MoodHelper {
  static const Map<String, String> moodEmojis = {
    'happy': '😁',
    'content': '😊',
    'neutral': '😐',
    'sad': '😢',
    'angry': '😡',
  };

  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFFDD835),      // Jaune
    'content': Color(0xFFFF9800),    // Orange
    'neutral': Color(0xFF9E9E9E),    // Gris
    'sad': Color(0xFF2196F3),        // Bleu
    'angry': Color(0xFFF44336),      // Rouge
  };

  static const Map<String, String> moodLabels = {
    'happy': 'Joyeux',
    'content': 'Content',
    'neutral': 'Neutre',
    'sad': 'Triste',
    'angry': 'Énervé',
  };

  static String getEmoji(String mood) {
    return moodEmojis[mood] ?? '😐';
  }

  static Color getColor(String mood) {
    return moodColors[mood] ?? Colors.grey;
  }

  static String getLabel(String mood) {
    return moodLabels[mood] ?? 'Neutre';
  }

  static List<String> getAllMoods() {
    return ['happy', 'content', 'neutral', 'sad', 'angry'];
  }
}
