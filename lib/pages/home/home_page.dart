import 'dart:math';

import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../region_selection/region_selection_page.dart';
import 'bottom_sheet_content.dart';

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
  LatLng _sheetPosition = LatLng(22.2968, 114.1722);
  final RxDouble _sheetHeight = 0.0.obs;
  double _sheetState = 0.0;
  String _selectedRegion = 'Tsim Sha Tsui';
  LatLng _selectedLatLng = LatLng(22.2976, 114.1722);
  TextEditingController searchController = TextEditingController();
  String _nearestRegion = '';

  @override
  void initState() {
    _sheetState = 0.0;
    super.initState();
    _sheetController.addListener(() {
      _sheetHeight.value = _sheetController.size;
      // _checkSnapPoints();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _checkSnapPoints() {
    if (_sheetController.size < 0.4) {
      print('Bottom sheet snapped to 0.3');
      _sheetHeight.value = _sheetState = 0.3;
    } else if (_sheetController.size > 0.95) {
      print('Bottom sheet snapped to 1.0');
      _sheetHeight.value = _sheetState = 1.0;
      // setState(() {
      //   _sheetState = 1.0;
      // });
      // Add your custom logic here
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveCamera(LatLng position, String title, String description, {bool triggerSheet = true}) {
    _mapController.animateCamera(CameraUpdate.newLatLng(position));
    setState(() {
      _sheetTitle = title;
      _sheetDescription = description;
      _sheetPosition = position;
      !triggerSheet ? _sheetState = 0.0 : _sheetState = 0.3;
      !triggerSheet ? _sheetHeight.value = 0.0 : _sheetHeight.value = 0.3;
      _sheetHeight.value = 0.3;
    });
    _sheetController.animateTo(0.3, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _selectRegion() async {
    final result = await Get.to(() => RegionSelectionPage(
          initialSelectedRegion: _selectedRegion,
        ));
    if (result != null) {
      setState(() {
        _selectedRegion = result['title'];
        _selectedLatLng = result['latLng'];
      });
      _mapController.animateCamera(CameraUpdate.newLatLng(_selectedLatLng));
    }
  }

  void _onCameraMove(CameraPosition position) {
    final nearestRegion = _findNearestRegion(position.target);
    setState(() {
      _nearestRegion = nearestRegion;
      _selectedRegion = nearestRegion;
    });
  }

  String _findNearestRegion(LatLng target) {
    String nearestRegion = '';
    double minDistance = double.infinity;

    hong_kong_regions.forEach((region, districts) {
      districts.forEach((district, neighborhoods) {
        neighborhoods.forEach((neighborhood, coords) {
          final distance = _calculateDistance(target, LatLng(coords['lat'] ?? 0.0, coords['lng'] ?? 0.0));
          if (distance < minDistance) {
            minDistance = distance;
            nearestRegion = neighborhood;
          }
        });
      });
    });

    return nearestRegion;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    final double lat1 = point1.latitude;
    final double lon1 = point1.longitude;
    final double lat2 = point2.latitude;
    final double lon2 = point2.longitude;

    final double p = 0.017453292519943295; // Pi/180
    final double a = 0.5 - cos((lat2 - lat1) * p) / 2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, don't continue.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current location.
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // Move the camera to the current location.
    _moveCamera(currentLatLng, 'Current Position', 'You are here', triggerSheet: false);
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(22.297, 114.172),
        onTap: () {
          _moveCamera(LatLng(22.297, 114.172), 'Marker 1', 'This is marker 1');
        },
      ),
      Marker(
        markerId: MarkerId('marker2'),
        position: LatLng(22.296, 114.173),
        onTap: () {
          _moveCamera(LatLng(22.296, 114.173), 'Marker 2', 'This is marker 2');
        },
      ),
      Marker(
        markerId: MarkerId('marker3'),
        position: LatLng(22.295, 114.171),
        onTap: () {
          _moveCamera(LatLng(22.295, 114.171), 'Marker 3', 'This is marker 3');
        },
      ),
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() {
          return AnimatedOpacity(
            opacity: _sheetHeight.value > 0.750 ? 0.0 : 1.0,
            duration: Duration(milliseconds: 150),
            child: IgnorePointer(
              ignoring: _sheetHeight.value > 0.55,
              child: AppBar(
                // remove leading padding!!!
                titleSpacing: 0,

                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Clicky(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        margin: const EdgeInsets.only(bottom: 2.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: _selectRegion,
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.black,
                                size: 30,
                                shadows: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 2)],
                                grade: 30,
                                weight: 2,
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'selectedRegion',
                                    // dont animate incoming text
                                    createRectTween: (begin, end) {
                                      return RectTween(begin: end, end: end);
                                    },

                                    child: Text(
                                      _nearestRegion.isEmpty ? _selectedRegion : _nearestRegion,
                                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        shadows: [
                                          BoxShadow(color: Colors.black.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 2)
                                        ],
                                      ),
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
              ),
            ),
          );
        }),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            // don't zoom out of hong kong
            minMaxZoomPreference: MinMaxZoomPreference(12.0, 18.0),
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 14.4746,
            ),
            markers: markers,
          ),
          DraggableScrollableSheet(
            snapAnimationDuration: const Duration(milliseconds: 300),
            controller: _sheetController,
            initialChildSize: _sheetState > 0.0 ? 0.3 : 0.0,
            minChildSize: _sheetState > 0.0 ? 0.3 : 0.0,
            maxChildSize: 1,
            snap: true,
            snapSizes: [0.3, 1],
            shouldCloseOnMinExtent: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Obx(() {
                return BottomSheetContent(
                  title: _sheetTitle,
                  description: _sheetDescription,
                  position: _sheetPosition,
                  scrollController: scrollController,
                  sheetController: _sheetController,
                  onClose: () {
                    setState(() {
                      _sheetState = 0.0;
                      _sheetHeight.value = 0.0;
                      // animate to 0.0 after 0.01 seconds to prevent flickering
                      Future.delayed(Duration(milliseconds: 50), () {
                        _sheetController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                      });
                    });
                  },
                  sheetHeight: _sheetHeight.value,
                );
              });
            },
          ),
          Positioned(
            right: 16.0,
            top: 16.0 + kToolbarHeight,
            child: AnimatedOpacity(
              opacity: _sheetHeight.value > 0 ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // chatbot icon button
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: IconButton(
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 35, // Increase icon size
                          ),
                          Container(
                            height: 16, // Set a fixed height
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Chat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Increase text size
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      iconSize: 50, // Increase button size
                      style: ButtonStyle(),
                      onPressed: () {
                        // Handle chatbot button press
                      },
                    ),
                  ),

                  // plane icon button
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: IconButton(
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.airplanemode_active,
                            color: Colors.white,
                            size: 35, // Increase icon size
                          ),
                          Container(
                            height: 16, // Set a fixed height
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Flight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Increase text size
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      iconSize: 50, // Increase button size
                      style: ButtonStyle(),
                      onPressed: () {
                        // Handle settings button press
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   heroTag: 'currentLocation',
          //   onPressed: _getCurrentLocation,
          //   child: Icon(Icons.my_location),
          //   backgroundColor: Theme.of(context).colorScheme.primary,
          // ),
          SizedBox(height: 16),
          AnimatedOpacity(
            opacity: _sheetState > 0.0 ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: FloatingActionButton.extended(
              heroTag: 'search',
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
              icon: Icon(Icons.search),
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
