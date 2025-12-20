import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For ScrollDirection
import 'package:flutter/rendering.dart';
import '../models/journal_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late ScrollController _scrollController;
  bool _showFabText = true;

  final List<JournalEntry> entries = [
    JournalEntry(
      id: 1,
      title: 'First Day',
      content: 'Started working on my Journey Journal Flutter app.',
      date: '2025-12-20',
      mood: 'happy',
    ),
    JournalEntry(
      id: 2,
      title: 'Learning Flutter',
      content: 'Learned ListView, BottomNavigationBar, and UI structure.',
      date: '2025-12-21',
      mood: 'excited',
    ),
    JournalEntry(
      id: 3,
      title: 'UI Done',
      content: 'Front-end is ready, next step is database.',
      date: '2025-12-22',
      mood: 'neutral',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;

      if (direction == ScrollDirection.reverse && _showFabText) {
        setState(() => _showFabText = false);
      } else if (direction == ScrollDirection.forward && !_showFabText) {
        setState(() => _showFabText = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          children: [
            _buildRoundedAppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),

      /* ---------------- FIXED ANIMATED FAB ---------------- */
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 56,
          width: _showFabText
              ? MediaQuery.of(context).size.width *
                    0.4 // max 40% of screen
              : 56,
          child: FloatingActionButton(
            onPressed: () {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add),
                if (_showFabText) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text('Add Entry', overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journey'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Medias',
          ),
        ],
      ),
    );
  }

  /* ---------------- ROUNDED APP BAR ---------------- */
  Widget _buildRoundedAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.book, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'Journey',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
    );
  }

  /* ---------------- BODY ---------------- */
  Widget _buildBody() {
    if (_currentIndex == 0) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DATE
                      Text(
                        entry.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),

                      // TITLE
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // CONTENT
                      Text(
                        entry.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // MOOD
                      _buildMood(entry.mood),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // RIGHT SIDE IMAGE (placeholder icon)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/applewatch.png',
                      ), // put a placeholder image in assets
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (_currentIndex == 1) {
      return const Center(child: Text('Calendar Page (later)'));
    } else {
      return const Center(child: Text('Medias Page (later)'));
    }
  }

  /* ---------------- MOOD ---------------- */
  Widget _buildMood(String mood) {
    IconData icon;
    Color color;

    switch (mood) {
      case 'happy':
        icon = Icons.sentiment_satisfied_alt;
        color = Colors.green;
        break;
      case 'sad':
        icon = Icons.sentiment_dissatisfied;
        color = Colors.blue;
        break;
      case 'angry':
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
        break;
      case 'excited':
        icon = Icons.sentiment_very_satisfied;
        color = Colors.orange;
        break;
      default:
        icon = Icons.sentiment_neutral;
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(mood, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
