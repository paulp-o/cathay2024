import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripInfoPage extends StatefulWidget {
  @override
  _TripInfoPageState createState() => _TripInfoPageState();
}

class _TripInfoPageState extends State<TripInfoPage> {
  String? departureAirport;
  String? arrivalAirport;
  String? departureDate;
  String? lastDate;
  String? name;

  @override
  void initState() {
    super.initState();
    _loadTripInfo();
  }

  Future<void> _loadTripInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      departureAirport = prefs.getString('departureAirport');
      arrivalAirport = prefs.getString('arrivalAirport');
      departureDate = prefs.getString('departureDate');
      lastDate = prefs.getString('lastDate');
      name = prefs.getString('name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Information'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTripInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                // web image
                child: Image.network(
                    'https://www.scenic.org/wp-content/uploads/2023/04/dino-reichmuth-A5rCN8626Ck-unsplash-scaled.jpeg'),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${name != null ? name!.replaceAll('/', ' ') : 'Guest'}!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.flight_takeoff, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Departure Airport: $departureAirport',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.flight_land, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'Arrival Airport: $arrivalAirport',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.date_range, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            'Departure Date: ${_formatDate(departureDate)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            'Last Date of Travel: ${_formatDate(lastDate)}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_formatDate(String? departureDate) {
  if (departureDate == null) return '';
  final date = DateTime.parse(departureDate);
  return '${date.day}/${date.month}/${date.year}';
}
