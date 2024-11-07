// lib/utils/restaurant_parser.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/restaurant.dart';

Future<List<Restaurant>> loadRestaurantData() async {
  final rawData = await rootBundle.loadString('assets/restaurant_data_with_details.csv');
  List<List<dynamic>> rows = const CsvToListConverter().convert(rawData, eol: '\n');

  return rows.skip(1).map((row) {
    try {
      return Restaurant(
        name: row[0],
        location: row[1],
        typeOfCuisine: row[2],
        lat: _parseDouble(row[3]), // Use helper function
        lon: _parseDouble(row[4]), // Use helper function
        address: row[5],
        phoneNumber: row[6],
        openingHours: parseOpeningHours(row[7] ?? ''),
      );
    } catch (e) {
      print('Error parsing restaurant data: $e');
      return null; // Return null if parsing fails for this row
    }
  }).where((restaurant) => restaurant != null).cast<Restaurant>().toList();
}

// Helper function to parse double with default value of 0.0 on error
double _parseDouble(dynamic value) {
  if (value == null || value.toString().trim().isEmpty) {
    return 0.0; // Default value if data is missing
  }
  try {
    return double.parse(value.toString());
  } catch (e) {
    print('Invalid double value: $value. Defaulting to 0.0');
    return 0.0;
  }
}

Map<String, String> parseOpeningHours(String hoursData) {
  final Map<String, String> hours = {};
  
  // Check if hoursData is empty
  if (hoursData.trim().isEmpty) {
    return hours; // Return an empty map if there's no opening hours data
  }

  // Split by newline to handle each day separately
  final days = hoursData.split('\n');
  for (var day in days) {
    // Split by ":" to separate the day from the time
    final splitDay = day.split(':');
    
    // Check if splitDay has at least two parts (day and hours)
    if (splitDay.length < 2) continue;

    hours[splitDay[0].trim()] = splitDay[1].trim();
  }
  
  return hours;
}