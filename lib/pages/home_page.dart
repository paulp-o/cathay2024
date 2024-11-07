import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_info/trip_info_page.dart';
import '../screens/chat_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final travelData = {
              'departureAirport': prefs.getString('departureAirport'),
              'arrivalAirport': prefs.getString('arrivalAirport'),
              'departureDate': prefs.getString('departureDate'),
              'lastDate': prefs.getString('lastDate'),
              'name': prefs.getString('name'),
            };
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(travelData: travelData),
              ),
            );
          },
          child: Text('Go to Chat Screen'),
        ),
      ),
    );
  }
}
