import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late GoogleMapController _mapController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  String _sheetTitle = 'Place Name';
  String _sheetDescription = 'Detailed Address';
  LatLng _sheetPosition = const LatLng(22.2968, 114.1722);
  bool _isSheetVisible = false;
  final RxDouble _sheetHeight = 0.0.obs;
  Set<Marker> markers = {}; // Initialize an empty Set of markers
  BitmapDescriptor? customMarkerIcon; // Custom marker icon

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() {
      _sheetHeight.value = _sheetController.size;
    });
    _loadCustomMarker(); // Load the custom marker
    _loadCsvData(); // Load CSV data when the app initializes
  }

  // Load custom marker icon
  Future<void> _loadCustomMarker() async {
    customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(1, 1)), // Adjust the size as needed
      'assets/custom_marker.png',
    );
    setState(() {}); // Update state after loading the icon
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
  
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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
            icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker, // Use custom icon if loaded
            onTap: () {
              _moveCamera(LatLng(lat, lon), name, row[2]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: _sheetHeight.value > 0.95 ? const Size.fromHeight(0) : const Size.fromHeight(56),
        child: AnimatedOpacity(
          opacity: _isSheetVisible ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: Colors.transparent,
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
                  style: const ButtonStyle(),
                  onPressed: () {
                    // Handle settings button press
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(22.2968, 114.1722),
              zoom: 14.4746,
            ),
            markers: markers,
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _isSheetVisible ? 0.3 : 0.0,
            minChildSize: _isSheetVisible ? 0.3 : 0.0,
            maxChildSize: 1,
            snap: true,
            snapSizes: const [0.3, 1],
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
                        // animate to 0.0 after 0.01 seconds to prevent flickering

                        Future.delayed(const Duration(milliseconds: 50), () {
                          _sheetController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        });
                      });
                    },
                    sheetHeight: _sheetHeight.value,
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

  const BottomSheetContent({
    super.key,
    required this.title,
    required this.description,
    required this.position,
    required this.scrollController,
    required this.sheetController,
    required this.onClose,
    required this.sheetHeight,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  // make the line disappear when the sheet is fully expanded
                  color: Colors.white.withOpacity(sheetHeight > 0.95 ? 0.0 : 0.8),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            // add some space when the sheet is fully expanded. Use smooth animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              height: sheetHeight > 0.95 ? 25.0 : 0.0,
              curve: Curves.easeOut,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  sizeCurve: Curves.easeOut,
                  firstCurve: Curves.easeOut,
                  secondCurve: Curves.easeOut,
                  firstChild: Container(),
                  secondChild: InkWell(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        sheetController.animateTo(0.3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      },
                    ),
                  ),
                  crossFadeState: sheetHeight > 0.95 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 600),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),

                // conditionally show the close button when the sheet is fully expanded. use smooth animation
                AnimatedOpacity(
                  opacity: sheetHeight > 0.95 ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: sheetHeight == 1
                        ? null
                        : () {
                            sheetController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            onClose();
                          },
                  ),
                )
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Latitude: ${position.latitude}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            Text(
              'Longitude: ${position.longitude}',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Reservation Date: 2023-10-01',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // Handle reservation button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Make Reservation',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const Divider(
              color: Colors.white,
              thickness: 1.0,
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.white,
                child: Text(
                  'Main Dish',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
