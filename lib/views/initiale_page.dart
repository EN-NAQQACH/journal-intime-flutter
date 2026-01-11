import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'conexion_page.dart';

class InitialePage extends StatefulWidget {
  const InitialePage({super.key});

  @override
  State<InitialePage> createState() => _InitialePageState();
}

class _InitialePageState extends State<InitialePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroPage> _pages = [
    IntroPage(
      title: 'Bienvenue à Journal Intime',
      description: 'Documentez vos pensées, émotions et souvenirs quotidiens',
      icon: Icons.edit_note_rounded,
      color: Colors.purple,
    ),
    IntroPage(
      title: 'Suivez Vos Humeurs',
      description: 'Visualisez vos émotions avec des couleurs et des emojis',
      icon: Icons.mood_rounded,
      color: Colors.blue,
    ),
    IntroPage(
      title: 'Capturez Vos Moments',
      description: 'Ajoutez des photos à vos entrées de journal',
      icon: Icons.photo_camera_rounded,
      color: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => _navigateToLogin(),
                  child: const Text('Passer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotWidth: 12,
                  dotHeight: 12,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.grey.shade300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } else {
                      _navigateToLogin();
                    }
                  },
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(_currentPage < _pages.length - 1 ? 'Suivant' : 'Commencer', 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(page.icon, size: 120, color: page.color),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: page.color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

void _navigateToLogin() {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const ConexionPage(),
      fullscreenDialog: true, // optional
    ),
  );
}


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class IntroPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  IntroPage({required this.title, required this.description, required this.icon, required this.color});
}