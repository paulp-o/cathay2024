import 'dart:math';

import 'package:cathay2024/screens/chat_screen.dart';
import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:clicky_flutter/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../region_selection/region_selection_page.dart';
import '../trip_info/trip_info_page.dart';
import 'bottom_sheet_content.dart';
import '../trip_info/input_trip_info_page.dart';

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
  bool _isTripMode = false;

  @override
  void initState() {
    super.initState();
    _sheetState = 0.0;
    _sheetController.addListener(() {
      _sheetHeight.value = _sheetController.size;
    });
    _checkTripMode();
  }

  Future<void> _checkTripMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTripMode = prefs.getBool('tripModeEnabled') ?? false;
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

  void _toggleTripMode() async {
    if (!_isTripMode) {
      final result = await Get.to(() => InputTripInfoPage());
      if (result != null && result['enabled']) {
        setState(() {
          _isTripMode = true;
        });
      }
    } else {
      bool confirmDisable = await _showDisableTripModeDialog();
      if (confirmDisable) {
        // remove trip info from shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('name');
        await prefs.remove('departureAirport');
        await prefs.remove('arrivalAirport');
        await prefs.remove('departureDate');
        await prefs.remove('lastDate');
        // set trip mode to false
        await prefs.setBool('tripModeEnabled', false);
        setState(() {
          _isTripMode = false;
        });
      }
    }
  }

  Future<bool> _showDisableTripModeDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Disable Trip Mode'),
              content: Text(
                  'Are you sure you want to disable trip mode? You will need to enter all trip information again to re-enable it.'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Disable'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _navigateToTripInfoPage() async {
    await Get.to(() => TripInfoPage());
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      if (_isTripMode) ...[
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
      ]
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
                                        fontSize: 40,
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
            left: 16.0,
            top: 16.0 + kToolbarHeight * 2,
            child: AnimatedOpacity(
              opacity: _sheetHeight.value > 0 ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _toggleTripMode,
                    child: Clicky(
                      style: ClickyStyle(color: Colors.transparent),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: _isTripMode ? null : Colors.white,
                          gradient: _isTripMode
                              ? LinearGradient(
                                  colors: [Colors.blue, Colors.purple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.black.withOpacity(0.2),
                            width: _isTripMode ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isTripMode ? Icons.airplanemode_active : Icons.airplanemode_inactive,
                                  color: _isTripMode ? Colors.white : Colors.black,
                                ),
                                SizedBox(width: 8),
                                Switch(
                                  value: _isTripMode,
                                  onChanged: (value) {
                                    _toggleTripMode();
                                  },
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                                  activeColor: _isTripMode ? Colors.white : Theme.of(context).colorScheme.primary,
                                  activeTrackColor: _isTripMode
                                      ? Colors.white.withOpacity(0.5)
                                      : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                ),
                              ],
                            ),
                            Text(
                              _isTripMode ? 'Trip Mode ON!' : 'Trip Mode',
                              style: TextStyle(
                                color: _isTripMode ? Colors.white : Colors.black,
                                fontWeight: _isTripMode ? FontWeight.bold : FontWeight.normal,
                                fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                              ),
                            ),
                            if (_isTripMode)
                              OutlinedButton(
                                onPressed: _navigateToTripInfoPage,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white),
                                ),
                                child: Text(
                                  'View Trip Info',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0),
                  Clicky(
                    style: ClickyStyle(color: Colors.transparent),
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 2),
                            blurRadius: 2,
                          ),
                        ],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: IconButton(
                        //shadow

                        icon: Column(
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
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                final travelData = {
                                  'departureAirport': prefs.getString('departureAirport'),
                                  'arrivalAirport': prefs.getString('arrivalAirport'),
                                  'departureDate': prefs.getString('departureDate'),
                                  'lastDate': prefs.getString('lastDate'),
                                  'name': prefs.getString('name'),
                                  'selectedRegion': _selectedRegion,
                                };

                                // Remove null values
                                travelData.removeWhere((key, value) => value == null);

                                return ChatScreen(travelData: travelData);
                              },
                            ),
                          );
                        },
                      ),
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
