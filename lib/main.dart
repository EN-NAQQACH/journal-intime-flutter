import 'package:flutter/material.dart';
import './views/home_page.dart';

void main() {
  runApp(const JourneyApp());
}

class JourneyApp extends StatelessWidget {
  const JourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journey Journal',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomePage(),
    );
  }
}
