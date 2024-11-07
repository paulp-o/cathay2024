import 'dart:convert';
import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:cathay2024/models/restaurant.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _mapController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  String _sheetTitle = 'Place Name';
  String _sheetDescription = 'Detailed Address';
  LatLng _sheetPosition = const LatLng(22.2968, 114.1722);
  bool _isSheetVisible = false;
  final RxDouble _sheetHeight = 0.0.obs;
  Set<Marker> markers = {}; // Initialize an empty Set of markers
  BitmapDescriptor? customMarkerIcon; // Custom marker icon
  String selectedCategory = ''; // Add selected category

  // Categories for filtering
  final List<String> categories = ['All', 'Coffee & Café', 'Grill & Steak', 'Italian', 'Bakery', 'Bar'];
  
  get restaurants => null;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      _sheetHeight.value = _sheetController.size;
    });
    _loadCustomMarker(); // Load the custom marker
    _loadCsvData(); // Load CSV data when the app initializes
    _loadMenuData(); // Load the menu data on initialization
  }

  // Load custom marker icon
  Future<void> _loadCustomMarker() async {
    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(1, 1)), // Adjust the size as needed
      'assets/custom_marker.png',
    );
    setState(() {}); // Update state after loading the icon
  }

  // Update markers based on selected category
  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    _updateMarkers(category);
  }

  Future<void> _updateMarkers(String category) async {
    Set<Marker> filteredMarkers = {};

    for (var restaurant in restaurants) {
      if (category == 'All' || restaurant.typeOfCuisine == category) {
        final marker = Marker(
          markerId: MarkerId(restaurant.name),
          position: LatLng(restaurant.lat, restaurant.lon),
          icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () {
            _moveCamera(LatLng(restaurant.lat, restaurant.lon), restaurant.name, restaurant.typeOfCuisine);
          },
        );
        filteredMarkers.add(marker);
      }
    }

    setState(() {
      markers = filteredMarkers;
    });
  }

  /// Function to resize a map icon to the specified width and height
Future<BitmapDescriptor> resizeMapIcon(String assetPath, int width, int height) async {
  // Load the image data from assets
  final ByteData data = await rootBundle.load(assetPath);
  
  // Decode and resize the image
  final ui.Codec codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: width,
    targetHeight: height,
  );
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  
  // Convert the resized image to bytes compatible with BitmapDescriptor
  final ByteData? resizedData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
  
  // Return the resized image as a BitmapDescriptor
  return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
}

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveCamera(LatLng position, String title, String description) {
    _mapController.animateCamera(CameraUpdate.newLatLng(position));
    setState(() {
      _sheetTitle = title;
      _sheetDescription = description;
      _sheetPosition = position;
      _isSheetVisible = true;
    });
    _sheetController.animateTo(0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

Future<void> _loadCsvData() async {
  try {
    // Load CSV data as a string
    String csvData = await rootBundle.loadString('assets/restaurant_data.csv');
    print("Raw CSV data loaded:\n$csvData");

    // Replace newlines within quoted fields with a custom delimiter
    csvData = csvData.replaceAllMapped(
      RegExp(r'\"(.*?)\"', dotAll: true),
      (match) => match[0]!.replaceAll('\n', '+'), // Replace newlines within quotes with "+"
    );

    // Split into lines
    List<String> lines = csvData.split('\n');
    print("Total lines (including header): ${lines.length}");

    if (lines.length <= 1) {
      print("CSV file has no data rows.");
      return;
    }

    // Process each line individually, skipping the header
    Set<Marker> loadedMarkers = {};

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Split the line by commas not within quotes
      final List<String> row = line.split(RegExp(r',(?=(?:[^"]*"[^"]*")*[^"]*$)'));

      print("Processing row $i: $row");

      // Verify that the row has exactly 8 columns
      if (row.length != 8) {
        print("Row $i has an unexpected number of columns: ${row.length}");
        continue;
      }

      try {
        // Extract and clean each field
        final String name = row[0].replaceAll('"', '').trim();
        final String location = row[1].replaceAll('"', '').trim();
        final String cuisine = row[2].replaceAll('"', '').trim();
        final double lat = double.parse(row[3].replaceAll('"', '').trim());
        final double lon = double.parse(row[4].replaceAll('"', '').trim());
        final String address = row[5].replaceAll('"', '').trim();
        final String phone = row[6].replaceAll('"', '').trim();
        final String openingHours = row[7].replaceAll('+', '\n').trim();

        print("Creating marker for: $name at ($lat, $lon)");

        BitmapDescriptor customMarkerIcon = await resizeMapIcon('assets/custom_marker.png', 80, 80);

        // Create a marker for each restaurant
    final marker = Marker(
      markerId: MarkerId(name),
      position: LatLng(lat, lon),
      icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
      onTap: () {
        _showBottomSheet(name); // Display bottom sheet with restaurant details and menu
      },
    );

        loadedMarkers.add(marker);
      } catch (e) {
        print("Error parsing row $i: $e");
      }
    }

    // Update markers in state
    setState(() {
      markers = loadedMarkers;
    });
    print("Markers set successfully. Total markers: ${markers.length}");
  } catch (e) {
    print("Error loading CSV data: $e");
  }
}

List<Map<String, dynamic>> restaurantMenus = [];

Future<void> _loadMenuData() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/restaurant_menu_data.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    restaurantMenus = jsonData.map((menu) => Map<String, dynamic>.from(menu)).toList();
    print("Menu data loaded successfully: $restaurantMenus");
  } catch (e) {
    print("Error loading menu data: $e");
  }
}

