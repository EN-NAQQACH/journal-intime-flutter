import 'package:flutter/material.dart';
import '../services/db_service.dart';

class MoodProvider with ChangeNotifier {
  Map<String, int> moodCounts = {};
  Map<DateTime, String> dailyMoods = {};
  List<Map<String, dynamic>> weeklyData = [];

  Future<void> loadMoodStats(int userId) async {
    final db = DBService.instance;
    final entries = await db.getEntriesByUser(userId);

    moodCounts = {};
    dailyMoods = {};

    for (var entry in entries) {
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
      final dateKey = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      dailyMoods[dateKey] = entry.mood;
    }

    _calculateWeeklyData(entries);
    notifyListeners();
  }


  void _calculateWeeklyData(List entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 6));

    final recentEntries = entries.where((e) {
      final entryDate = DateTime(e.date.year, e.date.month, e.date.day);
      return !entryDate.isBefore(weekAgo);
    }).toList();

    final Map<String, int> weeklyCounts = {};

    for (var entry in recentEntries) {
      weeklyCounts[entry.mood] = (weeklyCounts[entry.mood] ?? 0) + 1;
    }

    weeklyData = weeklyCounts.entries
        .map((e) => {'mood': e.key, 'count': e.value})
        .toList();
  }


  int getHappyDaysCount() => moodCounts['happy'] ?? 0;
  int getTotalEntriesCount() => moodCounts.values.fold(0, (sum, count) => sum + count);

  Color getMoodColor(String mood) {
    switch (mood) {
      case 'happy':
        return const Color(0xFFFFD700);
      case 'content':
        return const Color(0xFFFF8C00);
      case 'neutral':
        return const Color(0xFF808080);
      case 'sad':
        return const Color(0xFF4169E1);
      case 'angry':
        return const Color(0xFFDC143C);
      default:
        return Colors.grey;
    }
  }

  String getMoodEmoji(String mood) {
    switch (mood) {
      case 'happy':
        return '😁';
      case 'content':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😢';
      case 'angry':
        return '😡';
      default:
        return '😐';
    }
  }

  String getMoodLabel(String mood) {
    switch (mood) {
      case 'happy':
        return 'Joyeux';
      case 'content':
        return 'Content';
      case 'neutral':
        return 'Neutre';
      case 'sad':
        return 'Triste';
      case 'angry':
        return 'Énervé';
      default:
        return 'Neutre';
    }
  }
}
