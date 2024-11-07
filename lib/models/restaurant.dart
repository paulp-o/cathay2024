// lib/models/restaurant.dart
class Restaurant {
  final String name;
  final String location;
  final String typeOfCuisine;
  final double lat;
  final double lon;
  final String address;
  final String phoneNumber;
  final Map<String, String> openingHours;

  Restaurant({
    required this.name,
    required this.location,
    required this.typeOfCuisine,
    required this.lat,
    required this.lon,
    required this.address,
    required this.phoneNumber,
    required this.openingHours,
  });
}