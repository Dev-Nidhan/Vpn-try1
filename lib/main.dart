import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TinyVPNApp());
}

class TinyVPNApp extends StatelessWidget {
  const TinyVPNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyVPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
