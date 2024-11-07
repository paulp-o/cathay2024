import 'package:flutter/material.dart';
import 'chat_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: IconButton(
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
      ),
    );
  }
} 