void _showBottomSheet(String restaurantName) {
  print("Attempting to show bottom sheet for $restaurantName");

  // Find the restaurant's menu by restaurant name
  final restaurantData = restaurantMenus.firstWhere(
    (menu) => menu['restaurant_name'] == restaurantName,
    orElse: () => <String, dynamic>{}, // Return an empty map if not found
  );

  // Use an empty menu if restaurantData is not found or empty
  final List<Map<String, dynamic>> menu = restaurantData.isNotEmpty
      ? List<Map<String, dynamic>>.from(restaurantData['menu'] ?? [])
      : [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allow full-screen behavior
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.4,  // Starting size as a fraction of screen height
        minChildSize: 0.3,      // Minimum size (30% of screen height)
        maxChildSize: 1.0,      // Maximum size (full screen)
        snap: true,             // Enable snapping
        snapSizes: [0.4, 1.0],  // Snap positions at 40% and full screen
        expand: false,          // Prevents full expansion unless snapped to full
        builder: (context, scrollController) {
          return BottomSheetContent(
            title: restaurantData['restaurant_name'] ?? restaurantName,
            description: restaurantData['cuisine_type'] ?? 'No Cuisine Data Available',
            position: LatLng(
              restaurantData['lat'] ?? _sheetPosition.latitude,
              restaurantData['lon'] ?? _sheetPosition.longitude
            ),
            scrollController: scrollController, // Pass the scrollController
            sheetController: _sheetController,
            onClose: () {
              Navigator.pop(context);
            },
            sheetHeight: _sheetHeight.value,
            menu: menu, // Pass the menu data (empty if not found)
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the map to be visible behind the AppBar and filter bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0,
        title: Row(
          children: [
            Clicky(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                margin: const EdgeInsets.only(bottom: 2.0),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    // Handle the tap
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.black, size: 30),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TST",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.airplanemode_active,
                color: Colors.white,
              ),
              iconSize: 30,
              onPressed: () {
                // Handle settings button press
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(22.2968, 114.1722),
              zoom: 14.4746,
            ),
            markers: markers,
          ),
          
          // Positioned Filter Bar below the AppBar
          Positioned(
            top: kToolbarHeight + 70, // Position below the AppBar
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.1), // Semi-transparent background
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () => _filterByCategory(category == 'All' ? '' : category),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCategory == category ? const Color(0xFF005E62) : Colors.grey,
                          foregroundColor: selectedCategory == category ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        ),
                        child: Text(category),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Draggable Scrollable Bottom Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _isSheetVisible ? 0.3 : 0.0,
            minChildSize: _isSheetVisible ? 0.3 : 0.0,
            maxChildSize: 1.0, // Allow it to be pulled to cover the whole screen
            snap: true,
            snapSizes: const [0.3, 1.0],
            shouldCloseOnMinExtent: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Obx(() => BottomSheetContent(
                    title: _sheetTitle,
                    description: _sheetDescription,
                    position: _sheetPosition,
                    scrollController: scrollController,
                    sheetController: _sheetController,
                    onClose: () {
                      setState(() {
                        _isSheetVisible = false;
                        _sheetController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                      });
                    },
                    sheetHeight: _sheetHeight.value,
                    menu: restaurantMenus, // Pass the menu data here
                  ));
            },
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _isSheetVisible ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Handle text button press
          },
          label: Text(
            'search here',
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          ),
          icon: const Icon(Icons.search),
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class BottomSheetContent extends StatelessWidget {
  final String title;
  final String description;
  final LatLng position;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final VoidCallback onClose;
  final double sheetHeight;
  final List<Map<String, dynamic>> menu;

  const BottomSheetContent({
    super.key,
    required this.title,
    required this.description,
    required this.position,
    required this.scrollController,
    required this.sheetController,
    required this.onClose,
    required this.sheetHeight,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(sheetHeight > 0.95 ? 0.0 : 0.8),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
            ),
            const Divider(color: Colors.white24, thickness: 1.0),
            const SizedBox(height: 8.0),
            Text(
              'Menu',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            ...menu.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), // Subtle background for each item
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['item_name'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    item['description'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${item['price'].toString()}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24),
                        Text(
                          item['category'] ?? '',
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}