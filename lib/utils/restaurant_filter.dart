// lib/utils/restaurant_filter.dart
import '../models/restaurant.dart';

const Map<String, String> mergedCategories = {
  'Coffee & Vegetarian': 'Coffee & Café',
  'Coffee': 'Coffee & Café',
  'Café': 'Coffee & Café',
  'Italian Café': 'Italian',
  'Bakery/Café': 'Coffee & Café',
  'French Café': 'French',
  'Chocolates/Café': 'Coffee & Café',
  'Café & Vegan': 'Coffee & Café',
  'Café & Healthy Foods': 'Coffee & Café',
  'Bakery': 'Bakery',
  'Bakery & Bar': 'Bakery',
  'Bar & Lounge': 'Bar',
  'Bar': 'Bar',
  'Steakhouse': 'Grill & Steak',
  'BBQ & Grill': 'Grill & Steak',
  'Grill & Seafood': 'Grill & Steak',
  'Bar & Grill': 'Grill & Steak',
  // Add other mappings as needed
};

List<Restaurant> filterRestaurantsByMergedCategory(List<Restaurant> restaurants, String selectedCategory) {
  return restaurants.where((restaurant) {
    String? mergedCategory = mergedCategories[restaurant.typeOfCuisine] ?? restaurant.typeOfCuisine;
    return mergedCategory == selectedCategory;
  }).toList();
}