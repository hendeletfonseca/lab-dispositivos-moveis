import 'package:flutter/material.dart';

import 'package:sudoku/view/HistoryScreen.dart';
import 'package:sudoku/view/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(
              title: 'Sudoku',
            ),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
