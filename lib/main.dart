import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_page_screen.dart';

void main() {
  runApp(const UniversBookApp());
}

class UniversBookApp extends StatelessWidget {
  const UniversBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(fontFamily: 'Vazir'),
    );
  }
}

