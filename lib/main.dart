import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const LikelembaApp());

class LikelembaApp extends StatelessWidget {
  const LikelembaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Likelemba',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7A5B)),
      ),
      home: const HomeScreen(),
    );
  }
}
