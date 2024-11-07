import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Food App',
      theme: ThemeData(
        primaryColor: const Color(0xFF005E62),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005E62),
          secondary: const Color(0xFF007F83),
          tertiary: const Color(0xFFE0F2F3),
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF005E62),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Food App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    travelData: {
                      'departure': '2024-03-20 10:00',
                      'arrival': '2024-03-21 14:00',
                      'destination': 'Hong Kong',
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Main Content Here'),
      ),
    );
  }
}
